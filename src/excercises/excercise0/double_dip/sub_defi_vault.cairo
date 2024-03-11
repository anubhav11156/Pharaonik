#[starknet::contract]
mod SubDefiVault {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc20::ERC20Component;

    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;


    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    use core::traits::{TryInto, Into};
    use core::array::ArrayTrait;
    use core::zeroable::Zeroable;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252, get_tx_info
    };
    use pharaonik::interfaces::ISubDefiVault::ISubDefiVault;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::math::Math::{mul_div_down, mul_div_up};
    use pharaonik::utils::errors::Errors;


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        SRC5Event: SRC5Component::Event,
        ERC20Event: ERC20Component::Event,
        Deposit: Deposit,
        Withdraw: Withdraw
    }

    #[derive(Drop, starknet::Event)]
    struct Deposit {
        sender: ContractAddress,
        owner: ContractAddress,
        assets: u256,
        shares: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Withdraw {
        sender: ContractAddress,
        receiver: ContractAddress,
        owner: ContractAddress,
        assets: u256,
        share: u256,
        batchId: u128,
    }

    #[storage]
    struct Storage {
        // components
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        underlying_asset: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, name: felt252, symbol: felt252, _underlying_asset: ContractAddress,
    ) {
        assert(!_underlying_asset.is_zero(), Errors::ZERO_ADDRESS);
        self.underlying_asset.write(_underlying_asset);
    }

    #[external(v0)]
    impl SubDefiVault of ISubDefiVault<ContractState> {
        fn deposit(
            ref self: ContractState,
            amount: u256,
            receiver: ContractAddress,
            market: ContractAddress
        ) -> u256 {
            assert(amount > 0, Errors::ZERO_AMOUNT);
            assert(!receiver.is_zero(), Errors::ZERO_ADDRESS);
            let shares = self.preview_deposit(amount);
            self._deposit(receiver, market, amount, shares);
            return shares;
        }

        fn redeem(
            ref self: ContractState, shares: u256, receiver: ContractAddress, owner: ContractAddress
        ) -> u256 {
            self.reentrancyguard.start();
            self.pausable.assert_not_paused();
            assert(shares <= self.max_redeem(owner), Errors::INVALID_SHARES);
            let fees = self._collect_fees(owner, shares, UNSTAKE);
            let _shares = shares - fees;
            let _assets = self.preview_redeem(_shares);
            if (_assets <= self.vault_balance()) {
                self._immediate_withdraw(get_caller_address(), receiver, owner, _assets, _shares);
            } else {
                self._withdraw(get_caller_address(), receiver, owner, _assets, _shares);
            }
            self.reentrancyguard.end();
            return _assets;
        }

        fn preview_deposit(self: @ContractState, assets: u256) -> u256 {
            self.convert_to_shares(assets)
        }

        fn preview_redeem(self: @ContractState, shares: u256) -> u256 {
            self.convert_to_assets(shares)
        }

        fn convert_to_shares(self: @ContractState, assets: u256) -> u256 {
            let supply: u256 = self.erc20.total_supply();
            if (assets == 0 || supply == 0) {
                assets
            } else {
                mul_div_down(assets, supply, self.total_assets())
            }
        }

        fn convert_to_assets(self: @ContractState, shares: u256) -> u256 {
            let supply: u256 = self.erc20.total_supply();
            if (supply == 0) {
                shares
            } else {
                mul_div_down(shares, self.total_assets(), supply)
            }
        }

        fn asset(self: @ContractState) -> ContractAddress {
            self.underlying_asset.read()
        }
    }

    #[generate_trait]
    impl VaultInternal of VaultInternalTrait {
        // self._deposit(receiver, market, amount, shares); 
        fn _deposit(
            ref self: ContractState,
            receiver: ContractAddress,
            market: ContractAddress,
            amount: u256,
            shares: u256
        ) {
            self.erc20._mint(receiver, shares);
            IERC20CamelDispatcher { contract_address: market }
                .transferFrom(receiver, get_contract_address(), amount);

            self
                .emit(
                    Deposit {
                        sender: receiver,
                        owner: receiver,
                        assets: amount,
                        shares: shares,
                    }
                );
        }

        fn _withdraw(
            ref self: ContractState,
            caller: ContractAddress,
            receiver: ContractAddress,
            owner: ContractAddress,
            assets: u256,
            shares: u256,
        ) {
            if (caller != owner) {
                self.erc20._spend_allowance(owner, caller, shares);
            }

            // Shares transfered to vault contract, which once the vault contract recieves funds
            // will send ETH to respective users and burn the shares
            self.erc20._transfer(owner, get_contract_address(), shares);

            self
                .emit(
                    Withdraw {
                        sender: caller,
                        receiver: receiver,
                        owner: owner,
                        assets: assets,
                        share: shares,
                        batchId: current_batch_id,
                    }
                );
        }


        fn _get_exchange_rate(self: @ContractState) -> ExchangeRateData {
            self._hashstack_config().get_exchange_rate_data()
        }
    }
}


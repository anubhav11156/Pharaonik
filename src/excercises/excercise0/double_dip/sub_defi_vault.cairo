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
    use core::byte_array::ByteArray;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252, get_tx_info
    };
    use pharaonik::interfaces::ISubDefiVault::ISubDefiVault;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::math::Math::{mul_div_down, mul_div_up};
    use pharaonik::utils::errors::Errors;
    use pharaonik::utils::constants::Constants;

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
        receiver: ContractAddress,
        assets: u256,
        shares: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Withdraw {
        receiver: ContractAddress,
        assets: u256,
        share: u256,
    }

    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        admin: ContractAddress,
        underlying_asset: ContractAddress,
        rate: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, _admin: ContractAddress, _underlying_asset: ContractAddress,
    ) {
        assert(!_underlying_asset.is_zero(), Errors::ZERO_ADDRESS);
        assert(!_admin.is_zero(), Errors::ZERO_ADDRESS);
        self.underlying_asset.write(_underlying_asset);
        self.admin.write(_admin);
        self.erc20.initializer("sdETH", "sdETH");
    }

    #[abi(embed_v0)]
    impl SubDefiVault of ISubDefiVault<ContractState> {
        fn deposit(
            ref self: ContractState,
            assets: u256,
            receiver: ContractAddress,
            market: ContractAddress
        ) -> u256 {
            assert(assets > 0, Errors::ZERO_AMOUNT);
            assert(!receiver.is_zero(), Errors::ZERO_ADDRESS);
            let shares = self.preview_deposit(assets);
            self._deposit(receiver, market, assets, shares);
            return shares;
        }

        fn redeem(
            ref self: ContractState, shares: u256, receiver: ContractAddress, owner: ContractAddress
        ) -> u256 {
            assert(shares <= self.erc20.balance_of(receiver), 'Insufficient shares');
            assert(!receiver.is_zero(), Errors::ZERO_ADDRESS);
            let assets = self.preview_redeem(shares);
            self._withdraw(receiver, assets, shares);
            return assets;
        }

        fn preview_deposit(self: @ContractState, assets: u256) -> u256 {
            self.convert_to_shares(assets)
        }

        fn preview_redeem(self: @ContractState, shares: u256) -> u256 {
            self.convert_to_assets(shares)
        }

        fn convert_to_shares(self: @ContractState, assets: u256) -> u256 {
            let rate = (Constants::DECIMALS * Constants::DECIMALS) / self.get_rate();
            mul_div_down(assets, rate, Constants::DECIMALS)
        }

        fn convert_to_assets(self: @ContractState, shares: u256) -> u256 {
            let rate = self.get_rate();
            mul_div_down(shares, rate, Constants::DECIMALS)
        }

        fn asset(self: @ContractState) -> ContractAddress {
            self.underlying_asset.read()
        }

        fn get_rate(self: @ContractState) -> u256 {
            self.rate.read()
        }

        fn update_rate(ref self: ContractState, rate: u256) {
            self._assert_only_admin();
            assert(!rate.is_zero(), 'Zero rate');
            let old_rate = self.get_rate();
            assert(rate != old_rate, 'rate not new');
            self.rate.write(rate);
        }

        fn update_admin(ref self: ContractState, new_admin: ContractAddress) {
            self._assert_only_admin();
            assert(!new_admin.is_zero(), Errors::ZERO_ADDRESS);
            self.admin.write(new_admin);
        }
    }

    #[generate_trait]
    impl SubDefiVaultInternal of SubDefiVaultInternalTrait {
        fn _deposit(
            ref self: ContractState,
            receiver: ContractAddress,
            market: ContractAddress,
            assets: u256,
            shares: u256
        ) {
            self.erc20._mint(receiver, shares);
            let asset_balance_before = self._vault_asset_balance();
            IERC20CamelDispatcher { contract_address: market }
                .transferFrom(receiver, get_contract_address(), assets);
            let asset_balance_after = self._vault_asset_balance();
            assert(asset_balance_after == asset_balance_before + assets, 'Invalid after balance');
            self.emit(Deposit { receiver: receiver, assets: assets, shares: shares, });
        }

        fn _withdraw(
            ref self: ContractState, receiver: ContractAddress, assets: u256, shares: u256,
        ) {
            self.erc20._burn(receiver, shares);
            IERC20CamelDispatcher { contract_address: self.asset() }
                .transferFrom(get_contract_address(), receiver, assets);
            self.emit(Withdraw { receiver: receiver, assets: assets, share: shares, });
        }

        fn _vault_asset_balance(self: @ContractState) -> u256 {
            let balance = IERC20CamelDispatcher { contract_address: self.asset() }
                .balanceOf(get_contract_address());
            balance
        }

        fn _assert_only_admin(self: @ContractState) {
            assert(get_caller_address() == self.admin.read(), 'Caller not admin');
        }
    }
}


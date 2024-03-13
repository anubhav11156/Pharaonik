#[starknet::contract]
mod SubDefiRouter {
    use core::debug::PrintTrait;
    use core::traits::{TryInto, Into};
    use core::array::ArrayTrait;
    use core::zeroable::Zeroable;
    use core::byte_array::ByteArray;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252, get_tx_info
    };
    use pharaonik::interfaces::ISubDefiRouter::ISubDefiRouter;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::interfaces::ISubDefiVault::{
        ISubDefiVaultDispatcher, ISubDefiVaultDispatcherTrait
    };
    use pharaonik::utils::math::Math::{mul_div_down, mul_div_up};
    use pharaonik::utils::errors::Errors;
    use pharaonik::utils::constants::Constants;

    #[derive(Drop, Serde, starknet::Store)]
    struct Market {
        market_id: u32,
        market: ContractAddress,
        market_vault: ContractAddress,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct DepositRequest {
        deposit_id: u8,
        user: ContractAddress,
        deposit_market: ContractAddress,
        assets: u256,
        shares: u256,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct RedeemRequest {
        redeem_id: u8,
        user: ContractAddress,
        redeem_market: ContractAddress,
        assets: u256,
        shares: u256,
    }

    #[storage]
    struct Storage {
        admin: ContractAddress,
        deposit_id: u8,
        redeem_id: u8,
        market_id: u32,
        market_id_to_market: LegacyMap::<u32, Market>,
        deposit_id_detail: LegacyMap::<u8, DepositRequest>,
        redeem_id_detail: LegacyMap::<u8, RedeemRequest>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, _admin: ContractAddress) {
        assert(!_admin.is_zero(), Errors::ZERO_ADDRESS);
        self.admin.write(_admin);
    }

    #[abi(embed_v0)]
    impl SubDefiRouter of ISubDefiRouter<ContractState> {
        fn deposit_request(
            ref self: ContractState, market_id: u32, market: ContractAddress, amount: u256
        ) -> u8 {
            assert((market_id >= 0 && market_id <= (self.market_id.read())), 'Invalid market Id');
            assert(!market.is_zero(), Errors::ZERO_ADDRESS);
            let market_vault = self.get_market(market_id).market_vault;
            let deposit_id = self
                ._deposit_request(amount, get_caller_address(), market, market_vault);
            deposit_id
        }

        fn redeem_request(
            ref self: ContractState, market_id: u32, market: ContractAddress, amount: u256
        ) -> u8 {
            assert((market_id >= 0 && market_id <= self.market_id.read()), 'Invalid market Id');
            let market_vault: ContractAddress = self.get_market(market_id).market_vault;
            let redeem_id = self
                ._redeem_request(amount, get_caller_address(), market, market_vault);
            redeem_id
        }

        fn add_market(
            ref self: ContractState, market: ContractAddress, market_vault: ContractAddress
        ) {
            self._assert_only_admin();
            assert(!market.is_zero(), Errors::ZERO_ADDRESS);
            assert(!market_vault.is_zero(), Errors::ZERO_ADDRESS);
            let market_id: u32 = self.market_id.read();
            self.market_id.write(market_id + 1);

            self
                .market_id_to_market
                .write(
                    market_id,
                    Market { market_id: market_id, market: market, market_vault: market_vault, }
                );
        }

        fn get_market(self: @ContractState, market_id: u32) -> Market {
            self.market_id_to_market.read(market_id)
        }

        fn get_deposit_detail(self: @ContractState, deposit_id: u8) -> DepositRequest {
            assert((deposit_id >= 0 && deposit_id <= self.deposit_id.read()), 'Invalid deposit Id');
            self.deposit_id_detail.read(deposit_id)
        }

        fn get_redeem_detail(self: @ContractState, redeem_id: u8) -> RedeemRequest {
            assert((redeem_id >= 0 && redeem_id <= self.redeem_id.read()), 'Invalid Redeem Id');
            self.redeem_id_detail.read(redeem_id)
        }

        fn get_market_count(self: @ContractState) -> u32 {
            self.market_id.read() + 1
        }

        fn update_admin(ref self: ContractState, new_admin: ContractAddress) {
            self._assert_only_admin();
            assert(!new_admin.is_zero(), Errors::ZERO_ADDRESS);
            self.admin.write(new_admin);
        }
    }

    #[generate_trait]
    impl SubDefiRouterInternal of SubDefiRouterInternalTrait {
        fn _deposit_request(
            ref self: ContractState,
            amount: u256,
            receiver: ContractAddress,
            market: ContractAddress,
            market_vault: ContractAddress
        ) -> u8 {
            let deposit_id: u8 = self.deposit_id.read();
            self.deposit_id.write(deposit_id + 1);
            let shares = ISubDefiVaultDispatcher { contract_address: market_vault }
                .deposit(amount, receiver, market);
            self
                .deposit_id_detail
                .write(
                    deposit_id,
                    DepositRequest {
                        deposit_id: deposit_id,
                        user: receiver,
                        deposit_market: market,
                        assets: amount,
                        shares: shares
                    }
                );
            self.deposit_id.read()
        }

        fn _redeem_request(
            ref self: ContractState,
            amount: u256,
            receiver: ContractAddress,
            market: ContractAddress,
            market_vault: ContractAddress
        ) -> u8 {
            let redeem_id: u8 = self.redeem_id.read();
            self.redeem_id.write(redeem_id + 1);
            let assets = ISubDefiVaultDispatcher { contract_address: market_vault }
                .redeem(amount, receiver, receiver);
            self
                .redeem_id_detail
                .write(
                    redeem_id,
                    RedeemRequest {
                        redeem_id: redeem_id,
                        user: receiver,
                        redeem_market: market,
                        assets: assets,
                        shares: amount
                    }
                );
            self.redeem_id.read()
        }

        fn _assert_only_admin(self: @ContractState) {
            assert(get_caller_address() == self.admin.read(), 'caller not admin');
        }
    }
}


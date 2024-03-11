#[starknet::contract]
mod SubDefiRouter {
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
        market_id: u8,
        market: ContractAddress,
        market_vault: ContractAddress,
    }

    #[storage]
    struct Storage {
        admin: ContractAddress,
        market_count: u32,
        market_id_to_market: LegacyMap::<u8, Market>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, _admin: ContractAddress) {
        assert(!_admin.is_zero(), Errors::ZERO_ADDRESS);
    }

    #[abi(embed_v0)]
    impl SubDefiRouter of ISubDefiRouter<ContractState> {
        fn deposit_request(
            ref self: ContractState, market_id: u8, market: ContractAddress, amount: u256
        ) -> u256 {
            assert(!market.is_zero(), Errors::ZERO_ADDRESS);
            let market_vault = self.get_market(market_id).market_vault;
            0
        }

        fn get_market(sefl: @ContractState, market_id: u8) -> Market {
            self.market_id_to_market.read(market_id)
        }
    }

    #[generate_trait]
    impl SubDefiRouterInternal of SubDefiRouterInternalTrait {
        fn _assert_only_admin(self: @ContractState) {
            assert(get_caller_address() == self.admin.read(), 'Caller not admin');
        }
    }
}


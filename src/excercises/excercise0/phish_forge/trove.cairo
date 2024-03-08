#[starknet::contract]
mod Trove {
    use pharaonik::interfaces::ITrove::ITrove;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::errors::Errors;


    // use core::traits::{Into, TryInto};
    // // use core::array::ArrayTrait;
    // // use core::option::OptionTrait;
    // // use core::serde::Serde;
    // // use core::box::BoxTrait;
    use core::zeroable::Zeroable;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252
    };

    #[storage]
    struct Storage {
        trove_owner: ContractAddress,
        IERC20Camel: IERC20CamelDispatcher,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, trove_owner: ContractAddress, wETH_address: ContractAddress
    ) {
        assert(!trove_owner.is_zero(), Errors::ZERO_ADDRESS);
        assert(!wETH_address.is_zero(), Errors::ZERO_ADDRESS);
        self.trove_owner.write(trove_owner);
        self.IERC20Camel.write(IERC20CamelDispatcher { contract_address: wETH_address });
    }

    #[abi(embed_v0)]
    pub impl Trove of ITrove<ContractState> {
        fn deposit(ref self: ContractState, amount: u256, sender: ContractAddress) {
            assert(!amount.is_zero(), Errors::ZERO_AMOUNT);
            let this_trove = get_contract_address();
            self.IERC20Camel.read().transferFrom(sender, this_trove, amount);
        }
        fn withdraw(ref self: ContractState, amount: u256) {}
    }
}


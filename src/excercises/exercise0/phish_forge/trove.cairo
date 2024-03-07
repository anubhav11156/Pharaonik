#[starknet::contract]
mod Trove {
    use core::traits::Into;
    use core::traits::TryInto;
    use array::ArrayTrait;
    use option::OptionTrait;
    use serde::Serde;
    use box::BoxTrait;
    use starknet::{
        get_caller_address, get_contract_address, ContractAddress,
        ClassHash, // contract_address_to_felt252
    };

    mod Errors {
        const ZERO_ADDRESS: felt252 = 'Zero addres';
    }


    #[storage]
    struct Storage {
        trove_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, trove_owner: ContractAddress) {
        assert(!trove_owner.is_zero(), Errors::ZERO_ADDRESS);
    }

    #[external(v0)]
    impl Trove of ITrove<ContractState> {
        fn deposit(ref self: @ContractState, amount: u256) {}
    }
    #[generate_trait]
    impl Private of PrivateTrait {}
}

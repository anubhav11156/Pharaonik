#[starknet::interface]
pub trait IAttack<TContractState> {
    fn attack(ref self: TContractState) -> ();
}

#[starknet::contract]
mod Attack {
    use pharaonik::interfaces::ISubDefiRouter::{
        ISubDefiRouterDispatcher, ISubDefiRouterDispatcherTrait
    };
    use pharaonik::interfaces::ISubDefiVault::{
        ISubDefiVaultDispatcher, ISubDefiVaultDispatcherTrait
    };
    use pharaonik::utils::errors::Errors;
    use core::zeroable::Zeroable;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252
    };

    #[storage]
    struct Storage {
        sub_defi_router: ISubDefiRouterDispatcher,
        sub_defi_eth_vault: ISubDefiVaultDispatcher,
        owner: ContractAddress
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        _sub_defi_router_address: ContractAddress,
        _sub_defi_eth_vault_address: ContractAddress,
        _owner: ContractAddress
    ) {
        assert(!_sub_defi_router_address.is_zero(), Errors::ZERO_ADDRESS);
        assert(!_sub_defi_eth_vault_address.is_zero(), Errors::ZERO_ADDRESS);
        assert(!_owner.is_zero(), Errors::ZERO_ADDRESS);
        self
            .sub_defi_router
            .write(ISubDefiRouterDispatcher { contract_address: _sub_defi_router_address });
        self
            .sub_defi_eth_vault
            .write(ISubDefiVaultDispatcher { contract_address: _sub_defi_eth_vault_address });
        self.owner.write(_owner);
    }

    #[abi(embed_v0)]
    pub impl Attack of super::IAttack<ContractState> {
        // @todo Complete the below attack fuction to solve this exercise
        fn attack(ref self: ContractState) -> () {}
    }
}


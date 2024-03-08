pub mod Constants {
    use core::traits::{Into, TryInto};
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252
    };

    pub const ETH_SUPPLY: u256 = 100000000000000000000000; // 100000 ETH

    pub fn pharaonik_admin() -> ContractAddress {
        let _pharaonik_admin: ContractAddress = 'PharaonikAdmin'.try_into().unwrap();
        _pharaonik_admin
    }

    pub fn alice() -> ContractAddress {
        let _alice: ContractAddress = 'Alice'.try_into().unwrap();
        _alice
    }

    pub fn bob() -> ContractAddress {
        let _bob: ContractAddress = 'Bob'.try_into().unwrap();
        _bob
    }

    pub fn jhon() -> ContractAddress {
        let _jhon: ContractAddress = 'Jhon'.try_into().unwrap();
        _jhon
    }

    pub fn attacker() -> ContractAddress {
        let _attacker: ContractAddress = 'Attacker'.try_into().unwrap();
        _attacker
    }
}

pub mod Constants {
    use core::traits::{Into, TryInto};
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252, contract_address_const
    };

    pub const ETH_SUPPLY: u256 = 100000000000000000000000; // 100000 ETH
    pub const DECIMALS: u256 = 1000000000000000000; // 18 decimals

    pub fn pharaonik_admin() -> ContractAddress {
        let pharaonik_admin: ContractAddress =
            3108212838208404054834537966372198605045806014890484038615249350689380231004
            .try_into()
            .unwrap();
        pharaonik_admin
    }

    pub fn alice() -> ContractAddress {
        let alice: ContractAddress =
            1111123838208404789834537966372198605045806014890484038615249350689380231004
            .try_into()
            .unwrap();
        alice
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
        let attacker: ContractAddress =
            2223423838208404789834537966372198605045806014890484038615249350689380231004
            .try_into()
            .unwrap();
        attacker
    }
}

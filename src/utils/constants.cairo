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

    pub fn sub_defi_admin() -> ContractAddress {
        let sub_defi_admin: ContractAddress =
            1111123838208409087634537966372198605045806014890484038615249350689380231004
            .try_into()
            .unwrap();
        sub_defi_admin
    }

    pub fn attacker() -> ContractAddress {
        let attacker: ContractAddress =
            2223423838208404789834537966372198605045806014890484038615249350689380231004
            .try_into()
            .unwrap();
        attacker
    }
}

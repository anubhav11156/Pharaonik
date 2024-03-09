mod SetupPhishForge {
    use core::array::ArrayTrait;
    use starknet::ContractAddress;
    use starknet::contract_address_to_felt252;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::constants::Constants;
    use pharaonik::setup::setup::Setup::{
        init_setup, declare_contract, deploy_contract, fund_tokens
    };

    fn setup_phish_forge() -> (ContractAddress, ContractAddress) {
        let wETH_address = init_setup();
        let alice = Constants::alice();
        let amount = 10000000000000000000; // 10 ETH
        fund_tokens(wETH_address, alice, amount);
        let mut call_data = ArrayTrait::new();
        call_data.append(contract_address_to_felt252(alice));
        call_data.append(contract_address_to_felt252(wETH_address));
        let trove_class = declare_contract('Trove');
        let trove_address = deploy_contract(trove_class, call_data);
        (wETH_address, trove_address)
    }
}

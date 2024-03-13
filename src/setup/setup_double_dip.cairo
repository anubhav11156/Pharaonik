mod SetupDoubleDip {
    use core::array::ArrayTrait;
    use starknet::ContractAddress;
    use starknet::contract_address_to_felt252;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::constants::Constants;
    use pharaonik::setup::setup::Setup::{
        init_setup, declare_contract, deploy_contract, fund_tokens
    };

    fn setup_double_dip() -> (ContractAddress, ContractAddress, ContractAddress) {
        let wETH_address = init_setup();
        let router = setup_router();
        let eth_vault = setup_eth_vault(wETH_address);
        let attacker = Constants::attacker();
        fund_tokens(wETH_address, attacker, 5000000000000000000); // 5 ETH
        (wETH_address, router, eth_vault)
    }

    fn setup_router() -> ContractAddress {
        let sub_defi_admin = Constants::sub_defi_admin();
        let mut router_call_data = ArrayTrait::new();
        router_call_data.append(contract_address_to_felt252(sub_defi_admin));
        let sub_defi_router_class = declare_contract('SubDefiRouter');
        let sub_defi_router_address = deploy_contract(sub_defi_router_class, router_call_data);
        sub_defi_router_address
    }

    fn setup_eth_vault(wETH: ContractAddress) -> ContractAddress {
        let sub_defi_admin = Constants::sub_defi_admin();
        let mut eth_vault_call_data = ArrayTrait::new();
        eth_vault_call_data.append('sdETH');
        eth_vault_call_data.append('sdETH');
        eth_vault_call_data.append(contract_address_to_felt252(sub_defi_admin));
        eth_vault_call_data.append(contract_address_to_felt252(wETH));
        let eth_vault_class = declare_contract('SubDefiVault');
        let eth_vault_address = deploy_contract(eth_vault_class, eth_vault_call_data);
        fund_tokens(wETH, eth_vault_address, 1000000000000000000000); // 1000 ETH
        eth_vault_address
    }
}

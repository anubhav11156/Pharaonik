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
        ISubDefiRouterDispatcher, ISubDefiRouterDispatcherTrait
    };
    use pharaonik::excercises::excercise0::double_dip::attack::{
        IAttackSafeDispatcher, IAttackSafeDispatcherTrait
    };
    use pharaonik::utils::constants::Constants;
    use pharaonik::utils::errors::Errors;
    use pharaonik::setup::setup::Setup::{declare_contract, deploy_contract};
    use pharaonik::setup::setup_double_dip::SetupDoubleDip::{setup_double_dip};

    #[test]
    #[feature("safe_dispatcher")]
    fn test_exploit() {
        // Alice deposit action
        let (wETH_address, router_address, eth_vault_address) = setup_double_dip();
        let wETH = IERC20CamelSafeDispatcher { contract_address: wETH_address };
        let SubDefiRouter = ISubDefiRouter { contract_address: router_address };

        // Attack setup
        let attacker = Constants::attacker();
        let deposit_amount: u256 = 5000000000000000000; // 5 ETH

        start_prank(CheatTarget::One(wETH_address), attacker);
        let success = wETH.approve(eth_vault_address, deposit_amount).unwrap();
        assert(success, Errors::APPROVAL_FAILED);
        stop_prank(CheatTarget::One(wETH_address));

        let market_id: u32 = 0;

        start_prank(CheatTarget::One(router_address), attacker);
        let deposit_id: u8 = SubDefiRouter
            .deposit_request(market_id, market, deposit_amount)
            .unwrap();
        stop_prank(CheatTarget::One(trove_address));

        'Excerise Completed!'.print();
    }
}


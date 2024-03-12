#[cfg(test)]
mod TestPhishForge {
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
        let (wETH_address, router_address, eth_vault_address) = setup_phish_forge();
        let wETH = IERC20CamelSafeDispatcher { contract_address: wETH_address };
        let SubDefiRouter = ISubDefiRouterDispatcher { contract_address: router_address };
        let alice = Constants::alice();
        let deposit_amount: u256 = 5000000000000000000; // 5 ETH
        start_prank(CheatTarget::One(wETH_address), alice);
        let success = wETH.approve(trove_address, deposit_amount).unwrap();
        assert(success, Errors::APPROVAL_FAILED);
        stop_prank(CheatTarget::One(wETH_address));
        start_prank(CheatTarget::One(trove_address), alice);
        Trove.deposit(deposit_amount, alice).unwrap();
        stop_prank(CheatTarget::One(trove_address));

        // Attack setup
        // Objective : Phish alice to interact with attack contract and steal all her deposited ETH
        let attacker = Constants::attacker();
        let mut call_data = ArrayTrait::new();
        call_data.append(contract_address_to_felt252(trove_address));
        call_data.append(contract_address_to_felt252(attacker));
        let attack_contract_class: ContractClass = declare_contract('Attack');
        let attack_contract_address: ContractAddress = deploy_contract(
            attack_contract_class, call_data
        );
        let Attack = IAttackSafeDispatcher { contract_address: attack_contract_address };

        let mut mock_tx_info = TxInfoMockTrait::default();
        mock_tx_info.account_contract_address = Option::Some(caller());

        start_spoof(CheatTarget::All, mock_tx_info);
        Attack.attack().unwrap();
        stop_spoof(CheatTarget::All);

        let attacker_balance: u256 = wETH.balanceOf(attacker).unwrap();
        assert(attacker_balance == deposit_amount, Errors::ATTACK_FAILED);
        'Excerise Completed!'.print();
    }

    fn caller() -> ContractAddress {}
}

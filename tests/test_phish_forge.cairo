#[cfg(test)]
mod tests {
    use core::debug::PrintTrait;
    use core::result::ResultTrait;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{contract_address_to_felt252, ContractAddress};
    use snforge_std::{
        declare, ContractClass, ContractClassTrait, start_prank, stop_prank, start_spoof,
        stop_spoof, CheatTarget
    };
    use snforge_std::cheatcodes::tx_info::TxInfoMockTrait;
    use pharaonik::interfaces::IERC20Camel::{
        IERC20CamelSafeDispatcher, IERC20CamelSafeDispatcherTrait
    };
    use pharaonik::interfaces::ITrove::{ITroveSafeDispatcher, ITroveSafeDispatcherTrait};
    use pharaonik::excercises::excercise0::phish_forge::attack::{
        IAttackSafeDispatcher, IAttackSafeDispatcherTrait
    };
    use pharaonik::utils::constants::Constants;
    use pharaonik::utils::errors::Errors;
    use pharaonik::setup::setup::Setup::{declare_contract, deploy_contract};
    use pharaonik::setup::setup_phish_forge::SetupPhishForge::{setup_phish_forge};

    #[test]
    #[feature("safe_dispatcher")]
    fn test_exploit() {
        let (wETH_address, trove_address) = setup_phish_forge();
        let wETH = IERC20CamelSafeDispatcher { contract_address: wETH_address };
        let Trove = ITroveSafeDispatcher { contract_address: trove_address };
        let alice = Constants::alice();
        let deposit_amount: u256 = 5000000000000000000; // 5 ETH

        start_prank(CheatTarget::One(wETH_address), alice);
        let success = wETH.approve(trove_address, deposit_amount).unwrap();
        assert(success, Errors::APPROVAL_FAILED);
        stop_prank(CheatTarget::One(wETH_address));

        start_prank(CheatTarget::One(trove_address), alice);
        Trove.deposit(deposit_amount, alice).unwrap();
        stop_prank(CheatTarget::One(trove_address));

        let attacker = Constants::attacker();
        let mut call_data = ArrayTrait::new();
        call_data.append(contract_address_to_felt252(trove_address));
        call_data.append(contract_address_to_felt252(attacker));
        let attack_contract_class: ContractClass = declare_contract('Attack');
        let attack_contract_address: ContractAddress = deploy_contract(
            attack_contract_class, call_data
        );

        let mut mock_tx_info = TxInfoMockTrait::default();
        mock_tx_info.account_contract_address = Option::Some(alice);

        let Attack = IAttackSafeDispatcher { contract_address: attack_contract_address };

        start_spoof(CheatTarget::All, mock_tx_info);
        Attack.attack().unwrap();
        stop_spoof(CheatTarget::All);

        let attacker_balance: u256 = wETH.balanceOf(attacker).unwrap();
        assert(attacker_balance == deposit_amount, Errors::ATTACK_FAILED);
        'Excerise Completed!'.print();
    }
}

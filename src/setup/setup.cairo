mod Setup {
    use core::array::ArrayTrait;
    // use snforge_std::PrintTrait;
    use snforge_std::L1Handler;
    use snforge_std::L1HandlerTrait;
    use core::result::ResultTrait;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::ContractAddress;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::contract_address_to_felt252;
    use starknet::contract_address_const;
    use snforge_std::{
        declare, ContractClass, ContractClassTrait, start_prank, stop_prank, CheatTarget
    };
    use snforge_std::stop_warp;
    use snforge_std::start_warp;

    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::constants::Constants;

    fn declare_contract(target: felt252) -> ContractClass {
        let contract_class = declare(target);
        contract_class
    }

    fn deploy_contract(class: ContractClass, mut call_data: Array<felt252>) -> ContractAddress {
        let deployed_address = class.deploy(@call_data).unwrap();
        deployed_address
    }

    fn deploy_erc20_token(target: felt252, mut call_data: Array<felt252>) -> ContractAddress {
        let class = declare_contract(target);
        let token_address = deploy_contract(class, call_data);
        token_address
    }

    fn deploy_erc20_token_bridge(
        target: felt252, mut call_data: Array<felt252>
    ) -> ContractAddress {
        let class = declare_contract(target);
        let token_bridge_address = deploy_contract(class, call_data);
        token_bridge_address
    }

    fn setup_wETH_token(supply: u256, recevier: ContractAddress) -> ContractAddress {
        let mut call_data = ArrayTrait::new();
        call_data.append('wETH');
        call_data.append('wETH');
        let wETH_address = deploy_erc20_token('ERC20', call_data);
        let wETH = IERC20CamelDispatcher { contract_address: wETH_address };
        wETH.mint(recevier, supply);
        wETH_address
    }

    fn setup_starknet_eth_bridge(wETH_address: ContractAddress) -> ContractAddress {
        let mut call_data = ArrayTrait::new();
        call_data.append(contract_address_to_felt252(wETH_address));
        let starknet_eth_bridge_address = deploy_erc20_token_bridge('StarknetETHBridge', call_data);
        starknet_eth_bridge_address
    }
// fn setup() {
//     let pharaonik_admin = Constants::pharaonik_admin();
//     let eth_supply: u256 = Constants::ETH_SUPPLY;
//     let wETH_address = setup_wETH_token(eth_supply,pharaonik_admin);
// }

// fn setup_configurations(
//     hashstack_config: ContractAddress,
//     eth_address: ContractAddress,
//     vault_address: ContractAddress,
//     collector_address: ContractAddress,
//     fees_collector: ContractAddress,
//     token_bridge_address: ContractAddress,
//     min_eth_deposit_amount: u256,
//     max_eth_deposit_amount: u256,
//     min_withdraw_amount: u256,
//     max_withdraw_amount: u256,
//     stake_threshold: u256,
//     unstake_threshold: u256,
//     stake_wait_timeStamp: u64,
//     unstake_wait_timeStamp: u64,
//     min_stakers: u128,
//     min_unstakers: u128,
//     l1_reciepient_address: ContractAddress,
//     reserve_percentage: u8,
// ) {
//     let admin = contract_address_const::<7347374374734>();

//     // hashstack_config setups
//     start_prank(CheatTarget::One(hashstack_config), admin);
//     let config_dispatcher = IConfigSafeDispatcher { contract_address: hashstack_config };

//     let vault_settings: VaultSettings = VaultSettings {
//         staking_fees_bips: 10,
//         unstaking_fees_bips: 30,
//         min_eth_deposit_amount: min_eth_deposit_amount,
//         max_eth_deposit_amount: max_eth_deposit_amount,
//         stake_threshold: stake_threshold,
//         unstake_threshold: unstake_threshold,
//         min_stakers_in_batch: min_stakers,
//         min_unstaker_in_batch: min_unstakers,
//         stake_max_wait_time: stake_wait_timeStamp,
//         unstake_max_wait_time: unstake_wait_timeStamp,
//         min_withdraw_amount: min_withdraw_amount,
//         max_withdraw_amount: max_withdraw_amount,
//         er_change_limit: 500,
//         vault_reserve_percentage: reserve_percentage,
//         offchain_stake_threshold: stake_threshold,
//         offchain_unstake_threshold: unstake_threshold,
//     };

//     let auxiliary_contracts: AuxiliaryContracts = AuxiliaryContracts {
//         hashstack_eth_vault: vault_address,
//         hashstack_collector: collector_address,
//         starkgate_eth_bridge: token_bridge_address,
//         ETH_token: eth_address,
//         hashstack_l1_recipient: l1_reciepient_address,
//         fees_collector: fees_collector,
//     };

//     config_dispatcher.update_vault_settings(vault_settings).unwrap();
//     config_dispatcher.update_auxiliary_contracts(auxiliary_contracts).unwrap();

//     // config_dispatcher.update_fees_collector(fees_collector).unwrap();
//     // config_dispatcher.update_min_eth_deposit_amount(min_eth_deposit_amount).unwrap();
//     // config_dispatcher.update_max_eth_deposit_amount(max_eth_deposit_amount).unwrap();
//     // config_dispatcher.update_min_withdraw_amount(min_withdraw_amount).unwrap();
//     // config_dispatcher.update_max_withdraw_amount(max_withdraw_amount).unwrap();
//     // config_dispatcher.update_staking_fees_in_bips(10).unwrap();
//     // config_dispatcher.update_unstaking_fees_in_bips(30).unwrap();
//     // config_dispatcher.update_hashstack_vault(vault_address).unwrap();
//     // config_dispatcher.update_hashstack_collector(collector_address).unwrap();
//     // config_dispatcher.update_ETH_token(eth_address).unwrap();
//     // config_dispatcher.update_stake_threshold(stake_threshold).unwrap();
//     // config_dispatcher.update_unstake_threshold(unstake_threshold).unwrap();
//     // config_dispatcher.update_stake_batch_max_wait_time(stake_wait_timeStamp).unwrap();
//     // config_dispatcher.update_unstake_batch_max_wait_time(unstake_wait_timeStamp).unwrap();
//     // config_dispatcher.update_min_staker_in_batch(min_stakers).unwrap();
//     // config_dispatcher.update_min_unstaker_in_batch(min_unstakers).unwrap();
//     // config_dispatcher.update_hashstack_l1_recipient(l1_reciepient_address).unwrap();
//     // config_dispatcher.update_lido_exchange_rate(871026290691018100).unwrap();
//     // config_dispatcher.update_stader_exchange_rate(1014401042788767703).unwrap();
//     // config_dispatcher.update_reserves_percentage(5).unwrap();
//     stop_prank(CheatTarget::One(hashstack_config));
// }

// fn setup(
//     user: ContractAddress
// ) -> (ContractAddress, ContractAddress, ContractAddress, ContractAddress) {
//     let l1_reciepient_address = contract_address_const::<0987654321>();
//     let admin = contract_address_const::<7347374374734>();
//     let contract = declare('Config');
//     let mut calldata = ArrayTrait::new();
//     calldata.append(contract_address_to_felt252(admin));
//     let config_address = contract.deploy(@calldata).unwrap();
//     let eth_address = deploy_erc20(user);
//     let vault_address = deploy_vault(config_address);
//     let collector_address = deploy_collector(config_address);
//     let fees_collector = contract_address_const::<888888888888>();
//     let token_bridge_address: ContractAddress = setup_mock_token_bridge(
//         eth_address, config_address
//     );
//     setup_configurations(
//         config_address,
//         eth_address,
//         vault_address,
//         collector_address,
//         fees_collector,
//         token_bridge_address,
//         100000000000000000, // min eth 0.1 deposit
//         7000000000000000000, // max eth 7  deposit
//         100000000000000000, // min withdraw 0.1 deposit
//         1000000000000000000, // max withdraw 1 deposit
//         2500000000000000000, // stake threshold 2.5 ETH
//         200000000000000000, // unstake threshold 0.18 hETH
//         3600, // 1 hour wait time
//         3600,
//         3, // min stakers
//         3, // min unstakers
//         l1_reciepient_address,
//         5
//     );

//     (config_address, eth_address, vault_address, collector_address)
// }

// fn set_specialised_config(
//     user: ContractAddress, max_deposit_amt: u256
// ) -> (ContractAddress, ContractAddress, ContractAddress, ContractAddress) {
//     let l1_reciepient_address = contract_address_const::<0987654321>();
//     let admin = contract_address_const::<7347374374734>();

//     let contract = declare('Config');
//     let mut calldata = ArrayTrait::new();
//     calldata.append(contract_address_to_felt252(admin));
//     let config_address = contract.deploy(@calldata).unwrap();

//     let eth_address = deploy_erc20(user);

//     let vault_address = deploy_vault(config_address);

//     let manager_address = deploy_manager(config_address, eth_address, vault_address);

//     let fees_collector = contract_address_const::<888888888888>();

//     setup_configurations(
//         manager_address,
//         config_address,
//         eth_address,
//         vault_address,
//         fees_collector,
//         100000000000000000, // min eth 0.1 deposit
//         max_deposit_amt, // max eth 1  deposit
//         100000000000000000, // min withdraw 0.1 deposit
//         1000000000000000000, // max withdraw 1  deposit
//         3000000000000000000, // stake threshold 3 ETH
//         3600, // stake batch  wait time
//         3600, // unstake batch  wait time
//         3, // min stakers
//         3, // min unstakers
//         l1_reciepient_address
//     );

//     (config_address, eth_address, vault_address, manager_address)
// }

// fn transferETH(
//     to_address: ContractAddress,
//     amount: u256
// ) {
//     start_prank(CheatTarget::One(token_address), from_address);
//     IERC20CamelDispatcher { contract_address: token_address }.transfer(to_address, amount);
//     stop_prank(CheatTarget::One(token_address));
// }
}

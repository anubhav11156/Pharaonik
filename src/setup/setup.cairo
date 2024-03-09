mod Setup {
    use core::array::ArrayTrait;
    use snforge_std::{L1Handler, L1HandlerTrait};
    use core::result::ResultTrait;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{ContractAddress, contract_address_to_felt252, contract_address_const};
    use snforge_std::{
        declare, ContractClass, ContractClassTrait, start_prank, stop_prank, CheatTarget
    };
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::constants::Constants;
    use pharaonik::utils::errors::Errors;

    fn declare_contract(target: felt252) -> ContractClass {
        let contract_class = declare(target);
        contract_class
    }

    fn deploy_contract(_class: ContractClass, mut call_data: Array<felt252>) -> ContractAddress {
        let deployed_address = _class.deploy(@call_data).unwrap();
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
        let wETH_address = deploy_erc20_token('ERC20Camel', call_data);
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

    fn init_setup() -> ContractAddress {
        let pharaonik_admin = Constants::pharaonik_admin();
        let eth_supply: u256 = Constants::ETH_SUPPLY;
        let wETH_address = setup_wETH_token(eth_supply, pharaonik_admin);
        wETH_address
    }

    fn fund_tokens(token_address: ContractAddress, to_address: ContractAddress, amount: u256) {
        let pharaonik_admin = Constants::pharaonik_admin();
        let ERC20Camel = IERC20CamelDispatcher { contract_address: token_address };
        let pharaonik_admin_balance = ERC20Camel.balanceOf(pharaonik_admin);
        assert(amount > 0, Errors::ZERO_AMOUNT);
        assert(amount <= pharaonik_admin_balance, Errors::INSUFFICIENT_ADMIN_BALANCE);
        start_prank(CheatTarget::One(token_address), pharaonik_admin);
        let success: bool = ERC20Camel.transfer(to_address, amount);
        assert(success, Errors::TRANSFER_FAILED);
        stop_prank(CheatTarget::One(token_address));
    }
}

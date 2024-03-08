#[starknet::contract]
mod StarknetETHBridge {
    use pharaonik::interfaces::IStarknetETHBridge::IStarknetETHBridge;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use pharaonik::utils::errors::Errors;

    #[storage]
    struct Storage {
        IERC20Camel: IERC20CamelDispatcher,
    }

    #[constructor]
    fn constructor(ref self: ContractState, wETH_address: ContractAddress) {
        self.IERC20Camel.write(IERC20CamelDispatcher { contract_address: wETH_address });
    }

    #[abi(embed_v0)]
    impl StarknetETHBridge of IStarknetETHBridge<ContractState> {
        fn initiate_withdraw(ref self: ContractState, recipient: felt252, amount: u256) {
            let caller = get_caller_address();
            let this_contract = get_contract_address();
            self.IERC20Camel.read().transferFrom(caller, this_contract, amount);
        }
    }
}

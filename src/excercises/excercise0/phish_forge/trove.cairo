#[starknet::contract]
mod Trove {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use pharaonik::interfaces::ITrove::ITrove;
    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::errors::Errors;
    use core::zeroable::Zeroable;
    use core::starknet::{
        get_caller_address, get_contract_address, ContractAddress, ClassHash,
        contract_address_to_felt252, get_tx_info
    };

    #[storage]
    struct Storage {
        trove_owner: ContractAddress,
        IERC20Camel: IERC20CamelDispatcher,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, trove_owner: ContractAddress, wETH_address: ContractAddress
    ) {
        assert(!trove_owner.is_zero(), Errors::ZERO_ADDRESS);
        assert(!wETH_address.is_zero(), Errors::ZERO_ADDRESS);
        self.trove_owner.write(trove_owner);
        self.IERC20Camel.write(IERC20CamelDispatcher { contract_address: wETH_address });
    }

    #[abi(embed_v0)]
    pub impl Trove of ITrove<ContractState> {
        fn deposit(ref self: ContractState, amount: u256, sender: ContractAddress) {
            assert(!amount.is_zero(), Errors::ZERO_AMOUNT);
            let this_trove = get_contract_address();
            self.IERC20Camel.read().transferFrom(sender, this_trove, amount);
        }

        fn withdraw(ref self: ContractState, amount: u256, receiver: ContractAddress) {
            let caller = get_tx_info().unbox().account_contract_address;
            assert(caller == self.trove_owner.read(), Errors::ONLY_OWNER);
            assert(amount <= self.get_balance(), Errors::INSUFFICIENT_BALANCE);
            let success = self.IERC20Camel.read().transfer(receiver, amount);
            assert(success, Errors::TRANSFER_FAILED);
        }

        fn get_balance(self: @ContractState) -> u256 {
            let this_trove = get_contract_address();
            let balance: u256 = self.IERC20Camel.read().balanceOf(this_trove);
            balance
        }
    }
}


use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
pub trait ITrove<TContractState> {
    fn deposit(ref self: TContractState, amount: u256, sender: ContractAddress);
    fn withdraw(ref self: TContractState, amount: u256);
}

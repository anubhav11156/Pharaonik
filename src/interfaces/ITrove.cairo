use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
pub trait ITrove<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState, amount: u256);
}

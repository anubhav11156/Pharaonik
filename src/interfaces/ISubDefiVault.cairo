use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
trait ISubDefiVault<TContractState> {
    fn deposit(ref self:TContractState, amount:u256, receiver:ContractAddress, market:ContractAddress) -> u256;
}

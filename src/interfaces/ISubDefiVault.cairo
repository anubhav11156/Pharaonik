use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
trait ISubDefiVault<TContractState> {
    fn deposit(
        ref self: TContractState, assets: u256, receiver: ContractAddress, market: ContractAddress
    ) -> u256;
    fn redeem(
        ref self: TContractState, shares: u256, receiver: ContractAddress, owner: ContractAddress
    ) -> u256;
    fn update_rate(ref self: TContractState, rate: u256);
    fn asset(self: @TContractState) -> ContractAddress;
    fn get_rate(self: @TContractState) -> u256;
    fn preview_deposit(self: @TContractState, assets: u256) -> u256;
    fn preview_redeem(self: @TContractState, shares: u256) -> u256;
    fn convert_to_assets(self: @TContractState, shares: u256) -> u256;
    fn convert_to_shares(self: @TContractState, assets: u256) -> u256;
    fn update_admin(ref self: TContractState, new_admin: ContractAddress);
}

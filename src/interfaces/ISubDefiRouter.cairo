use starknet::{ContractAddress, ClassHash};
use pharaonik::excercises::excercise0::double_dip::sub_defi_router::SubDefiRouter::{
    Market, DepositRequest, RedeemRequest
};

#[starknet::interface]
trait ISubDefiRouter<TContractState> {
    fn deposit_request(
        ref self: TContractState, market_id: u32, market: ContractAddress, amount: u256
    ) -> u8;
    fn redeem_request(
        ref self: TContractState, market_id: u32, market: ContractAddress, amount: u256
    ) -> u8;
    fn add_market(ref self: TContractState, market: ContractAddress, market_vault: ContractAddress);
    fn get_market_count(self: @TContractState) -> u32;
    fn get_market(self: @TContractState, market_id: u32) -> Market;
    fn get_deposit_detail(self: @TContractState, deposit_id: u8) -> DepositRequest;
    fn get_redeem_detail(self: @TContractState, redeem_id: u8) -> RedeemRequest;
    fn update_admin(ref self: TContractState, new_admin: ContractAddress);
}

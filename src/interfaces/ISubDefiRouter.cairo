use starknet::{ContractAddress, ClassHash};
use pharaonik::excercises::excercise0::double_dip::sub_defi_router::SubDefiRouter::Market;

#[starknet::interface]
trait ISubDefiRouter<TContractState> {
    fn deposit_request(
        ref self: TContractState, market_id: u8, market: ContractAddress, amount: u256
    ) -> u256;
    fn redeem_request(
        ref self: TContractState, market_id: u8, market: ContractAddress, amount: u256
    ) -> u256;
    fn add_market(ref self: TContractState, market: ContractAddress);
    fn set_market_vault(ref self: TContractState, market_id: u8, market_vault: ContractAddress);
    fn get_market_count(self: @TContractState) -> u32;
    fn get_market(self: @TContractState, market_id: u8) -> Market;
    fn update_admin(ref self: TContractState, new_admin: ContractAddress);
}

#[starknet::interface]
trait IStarknetETHBridge<TContractState> {
    fn initiate_withdraw(ref self: TContractState, recipient: felt252, amount: u256);
}

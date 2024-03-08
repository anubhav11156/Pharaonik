mod excercises {
    mod excercise0 {
        mod phish_forge {
            mod trove;
        }
    }
// mod exercise1 {}

// mod exercise2 {}
}

mod interfaces {
    pub mod ITrove;
    pub mod IERC20Camel;
    pub mod IStarknetETHBridge;
}
mod mocks {
    pub mod starknet_eth_bridge;
    pub mod erc20_camel;
}

mod setup {
    mod setup;
}

mod utils {
    pub mod errors;
    pub mod constants;
}


mod excercises {
    mod excercise0 {
        mod phish_forge {
            mod trove;
            mod attack;
        }

        mod double_dip {
            mod sub_defi_router;
            mod sub_defi_vault;
            mod false_erc_20;
        }
    }
}

mod interfaces {
    pub mod IERC20Camel;
    pub mod IStarknetETHBridge;
    pub mod ITrove;
    pub mod ISubDefiRouter;
    pub mod ISubDefiVault;
}

mod mocks {
    pub mod starknet_eth_bridge;
    pub mod erc20_camel;
}

mod setup {
    mod setup;
    mod setup_phish_forge;
    mod setup_double_dip;
}

mod utils {
    pub mod errors;
    pub mod constants;
    pub mod math;
}

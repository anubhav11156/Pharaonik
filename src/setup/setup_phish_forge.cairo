mod SetupPhishForge {
    use core::array::ArrayTrait;
    // use snforge_std::PrintTrait;
    use snforge_std::L1Handler;
    use snforge_std::L1HandlerTrait;
    use core::result::ResultTrait;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::ContractAddress;
    use starknet::Felt252TryIntoContractAddress;
    use starknet::contract_address_to_felt252;
    use starknet::contract_address_const;
    use snforge_std::{
        declare, ContractClass, ContractClassTrait, start_prank, stop_prank, CheatTarget
    };
    use snforge_std::stop_warp;
    use snforge_std::start_warp;

    use pharaonik::interfaces::IERC20Camel::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use pharaonik::utils::constants::Constants;
}

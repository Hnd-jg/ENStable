// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Script} from "forge-std/Script.sol";
import {IdentityVault} from "../src/core/IdentityVault.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployIdentityVault is Script {
    function run() external returns (IdentityVault, HelperConfig) {
        // 1. Arrange (Obtener config)
        HelperConfig helperConfig = new HelperConfig();
        (address poolManager, address hook,) = helperConfig.activeNetworkConfig();

        // 2. Act (Desplegar)
        vm.startBroadcast();
        IdentityVault vault = new IdentityVault(poolManager, hook);
        vm.stopBroadcast();

        return (vault, helperConfig);
    }
}

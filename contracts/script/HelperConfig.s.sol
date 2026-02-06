// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address poolManager;
        address hook;
        address agentWallet;
    }

    NetworkConfig public activeNetworkConfig;

    address public constant UNICHAIN_POOL_MANAGER = 0x00B036B58a818B1BC34d502D3fE730Db729e62AC;

    constructor() {
        if (block.chainid == 1301) {
            activeNetworkConfig = getUnichainSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    // Esta sí puede ser pure porque no lee storage
    function getUnichainSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            poolManager: UNICHAIN_POOL_MANAGER,
            hook: address(0),
            agentWallet: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        });
    }

    // CAMBIO: Debe ser 'view' porque lee 'activeNetworkConfig'
    function getOrCreateAnvilEthConfig() public view returns (NetworkConfig memory) {
        if (activeNetworkConfig.poolManager != address(0)) {
            return activeNetworkConfig;
        }

        return NetworkConfig({
            poolManager: UNICHAIN_POOL_MANAGER,
            hook: address(0),
            agentWallet: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        });
    }
}

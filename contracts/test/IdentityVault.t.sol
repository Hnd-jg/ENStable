// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Test} from "forge-std/Test.sol";
import {IdentityVault} from "../src/core/IdentityVault.sol";
import {DeployIdentityVault} from "../script/DeployIdentityVault.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol"; // IMPORTANTE

contract IdentityVaultTest is Test {
    IdentityVault vault;
    HelperConfig config;

    address USER = makeAddr("user");

    function setUp() public {
        DeployIdentityVault deployer = new DeployIdentityVault();
        (vault, config) = deployer.run();
    }

    function testOnlyHookCanExecuteAgentAction() public {
        // Arrange
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(0x1)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(0))
        });

        // Act
        vm.prank(USER);

        // Assert
        vm.expectRevert(IdentityVault.IdentityVault__OnlyHookAuthorized.selector);
        vault.executeAgentAction(key, -60, 60, 100e18, USER);
    }
}

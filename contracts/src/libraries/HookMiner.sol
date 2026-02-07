// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title HookMiner
 * @author Cyfrin Updraft
 * @notice A minimal library for mining Uniswap v4 hook addresses.
 * @dev Credit: Original implementation by Cyfrin.
 * Source: https://github.com/Cyfrin/defi-uniswap-v4/blob/main/foundry/src/libraries/HookMiner.sol
 */

// Imports - None

// Interfaces, Libraries, Contracts
library HookMiner {
    // Type declarations - None

    // State variables
    // Mask to slice out the bottom 14 bit of the address
    uint160 constant FLAG_MASK = uint160((1 << 14) - 1);
    // Maximum number of iterations to find a salt, avoid infinite loops or MemoryOOG
    uint256 constant MAX_LOOP = 160_444;

    // Events - None

    // Modifiers - None

    // Functions

    /**
     * @notice Find a salt that produces a hook address with the desired `flags`.
     * @param deployer The address that will deploy the hook.
     * @param flags The desired flags for the hook address (e.g., BEFORE_SWAP_FLAG).
     * @param creationCode The creation code of a hook contract.
     * @param constructorArgs The encoded constructor arguments of a hook contract.
     * @return hookAddress The address where the hook will be deployed.
     * @return salt The salt required to achieve the hookAddress via CREATE2.
     */
    function find(address deployer, uint160 flags, bytes memory creationCode, bytes memory constructorArgs)
        internal
        view
        returns (address, bytes32)
    {
        flags = flags & FLAG_MASK; // mask for only the bottom 14 bits
        bytes memory creationCodeWithArgs = abi.encodePacked(creationCode, constructorArgs);

        address hookAddress;
        for (uint256 salt; salt < MAX_LOOP; salt++) {
            hookAddress = computeAddress(deployer, salt, creationCodeWithArgs);

            // If the hook's bottom 14 bits match the desired flags AND the address does not have bytecode, we found a match
            if (uint160(hookAddress) & FLAG_MASK == flags && hookAddress.code.length == 0) {
                return (hookAddress, bytes32(salt));
            }
        }
        revert("HookMiner: could not find salt");
    }

    /**
     * @notice Precompute a contract address deployed via CREATE2.
     * @param deployer The address that will deploy the hook.
     * @param salt The salt used to deploy the hook.
     * @param creationCodeWithArgs The creation code of a hook contract with encoded arguments.
     * @return hookAddress The precomputed CREATE2 address.
     */
    function computeAddress(address deployer, uint256 salt, bytes memory creationCodeWithArgs)
        internal
        pure
        returns (address hookAddress)
    {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xFF), deployer, salt, keccak256(creationCodeWithArgs)))))
        );
    }
}

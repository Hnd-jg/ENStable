// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IIdentityVault
 * @author Andres Chanchi
 * @notice Interface for the IdentityVault via Agentic Architecture.
 * @dev Follows the "Actuator" pattern for Uniswap v4 liquidity management.
 * This interface defines the interaction between the Hook and the Vault.
 */

// Imports
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId} from "v4-core/types/PoolId.sol";

// Interfaces, Libraries, Contracts
interface IIdentityVault {
    // Errors
    error IdentityVault__OnlyHookAuthorized();
    error IdentityVault__OnlyPoolManager();
    error IdentityVault__PoolManagerAlreadyUnlocked();
    error IdentityVault__GasLimitExceeded();
    error IdentityVault__InvalidTickRange();
    error IdentityVault__Insolvent(int256 delta0, int256 delta1);
    error IdentityVault__NoPositionToWithdraw();
    error IdentityVault__CastError();

    // Type declarations
    /**
     * @dev Optimized Packed Position (Fits in exactly 256 bits).
     * Layout:
     * [status: 8] [lastUpdated: 32] [liquidity: 128] [tickUpper: 24] [tickLower: 24] = 216 bits.
     * Note: This struct allows the Hook to decode packed data efficiently.
     */
    struct PackedPosition {
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint32 lastUpdated;
        uint8 status;
    }

    // Events
    /**
     * @notice Emitted when the AI Agent triggers a repositioning of user liquidity.
     */
    event PositionRepositioned(
        address indexed user, PoolId indexed poolId, int24 tickLower, int24 tickUpper, uint128 newLiquidity
    );

    /**
     * @notice Emitted when a user deposits liquidity into the vault.
     */
    event UserDeposit(address indexed user, uint128 amount);

    /**
     * @notice Emitted when a user withdraws liquidity from the vault.
     */
    event UserWithdrawal(address indexed user, uint128 amount, bool isPartial);

    // Functions

    /**
     * @notice Allows a user to deposit liquidity directly into a specific price range.
     * @param _key The PoolKey identifying the Uniswap V4 pool.
     * @param _amount The amount of liquidity to be added.
     * @param _lower The lower tick of the position range.
     * @param _upper The upper tick of the position range.
     */
    function deposit(PoolKey calldata _key, uint128 _amount, int24 _lower, int24 _upper) external payable;

    /**
     * @notice Allows a user to withdraw their liquidity from the vault.
     * @param _key The PoolKey identifying the Uniswap V4 pool.
     * @param _amount The amount of liquidity to withdraw.
     */
    function withdraw(PoolKey calldata _key, uint128 _amount) external;

    /**
     * @notice Specialized function that allows the authorized Hook to reposition user liquidity.
     * @dev This is the core "Actuator" function driven by AgentSignals.
     * @param _key The PoolKey for the pool.
     * @param _lower The new lower tick boundary.
     * @param _upper The new upper tick boundary.
     * @param _liq The amount of liquidity to move.
     * @param _user The owner of the liquidity.
     */
    function executeAgentAction(PoolKey calldata _key, int24 _lower, int24 _upper, uint128 _liq, address _user) external;

    /**
     * @notice Returns the packed position data for a given user.
     * @dev Used by the Hook to calculate deltas before executing an AgentSignal.
     * @param user The address of the vault depositor.
     */
    function getPosition(address user) external view returns (PackedPosition memory);

    /**
     * @notice Returns the PoolId currently associated with a user's vault position.
     * @param user The address of the vault depositor.
     */
    function getUserPoolId(address user) external view returns (PoolId);

    /**
     * @notice Returns the address of the authorized Hook.
     */
    function getHook() external view returns (address);
}

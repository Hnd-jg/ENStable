// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IEnstableHook
 * @author Andres Chanchi
 * @notice Interface for the Enstable Hook in Uniswap V4, integrating ENS signals and risk management.
 * @dev Follows the layout standards for ETHGlobal judges and high-tier security audits.
 */

// Imports
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

// Interfaces, Libraries, Contracts
interface IEnstableHook is IHooks {
    // Errors
    error EnstableHook__NotAuthorizedAgent();
    error EnstableHook__NotAuthorizedVault();
    error EnstableHook__OnlyPoolManager();
    error EnstableHook__StaleSignal();
    error EnstableHook__InvalidENSNode();
    error EnstableHook__ExtremeVolatility();
    error EnstableHook__InvalidHookData();
    error EnstableHook__CircuitBreakerActive();

    // Type declarations
    struct AgentSignal {
        uint256 currentPrice;
        uint256 volatility;
        int24 recommendedLower;
        int24 recommendedUpper;
        uint128 riskLevel;
        bytes32 ensNode;
        uint256 timestamp;
    }

    // Events
    /**
     * @notice Emitted when an agent signal is processed for a specific pool.
     * @dev poolId is represented as bytes32 to ensure compatibility and gas efficiency during emission.
     */
    event AgentSignalProcessed(address indexed user, bytes32 indexed poolId, int24 low, int24 high);

    /**
     * @notice Emitted when the risk level provided by the signal exceeds the safe threshold.
     */
    event RiskLevelExceeded(address indexed user, uint128 riskLevel);

    /**
     * @notice Emitted when the circuit breaker is triggered to pause hook operations.
     */
    event CircuitBreakerActivated(string reason);

    // Functions

    /**
     * @notice Processes the signal coming from the authorized AI Agent or ENS-linked node.
     * @param _key The PoolKey identifying the Uniswap V4 pool.
     * @param _user The address of the user interacting with the pool.
     * @param _signal The data structure containing the agent's market analysis.
     */
    function processAgentSignal(PoolKey calldata _key, address _user, AgentSignal calldata _signal) external;

    /**
     * @notice Returns the address of the authorized Agent allowed to push signals.
     */
    function getAgentAccount() external view returns (address);
}

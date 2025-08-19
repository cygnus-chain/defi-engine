// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title ICNSCallee - Interface for contracts that receive CNSPair callback
interface ICNSCallee {
    /// @notice Called by CNSPair after transferring tokens for a flash swap
    /// @param sender The address initiating the swap
    /// @param amount0 Amount of token0 sent
    /// @param amount1 Amount of token1 sent
    /// @param data Arbitrary data passed from the swap call
    function CNSCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

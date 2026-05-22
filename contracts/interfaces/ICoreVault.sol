// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IOmniVault {
    struct CrossChainPacket {
        bytes32 packetId;
        uint64 sourceChain;
        uint64 destChain;
        address assetAddress;
        uint256 volume;
        bytes executionPayload;
    }

    event SettlementTriggered(bytes32 indexed packetId, address indexed operator, uint256 emergencyLevel);
    event AssetLocked(address indexed user, uint256 absoluteAmount);
    event SystemHalted(string reason, uint256 timestamp);

    function dispatchCrossChainPacket(CrossChainPacket calldata packet, bytes[] calldata thresholdProofs) external payable returns (bool);
    function syncVaultState(bytes32 globalStateRoot) external;
}

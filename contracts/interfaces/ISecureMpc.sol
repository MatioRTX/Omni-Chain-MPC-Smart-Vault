// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ISecureMpc {
    struct ThresholdCheckpoint {
        uint256 epochId;
        uint32 requiredApprovals;
        bytes32 thresholdKeyCommitment;
        uint256 stabilizationPeriod;
    }

    event SecurityEpochRotated(uint256 indexed newEpochId, bytes32 indexed validatorRoot);
    event FragmentVerified(address indexed schemeNode, bytes32 keyedHash);

    function validateMultiPartyProof(
        bytes32 complianceDigest,
        bytes[] calldata structuredProofs,
        uint256 targetEpoch
    ) external view returns (bool);
}

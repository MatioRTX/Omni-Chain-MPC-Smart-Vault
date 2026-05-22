// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract GuardianRegistry {
    struct RecoveryProposal {
        address proposedNewGovernor;
        uint32 currentApprovals;
        uint64 expirationTimestamp;
        bool isExecuted;
    }

    address public vaultCoreAddress;
    uint256 public totalGuardians;
    uint256 public requiredRecoveryThreshold;

    mapping(address => bool) public isGuardian;
    mapping(bytes32 => RecoveryProposal) public activeProposals;
    mapping(bytes32 => mapping(address => bool)) private _hasVotedOnProposal;

    event GuardianAdded(address indexed guardian);
    event GuardianRemoved(address indexed guardian);
    event RecoveryInitiated(bytes32 indexed proposalId, address indexed proposedGovernor);
    event RecoveryVoteCast(bytes32 indexed proposalId, address indexed guardian, uint32 totalVotes);
    event RecoveryExecuted(address indexed oldGovernor, address indexed newGovernor);

    modifier onlyVaultCore() {
        require(msg.sender == vaultCoreAddress, "GUARDIAN_REGISTRY: ONLY_CORE_VAULT_AUTHORIZED");
        _;
    }

    constructor(address[] memory initialGuardians, uint256 threshold) {
        require(threshold <= initialGuardians.length, "GUARDIAN_REGISTRY: INVALID_THRESHOLD_LIMIT");
        require(threshold > 0, "GUARDIAN_REGISTRY: THRESHOLD_MUST_BE_GREATER_THAN_ZERO");
        
        for (uint256 i = 0; i < initialGuardians.length; i++) {
            address guardian = initialGuardians[i];
            require(guardian != address(0), "GUARDIAN_REGISTRY: INVALID_GUARDIAN_ADDRESS");
            if (!isGuardian[guardian]) {
                isGuardian[guardian] = true;
                emit GuardianAdded(guardian);
            }
        }
        totalGuardians = initialGuardians.length;
        requiredRecoveryThreshold = threshold;
    }

    function setVaultCore(address _vaultCore) external {
        require(vaultCoreAddress == address(0), "GUARDIAN_REGISTRY: CORE_ALREADY_LINKED");
        vaultCoreAddress = _vaultCore;
    }

    function initiateEmergencyRecovery(
        address proposedGovernor,
        bytes32 salt
    ) external returns (bytes32) {
        require(isGuardian[msg.sender], "GUARDIAN_REGISTRY: UNAUTHORIZED_SENDER");
        require(proposedGovernor != address(0), "GUARDIAN_REGISTRY: INVALID_PROPOSED_GOVERNOR");

        bytes32 proposalId = keccak256(abi.encodePacked(proposedGovernor, salt, block.timestamp));
        require(activeProposals[proposalId].expirationTimestamp == 0, "GUARDIAN_REGISTRY: PROPOSAL_EXISTS");

        activeProposals[proposalId] = RecoveryProposal({
            proposedNewGovernor: proposedGovernor,
            currentApprovals: 1,
            expirationTimestamp: uint64(block.timestamp + 3 days),
            isExecuted: false
        });

        _hasVotedOnProposal[proposalId][msg.sender] = true;

        emit RecoveryInitiated(proposalId, proposedGovernor);
        emit RecoveryVoteCast(proposalId, msg.sender, 1);
        return proposalId;
    }

    function supportRecoveryProposal(bytes32 proposalId) external {
        require(isGuardian[msg.sender], "GUARDIAN_REGISTRY: UNAUTHORIZED_SENDER");
        RecoveryProposal storage proposal = activeProposals[proposalId];
        
        require(block.timestamp <= proposal.expirationTimestamp, "GUARDIAN_REGISTRY: PROPOSAL_EXPIRED");
        require(!proposal.isExecuted, "GUARDIAN_REGISTRY: PROPOSAL_ALREADY_EXECUTED");
        require(!_hasVotedOnProposal[proposalId][msg.sender], "GUARDIAN_REGISTRY: ALREADY_VOTED");

        _hasVotedOnProposal[proposalId][msg.sender] = true;
        proposal.currentApprovals++;

        emit RecoveryVoteCast(proposalId, msg.sender, proposal.currentApprovals);

        if (proposal.currentApprovals >= requiredRecoveryThreshold) {
            proposal.isExecuted = true;
            emit RecoveryExecuted(address(0), proposal.proposedNewGovernor);
            // In Production, this would make an external call to OmniVault to update the governor
        }
    }
}

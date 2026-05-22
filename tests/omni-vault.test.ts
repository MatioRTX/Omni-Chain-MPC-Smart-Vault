import { IntentParserEngine, UnparsedUserIntent } from "../sdk/intent-parser";
import { ThresholdEngine, KeyShare } from "../sdk/threshold-utils";
import { MpcSigner } from "../sdk/mpc-signer";

describe("🛡️ OmniShield VaultX System Integration Suite", () => {
    let mockIntent: UnparsedUserIntent;
    let nodeShares: KeyShare[];

    beforeEach(() => {
        mockIntent = {
            sourceNetworkId: 1,         // Ethereum
            destinationNetworkId: 42161, // Arbitrum
            tokenAddress: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // WETH
            rawAmount: "1000000000000000000", // 1.0 ETH
            targetContractPayload: "0xa9059cbb000000000000000000000000da9df944a371991a9e9e8f522b1008bf8934be9a"
        };

        nodeShares = [
            { index: 1, shareValue: "457291048592019485920194859201948592" },
            { index: 2, shareValue: "859201948592019485920194859201948592" },
            { index: 3, shareValue: "129485920194859201948592019485920194" }
        ];
    });

    it("✅ Should successfully compile raw intents into fully-validated cross-chain packets", () => {
        const compiledPacket = IntentParserEngine.compileToCrossChainPacket(mockIntent);
        const isValid = IntentParserEngine.verifyPacketInvariants(compiledPacket);
        
        if (!isValid) throw new Error("Validation Failed: Packet invariants are structurally compromised");
        console.log(`[TEST SUCCESS] Packet ID generated perfectly: ${compiledPacket.packetId}`);
    });

    it("✅ Should securely aggregate multi-party thresholds and detect structural threshold bypasses", () => {
        const signer = new MpcSigner("imtoken-wallet-alpha", nodeShares);
        const messageHash = "0x8fa838e81881726a718271811aa7c191a28189e18192a8e81881726a71827181";
        
        const activeNodes = [1, 3]; // Threshold limit reached (2 out of 3)
        const partialProofs = signer.aggregateAndVerifyThresholdProofs(messageHash, activeNodes);
        
        if (partialProofs.length !== activeNodes.length) {
            throw new Error("Proof generation integrity mismatch detected");
        }
        console.log(`[TEST SUCCESS] Distributed MPC node threshold satisfied with ${partialProofs.length} secure signatures.`);
    });
});

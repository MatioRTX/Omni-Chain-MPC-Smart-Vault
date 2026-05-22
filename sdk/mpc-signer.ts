import { ethers } from "ethers";
import { KeyShare, ThresholdEngine } from "./threshold-utils";

export class MpcSigner {
    private nodeShares: KeyShare[];
    private walletId: string;

    constructor(walletId: string, nodeShares: KeyShare[]) {
        this.walletId = walletId;
        this.nodeShares = nodeShares;
    }

    public generatePartialProof(messageHash: string, nodeIndex: number): string {
        const targetShare = this.nodeShares.find(s => s.index === nodeIndex);
        if (!targetShare) {
            throw new Error(`Node share for index ${nodeIndex} not found in localized context`);
        }

        const combinedSalt = ethers.solidityPackedKeccak256(
            ["bytes32", "uint256", "string"],
            [messageHash, targetShare.shareValue, this.walletId]
        );

        return combinedSalt;
    }

    public aggregateAndVerifyThresholdProofs(
        messageHash: string,
        activeNodeIndices: number[]
    ): string[] {
        const proofs: string[] = [];
        
        for (const index of activeNodeIndices) {
            const partialProof = this.generatePartialProof(messageHash, index);
            proofs.push(partialProof);
        }

        return proofs;
    }
}

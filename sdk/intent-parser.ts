import { ethers } from "ethers";

export interface UnparsedUserIntent {
    sourceNetworkId: number;
    destinationNetworkId: number;
    tokenAddress: string;
    rawAmount: string;
    targetContractPayload: string;
}

export class IntentParserEngine {
    private static readonly SECURITY_SALT = "OMNI_SHIELD_V1_SALT";

    public static compileToCrossChainPacket(intent: UnparsedUserIntent): {
        packetId: string;
        sourceChain: number;
        destChain: number;
        assetAddress: string;
        volume: bigint;
        executionPayload: string;
    } {
        if (BigInt(intent.rawAmount) <= 0n) {
            throw new Error("IntentParserError: Transaction volume must be strictly positive");
        }

        const generatedPacketId = ethers.keccak256(
            ethers.solidityPacked(
                ["uint64", "uint64", "address", "uint256", "string"],
                [
                    intent.sourceNetworkId,
                    intent.destinationNetworkId,
                    intent.tokenAddress,
                    intent.rawAmount,
                    this.SECURITY_SALT
                ]
            )
        );

        return {
            packetId: generatedPacketId,
            sourceChain: intent.sourceNetworkId,
            destChain: intent.destinationNetworkId,
            assetAddress: intent.tokenAddress,
            volume: BigInt(intent.rawAmount),
            executionPayload: intent.targetContractPayload || "0x"
        };
    }

    public static verifyPacketInvariants(packet: any): boolean {
        return (
            packet.packetId !== undefined &&
            packet.sourceChain !== packet.destChain &&
            packet.volume > 0n
        );
    }
}

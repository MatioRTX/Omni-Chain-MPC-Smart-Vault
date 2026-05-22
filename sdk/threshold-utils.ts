import { ethers } from "ethers";

export interface KeyShare {
    index: number;
    shareValue: string; // Hex string of the cryptographic share
}

export class ThresholdEngine {
    private static readonly PRIME_ORDER = BigInt("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141");

    public static reconstructSecret(shares: KeyShare[]): string {
        let secret = BigInt(0);

        for (let i = 0; i < shares.length; i++) {
            let num = BigInt(1);
            let den = BigInt(1);

            for (let j = 0; j < shares.length; j++) {
                if (i === j) continue;
                num = (num * BigInt(-shares[j].index)) % this.PRIME_ORDER;
                let diff = BigInt(shares[i].index - shares[j].index);
                den = (den * diff) % this.PRIME_ORDER;
            }

            const shareValue = BigInt(shares[i].shareValue);
            const lagrangeCoeff = (num * this.modInverse(den, this.PRIME_ORDER)) % this.PRIME_ORDER;
            secret = (secret + (shareValue * lagrangeCoeff)) % this.PRIME_ORDER;
        }

        return "0x" + ((secret + this.PRIME_ORDER) % this.PRIME_ORDER).toString(16);
    }

    private static modInverse(a: bigint, m: bigint): bigint {
        let g = this.gcdExtended(a < 0n ? a + m : a, m);
        return (g.x % m + m) % m;
    }

    private static gcdExtended(a: bigint, b: bigint): { gcd: bigint; x: bigint; y: bigint } {
        if (b === 0n) return { gcd: a, x: 1n, y: 0n };
        let ext = this.gcdExtended(b, a % b);
        return { gcd: ext.gcd, x: ext.y, y: ext.x - (a / b) * ext.y };
    }
}

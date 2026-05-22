# 🛡️ OmniShield VaultX

An enterprise-grade, high-performance **Multi-Language Architecture** for secure multi-chain liquidity management, equipped with an **On-Chain Solidity Core**, **TypeScript MPC Threshold SDK**, and a low-latency **Go Cross-Chain Relay Service**. Designed specifically for the imToken 10th Anniversary Hackathon.

---

## 🏎️ Multi-Language Architecture Breakdown

Our repository splits tasks by the optimal performance profiles of target programming languages:
1. **Contracts (`Solidity ^0.8.26`)**: Handles on-chain execution, secure finite-field polynomial evaluations (`VaultMath.sol`), multi-party signature verifications, and state anchors.
2. **SDK (`TypeScript`)**: Implements off-chain user intents decomposition (`intent-parser.ts`) and threshold secret reconstruction routines via Lagrange Coefficients.
3. **Relayer (`Go`)**: High-throughput parallel block indexing (`bridge_listener.go`) and low-latency network state broadcast engine to minimize cross-chain processing time.

---

## 📂 Repository Directory Layout

```text
omni-shield-vaultx/
├── contracts/                  # 1. On-Chain Cryptographic Settlement Core
│   ├── interfaces/
│   │   ├── IOmniVault.sol
│   │   └── ISecureMpc.sol
│   ├── libraries/
│   │   └── VaultMath.sol
│   └── core/
│       ├── OmniVault.sol
│       └── GuardianRegistry.sol
├── sdk/                        # 2. Client Intent & Threshold Cryptography (TypeScript)
│   ├── mpc-signer.ts
│   ├── threshold-utils.ts
│   └── intent-parser.ts
├── relayer/                    # 3. Microservice Messaging Engine (Go)
│   ├── main.go
│   └── bridge_listener.go
└── tests/                      # 4. End-to-End System Integration Framework
    └── omni-vault.test.ts



## Execution Suite Trigger (TypeScript)
```bash
# Install the environment variables and dependencies
npm install

# Run the unified high-security framework simulation
npx ts-node --transpile-only tests/omni-vault.test.ts

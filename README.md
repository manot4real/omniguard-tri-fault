# 🛡️ OmniGuard: Tri-Fault Credit Monitor

**Production-Grade Multi-Vector Security Trap for the Drosera Network**  
*Real-time monitoring of lending market health across three critical risk vectors*

[![Drosera Network](https://img.shields.io/badge/Drosera-Protocol-4C51BF)](https://drosera.network)
[![Ethereum](https://img.shields.io/badge/Testnet-Hoodi-3C3C3D)](https://hoodi.ethpandaops.io)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.30-363636)](https://soliditylang.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 📊 Executive Summary

The **OmniGuard Tri-Fault Credit Monitor** is a sophisticated security trap deployed on the Drosera Network that provides comprehensive, real-time monitoring of lending protocol health. By simultaneously tracking three orthogonal risk vectors, it offers early warning detection for potential insolvency events, market manipulation, and oracle failures.

**Current Deployment:** `0x8aA08a0C9D63a6a52F405bC909F550E381a643c6` on Hoodi Testnet  
**Status:** **ACTIVE** - Monitoring simulated lending market in triggered fault state

## 🎯 Core Monitoring Logic

### Three Independent Risk Vectors

| Vector | Metric | Threshold | Rationale |
|--------|--------|-----------|-----------|
| **V1: Market Utilization** | `getUtilizationRatio()` | > 95% | Over-utilized markets face liquidity crises and cannot service withdrawals |
| **V2: Protocol Bad Debt** | `getTotalBadDebt()` | > 1000 ETH | Uncollateralized positions threaten protocol solvency and user funds |
| **V3: Oracle Freshness** | `getOracleLastUpdate()` | > 1 hour | Stale price feeds enable manipulation and inaccurate risk calculations |

### Intelligent Alert Logic
**Alert Condition = (V1 OR V2) AND V3**

This logic ensures:
- **High Sensitivity:** Triggers on either fundamental risk (over-utilization OR bad debt)
- **High Specificity:** Requires oracle failure to prevent false positives during normal volatility
- **Actionable Intelligence:** Oracle staleness compounds other risks, warranting immediate response

## 🏗️ System Architecture

### Contract Ecosystem

```mermaid
graph TB
    A[Drosera Network] --> B[OmniGuardTrap.sol]
    B --> C{collect()}
    C --> D[MockLendingMarket.sol]
    D --> E[Utilization Data]
    D --> F[Bad Debt Data]
    D --> G[Oracle Timestamp]
    C --> H[Current Block Time]
    
    B --> I{shouldRespond()}
    I --> J[Risk Logic Engine]
    J --> K[(V1 OR V2) AND V3]
    
    B --> L[Response Trigger]
    L --> M[OmniGuardResponse.sol]
    M --> N[emit TriFaultDetected]
    M --> O[Emergency Actions*]
```

## Contract Addresses (Hoodi Testnet)

| Contract |	Address |	Purpose |
|----------|------------|---------------|
| **Mock Lending Market** |	`0xf294385E5a1AC8e84147Da7565c209c8CF2882c0` | 	Simulated Aave/Compound protocol with adjustable risk parameters |
| **OmniGuard Trap** | 	`0x8aA08a0C9D63a6a52F405bC909F550E381a643c6` | 	Core monitoring logic implementing Drosera ITrap interface |
| **Response Contract** | 	`0xA5C0C612aD61c3A53AC22986d1ed419bF8c15e03` | 	Emergency response executor with upgradeable action framework |

# 🔧 Technical Implementation
## Gas-Optimized Design

```// Efficient data packing in collect()
return abi.encode(utilization, badDebt, oracleUpdate, block.timestamp);

// Pure function logic in shouldRespond()
bool shouldTrigger = (utilizationCritical || badDebtCritical) && oracleStale;
```

**Performance Metrics:**
- `collect()`: 33,830 gas (3 external calls + timestamp)

- `shouldRespond()`: 24,766 gas (complex pure logic with decoding)

- **Total per evaluation:** ~58,596 gas (within Drosera relay limits)

## Drosera Network Configuration

```[traps.omniguard_tri_fault]
response_contract = "0xA5C0C612aD61c3A53AC22986d1ed419bF8c15e03"
response_function = "executeResponse(address,bytes)"
cooldown_period_blocks = 50
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 1  # Gas-optimized single-block sampling
private = true
```


# 🚨 Current Monitoring Scenario

## Active Fault State (Triggered for Testing)

| Parameter | 	Current Value | 	Threshold | 	Status |
| Utilization Ratio | 	96% | 	95% | 	**❌ EXCEEDED** | 
| Bad Debt | 	1,500 ETH | 	1,000 ETH | 	**❌ EXCEEDED** | 
| Oracle Age | 	2+ hours | 	1 hour | **❌ STALE** | 
**Result:** All three fault conditions are met → Trap should be actively triggering responses via Drosera operators.

## Expected Response Flow

1. **Drosera Operators** periodically call `collect()` (every ~50 blocks)

2. **Risk Evaluation** runs `shouldRespond()` with collected data

3. **Alert Generation:** When `(TRUE OR TRUE) AND TRUE = TRUE`

4. **Response Execution:** Operators call `executeResponse()` with context data

5. **Event Emission:** `TriFaultDetected` event with trigger details


# 🛠️ Development & Deployment

## Prerequisites

```# Core dependencies
forge install
forge install openzeppelin/openzeppelin-contracts@v5.0.2
forge install drosera-network/drosera-contracts

# Drosera CLI
curl -L https://cli.drosera.io/install.sh | sh
```

## Deployment Sequence

```# 1. Deploy mock protocol
forge script script/DeployMock.sol --rpc-url $HOODI_RPC_URL --broadcast --legacy

# 2. Deploy response contract
forge script script/DeployResponse.sol --rpc-url $HOODI_RPC_URL --broadcast --legacy

# 3. Configure and deploy trap
drosera dryrun  # Validate configuration
drosera apply   # Deploy to Drosera network
```

## Environment Variables

```HOODI_RPC_URL="https://rpc.hoodi.ethpandaops.io/"
PRIVATE_KEY="0x..."  # Testnet deployer wallet
```

# 📈 Production Roadmap

## Phase 1: Hoodi Testnet (Current)

- Three-vector monitoring logic

- Gas optimization testing

- Response contract framework

- Operator response verification

## Phase 2: Mainnet Preparation

- Gas limit stress testing

- Response contract upgrades

- Multi-protocol support (Aave V3, Compound V3, Euler)

- Governance integration for automated responses

## Phase 3: Enterprise Features

- SLA monitoring dashboards

- Cross-protocol correlation engine

- Machine learning anomaly detection

- Insurance fund triggering mechanism

# 🎓 Learning Resources

## Key Concepts Demonstrated

1. **Multi-Vector Risk Assessment -** Correlated risk factor monitoring

2. **Gas-Aware Smart Contract Design -** Optimization for relay networks

3. **Oracle Security Patterns -** Timeliness as a security primitive

4. **Emergency Response Frameworks -** Graduated response protocols

## Real-World Analogues

- **Aave V3:** `HealthFactor` monitoring + `Oracle` freshness

- **Compound V3:** `Utilization` caps + `ReserveFactor` thresholds

- **MakerDAO:** `CollateralizationRatio` + `Oracle` security modules

# 🔍 Verification & Monitoring

## Live Dashboard
**[Drosera Trap Status:](https://app.drosera.network/traps/0x8aA08a0C9D63a6a52F405bC909F550E381a643c6)**
**[Hoodi Explorer:](https://hoodi.etherscan.io)**

## Response Verification
```
# Check for triggered responses
cast logs --from-block 2122264 \
  --address 0xA5C0C612aD61c3A53AC22986d1ed419bF8c15e03 \
  --rpc-url $HOODI_RPC_URL
222
```


# ⚠️ Risk Considerations

## Technical Limitations

1. **Gas Constraints:** 3 external calls approach Drosera relay limits

2. **Timestamp Precision:** Block timestamps have ~12-second granularity

3. **Oracle Dependency:** Assumes oracle provides accurate timestamps

## Security Assumptions

1. **Protocol Integrity:** Mock contract accurately simulates real protocol behavior

2. **Operator Honesty:** Drosera network operators execute faithfully

3. **Network Stability:** Hoodi testnet maintains consistent block production


# 🤝 Contributing
This project demonstrates advanced Drosera trap patterns. Contributions welcome:

1. **Gas Optimization:** Reduce `collect()` and `shouldRespond()` gas costs

2. **Additional Vectors:** Implement TVL monitoring, whale position tracking

3. **Cross-Protocol Support:** Extend to Morpho Blue, Euler V2, Spark Protocol

# 🙏 Acknowledgments

- **Drosera Network** for the decentralized monitoring infrastructure

- **Hoodi Testnet** for providing a robust testing environment

- **OpenZeppelin** for battle-tested contract libraries


**⚠️ DISCLAIMER:** This is a testnet deployment for educational purposes. Mainnet deployments require extensive security auditing, gas optimization, and risk assessment.

Last Updated: Block 2122271 | Trap Status: ACTIVE | Fault State: TRIGGERED

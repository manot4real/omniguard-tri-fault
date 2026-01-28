
# OmniGuard: Tri-Fault Credit Monitor

A production-grade, multi-vector security trap for the Drosera Network that monitors lending market health across three critical fault vectors.

## Overview

The OmniGuard trap implements comprehensive risk monitoring for lending protocols, simulating real-world production monitoring of protocols like Aave or Compound. It tracks:
1. **Utilization Ratio** - Market overutilization (>95%)
2. **Bad Debt Accumulation** - Protocol insolvency risk (>1000 ETH)
3. **Oracle Freshness** - Price feed staleness (>1 hour)

**Trigger Logic:** `(HighUtilization OR HighBadDebt) AND StaleOracle`

## Architecture

### Contracts
- **MockLendingMarket.sol** (`0xf294385E5a1AC8e84147Da7565c209c8CF2882c0`) - Simulated lending protocol
- **OmniGuardTrap.sol** (`0x8aA08a0C9D63a6a52F405bC909F550E381a643c6`) - 3-vector monitoring trap
- **OmniGuardResponse.sol** (`0xA5C0C612aD61c3A53AC22986d1ed419bF8c15e03`) - Emergency response executor

### Network
- **Network:** Hoodi Testnet (Ethereum Chain ID: 560048)
- **Drosera Relay:** `https://relay.hoodi.drosera.io`
- **Deployment Block:** 2122264

## Technical Specifications

### Gas Usage
- `collect()`: 33,830 gas (3 external calls)
- `shouldRespond()`: 24,766 gas (complex pure logic)
- **Total:** ~58,596 gas per evaluation

### Monitoring Parameters
- **Cooldown:** 50 blocks
- **Operators:** 1-3
- **Sample Size:** 1 block (gas optimized)
- **Privacy:** Private trap, whitelisted operators

## Testing Scenario

The trap is currently monitoring a **triggered fault state**:
- Utilization: 96% (>95% threshold) ✅
- Bad Debt: 1500 ETH (>1000 ETH threshold) ✅  
- Oracle: Stale (2+ hours old) ✅

**Expected Behavior:** Drosera operators should detect this condition and execute the response contract, emitting a `TriFaultDetected` event.

## Deployment Commands

```bash
# Deploy mock protocol
forge script script/DeployMock.sol --rpc-url $HOODI_RPC_URL --broadcast --legacy

# Deploy response contract  
forge script script/DeployResponse.sol --rpc-url $HOODI_RPC_URL --broadcast --legacy

# Deploy trap to Drosera
drosera apply
```

## Files
- `src/mock/MockLendingMarket.sol` - Simulated lending protocol

- `src/OmniGuardTrap.sol` - Core monitoring logic

- `src/OmniGuardResponse.sol` - Response execution

- `drosera.toml` - Network configuration

- `script/DeployMock.sol` - Mock deployment script

- `script/DeployResponse.sol` - Response deployment script

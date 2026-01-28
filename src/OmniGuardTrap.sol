// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./mock/MockLendingMarket.sol";
import {ITrap} from "../lib/drosera-contracts/interfaces/ITrap.sol";

/**
 * @title OmniGuardTrap
 * @dev Monitors 3 fault vectors in a lending market:
 * 1. Utilization Ratio > 95%
 * 2. Bad Debt > 1000 ETH
 * 3. Oracle stale (>1 hour)
 * Trigger: (Vector1 OR Vector2) AND Vector3
 */
contract OmniGuardTrap is ITrap {
    // The mock lending market contract we're monitoring
    address public constant TARGET = 0xf294385E5a1AC8e84147Da7565c209c8CF2882c0;
    
    // Threshold constants (must match MockLendingMarket)
    uint256 public constant MAX_UTILIZATION = 95; // 95%
    uint256 public constant MAX_BAD_DEBT = 1000 ether; // 1000 ETH
    uint256 public constant ORACLE_STALE_TIME = 1 hours;
    
    /**
     * @dev Collects current state data from the target contract.
     * @return bytes - Encoded utilization, bad debt, oracle timestamp, AND current block timestamp.
     * 
     * GAS WARNING: This makes 3 separate external calls. We're at the limit.
     */
    function collect() external view override returns (bytes memory) {
        MockLendingMarket market = MockLendingMarket(TARGET);
        
        uint256 utilization = market.getUtilizationRatio();
        uint256 badDebt = market.getTotalBadDebt();
        uint256 oracleUpdate = market.getOracleLastUpdate();
        uint256 currentTime = block.timestamp;
        
        // Pack all data into a single bytes array
        return abi.encode(utilization, badDebt, oracleUpdate, currentTime);
    }
    
    /**
     * @dev Analyzes collected data to determine if response is needed.
     * @param data Array of historical data points. We use data[0] (most recent).
     * @return (bool, bytes) - Whether to respond, and optional context data.
     * 
     * LOGIC: (Utilization > 95% OR BadDebt > 1000 ETH) AND Oracle is stale (>1 hour)
     */
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Safety check: require at least one data point
        if (data.length == 0) {
            return (false, bytes("No data"));
        }
        
        // Decode the most recent data point
        (uint256 utilization, uint256 badDebt, uint256 oracleUpdate, uint256 collectionTime) = 
            abi.decode(data[0], (uint256, uint256, uint256, uint256));
        
        // Vector 1: Utilization critical
        bool utilizationCritical = utilization > MAX_UTILIZATION;
        
        // Vector 2: Bad debt critical  
        bool badDebtCritical = badDebt > MAX_BAD_DEBT;
        
        // Vector 3: Oracle stale (using timestamp collected at same time as oracle data)
        bool oracleStale = (collectionTime - oracleUpdate) > ORACLE_STALE_TIME;
        
        // Combined logic: (V1 OR V2) AND V3
        bool shouldTrigger = (utilizationCritical || badDebtCritical) && oracleStale;
        
        if (shouldTrigger) {
            // Encode context data about what triggered
            bytes memory context = abi.encode(
                utilizationCritical ? "UTILIZATION" : "",
                badDebtCritical ? "BAD_DEBT" : "",
                oracleStale ? "ORACLE_STALE" : ""
            );
            return (true, context);
        }
        
        return (false, bytes(""));
    }
}

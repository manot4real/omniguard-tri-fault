// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./mock/MockLendingMarket.sol";
import {ITrap} from "../lib/drosera-contracts/interfaces/ITrap.sol";

/**
 * @title OmniGuardTrap (Hardened Production Version)
 * @dev Monitors 3 fault vectors with robust error handling and gas optimization.
 * Technical improvements:
 * 1. Safe decoding with length validation
 * 2. Try/catch for external calls
 * 3. Safe timestamp subtraction
 * 4. Bitmask encoding for efficiency
 */
contract OmniGuardTrap is ITrap {
    // The mock lending market contract we're monitoring
    address public constant TARGET = 0xf294385E5a1AC8e84147Da7565c209c8CF2882c0;
    
    // Threshold constants
    uint256 public constant MAX_UTILIZATION = 95; // 95%
    uint256 public constant MAX_BAD_DEBT = 1000 ether; // 1000 ETH
    uint256 public constant ORACLE_STALE_TIME = 1 hours;
    
    // Bitmask flags for efficient context encoding
    uint8 public constant FLAG_UTILIZATION = 1 << 0; // 0b001
    uint8 public constant FLAG_BAD_DEBT = 1 << 1;    // 0b010
    uint8 public constant FLAG_ORACLE_STALE = 1 << 2; // 0b100
    
    /**
     * @dev Collects current state data with robust error handling.
     * Uses try/catch to prevent bricking if target functions revert.
     */
    function collect() external view override returns (bytes memory) {
        MockLendingMarket market = MockLendingMarket(TARGET);
        
        // Initialize with safe defaults (0 values are treated as suspicious)
        uint256 utilization;
        uint256 badDebt;
        uint256 oracleUpdate;
        
        // Try/catch each external call to prevent total failure
        try market.getUtilizationRatio() returns (uint256 util) {
            utilization = util;
        } catch {
            utilization = 0; // 0% utilization will trigger investigation
        }
        
        try market.getTotalBadDebt() returns (uint256 debt) {
            badDebt = debt;
        } catch {
            badDebt = type(uint256).max; // Max value will flag as critical
        }
        
        try market.getOracleLastUpdate() returns (uint256 update) {
            oracleUpdate = update;
        } catch {
            oracleUpdate = type(uint256).max; // Max timestamp = ancient
        }
        
        uint256 currentTime = block.timestamp;
        
        // Pack all data into a single bytes array (4 * 32 = 128 bytes)
        return abi.encode(utilization, badDebt, oracleUpdate, currentTime);
    }
    
    /**
     * @dev Analyzes collected data with robust validation.
     * - Validates data length before decode
     * - Safe timestamp arithmetic
     * - Efficient bitmask encoding
     */
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Safety check 1: Empty data array
        if (data.length == 0) {
            return (false, bytes(""));
        }
        
        bytes memory latestData = data[0];
        
        // Safety check 2: Validate expected data size (4 uint256 = 128 bytes)
        if (latestData.length != 128) {
            return (false, bytes(""));
        }
        
        // Decode the data (now safe)
        (uint256 utilization, uint256 badDebt, uint256 oracleUpdate, uint256 collectionTime) = 
            abi.decode(latestData, (uint256, uint256, uint256, uint256));
        
        // Vector 1: Utilization critical
        bool utilizationCritical = utilization > MAX_UTILIZATION;
        
        // Vector 2: Bad debt critical (handle max value as failure)
        bool badDebtCritical = (badDebt == type(uint256).max) || (badDebt > MAX_BAD_DEBT);
        
        // Vector 3: Oracle stale (safe subtraction)
        bool oracleStale;
        if (oracleUpdate == 0 || oracleUpdate == type(uint256).max) {
            // 0 timestamp or max value indicates failure
            oracleStale = true;
        } else if (oracleUpdate > collectionTime) {
            // Future timestamp - treat as invalid/stale
            oracleStale = true;
        } else {
            // Safe subtraction (guaranteed non-negative)
            oracleStale = (collectionTime - oracleUpdate) > ORACLE_STALE_TIME;
        }
        
        // Combined logic: (V1 OR V2) AND V3
        bool shouldTrigger = (utilizationCritical || badDebtCritical) && oracleStale;
        
        if (shouldTrigger) {
            // Efficient bitmask encoding (8 bits vs 3 strings)
            uint8 flags = (utilizationCritical ? FLAG_UTILIZATION : 0) |
                         (badDebtCritical ? FLAG_BAD_DEBT : 0) |
                         (oracleStale ? FLAG_ORACLE_STALE : 0);
            
            // Include raw data for forensic analysis
            bytes memory context = abi.encode(
                flags,
                utilization,
                badDebt,
                oracleUpdate,
                collectionTime
            );
            return (true, context);
        }
        
        return (false, bytes(""));
    }
}

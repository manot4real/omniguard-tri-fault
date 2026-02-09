// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./mock/MockLendingMarket.sol";
import {ITrap} from "../lib/drosera-contracts/interfaces/ITrap.sol";

/**
 * @title OmniGuardTrap (Fail-Safe Version)
 * @dev Returns empty bytes on any monitoring failure.
 * This prevents false alerts when target is unreachable.
 */
contract OmniGuardTrap is ITrap {
    address public constant TARGET = 0xf294385E5a1AC8e84147Da7565c209c8CF2882c0;
    uint256 public constant MAX_UTILIZATION = 95;
    uint256 public constant MAX_BAD_DEBT = 1000 ether;
    uint256 public constant ORACLE_STALE_TIME = 1 hours;
    
    // Bitmask flags
    uint8 public constant FLAG_UTILIZATION = 1 << 0;
    uint8 public constant FLAG_BAD_DEBT = 1 << 1;
    uint8 public constant FLAG_ORACLE_STALE = 1 << 2;
    uint8 public constant FLAG_MONITORING_FAILURE = 1 << 3; // New: monitoring degraded
    
    /**
     * @dev Returns empty bytes if ANY external call fails.
     * This ensures monitoring failures don't create false credit alerts.
     */
    function collect() external view override returns (bytes memory) {
        MockLendingMarket market = MockLendingMarket(TARGET);
        
        // Try all three calls - if ANY fails, return empty bytes
        try market.getUtilizationRatio() returns (uint256 utilization) {
            try market.getTotalBadDebt() returns (uint256 badDebt) {
                try market.getOracleLastUpdate() returns (uint256 oracleUpdate) {
                    // All calls succeeded - return normal data
                    uint256 currentTime = block.timestamp;
                    return abi.encode(utilization, badDebt, oracleUpdate, currentTime);
                } catch {
                    return bytes(""); // Oracle call failed
                }
            } catch {
                return bytes(""); // Bad debt call failed
            }
        } catch {
            return bytes(""); // Utilization call failed
        }
    }
    
    /**
     * @dev Analyzes collected data with robust validation.
     */
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Safety check 1: Empty data array
        if (data.length == 0) {
            return (false, bytes(""));
        }
        
        bytes memory latestData = data[0];
        
        // Safety check 2: Empty bytes indicates monitoring failure
        if (latestData.length == 0) {
            // OPTIONAL: Trigger separate "monitoring failure" alert
            // return (true, abi.encode(FLAG_MONITORING_FAILURE, 0, 0, 0, 0));
            return (false, bytes("")); // Silently ignore for now
        }
        
        // Safety check 3: Validate expected data size
        if (latestData.length != 128) {
            return (false, bytes(""));
        }
        
        // Decode the data
        (uint256 utilization, uint256 badDebt, uint256 oracleUpdate, uint256 collectionTime) = 
            abi.decode(latestData, (uint256, uint256, uint256, uint256));
        
        // Vector 1: Utilization critical
        bool utilizationCritical = utilization > MAX_UTILIZATION;
        
        // Vector 2: Bad debt critical
        bool badDebtCritical = badDebt > MAX_BAD_DEBT;
        
        // Vector 3: Oracle stale (safe subtraction)
        bool oracleStale;
        if (oracleUpdate == 0) {
            // 0 timestamp - treat as suspicious but not necessarily stale
            oracleStale = true;
        } else if (oracleUpdate > collectionTime) {
            // Future timestamp - treat as invalid
            oracleStale = true;
        } else {
            // Safe subtraction
            oracleStale = (collectionTime - oracleUpdate) > ORACLE_STALE_TIME;
        }
        
        // Combined logic: (V1 OR V2) AND V3
        bool shouldTrigger = (utilizationCritical || badDebtCritical) && oracleStale;
        
        if (shouldTrigger) {
            // Efficient bitmask encoding
            uint8 flags = (utilizationCritical ? FLAG_UTILIZATION : 0) |
                         (badDebtCritical ? FLAG_BAD_DEBT : 0) |
                         (oracleStale ? FLAG_ORACLE_STALE : 0);
            
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

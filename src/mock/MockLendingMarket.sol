// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockLendingMarket
 * @dev Simulates key risk parameters of a lending protocol for testing OmniGuard trap.
 */
contract MockLendingMarket is Ownable {
    // Vector 1: Utilization ratio (0-100, representing percentage)
    uint256 public utilizationRatio = 85; // Start at 85%
    
    // Vector 2: Bad debt in protocol (in wei)
    uint256 public totalBadDebt = 500 ether; // Start at 500 ETH bad debt
    
    // Vector 3: Oracle timestamp
    uint256 public oracleLastUpdate = block.timestamp;
    
    // Thresholds for testing (can be changed by owner)
    uint256 public constant MAX_UTILIZATION = 95; // 95%
    uint256 public constant MAX_BAD_DEBT = 1000 ether; // 1000 ETH
    uint256 public constant ORACLE_STALE_TIME = 1 hours;
    
    constructor() Ownable(msg.sender) {}
    
    // Getters for our trap to query
    function getUtilizationRatio() external view returns (uint256) {
        return utilizationRatio;
    }
    
    function getTotalBadDebt() external view returns (uint256) {
        return totalBadDebt;
    }
    
    function getOracleLastUpdate() external view returns (uint256) {
        return oracleLastUpdate;
    }
    
    // Setters to simulate risk scenarios (owner only for controlled testing)
    function setUtilizationRatio(uint256 _newRatio) external onlyOwner {
        utilizationRatio = _newRatio;
    }
    
    function setTotalBadDebt(uint256 _newBadDebt) external onlyOwner {
        totalBadDebt = _newBadDebt;
    }
    
    function setOracleLastUpdate(uint256 _newTimestamp) external onlyOwner {
        oracleLastUpdate = _newTimestamp;
    }
    
    // Helper to make oracle stale (set to 2 hours ago)
    function makeOracleStale() external onlyOwner {
        oracleLastUpdate = block.timestamp - 2 hours;
    }
    
    // Helper to trigger all three faults for testing
    function triggerTriFault() external onlyOwner {
        utilizationRatio = 96; // Above 95% threshold
        totalBadDebt = 1500 ether; // Above 1000 ETH threshold
        oracleLastUpdate = block.timestamp - 2 hours; // Stale
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OmniGuardResponse (Access Controlled)
 * @dev Executes when OmniGuardTrap detects faults.
 * Includes caller validation to prevent spoofing.
 */
contract OmniGuardResponse is Ownable {
    // Event with detailed forensic data
    event TriFaultDetected(
        address indexed trap,
        uint8 flags,                // Bitmask: 1=Util, 2=BadDebt, 4=OracleStale
        uint256 utilization,
        uint256 badDebt,
        uint256 oracleUpdate,
        uint256 collectionTime,
        uint256 timestamp
    );
    
    // Authorized Drosera executor address (set after deployment)
    address public authorizedExecutor;
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Set the authorized Drosera executor address.
     * Only callable by owner (deployer).
     */
    function setAuthorizedExecutor(address executor) external onlyOwner {
        authorizedExecutor = executor;
    }
    
    /**
     * @dev Called by Drosera network when trap triggers.
     * @param trap The address of the triggering trap.
     * @param data Context data from trap (bitmask + forensic data).
     */
    function executeResponse(address trap, bytes calldata data) external {
        // Access control: only authorized executor (Drosera) can call
        require(msg.sender == authorizedExecutor, "OmniGuard: Unauthorized");
        
        // Decode the context data
        (uint8 flags, uint256 utilization, uint256 badDebt, uint256 oracleUpdate, uint256 collectionTime) = 
            abi.decode(data, (uint8, uint256, uint256, uint256, uint256));
        
        // In production: implement emergency response logic here
        // e.g., interface with lending market to pause borrows
        
        emit TriFaultDetected(
            trap,
            flags,
            utilization,
            badDebt,
            oracleUpdate,
            collectionTime,
            block.timestamp
        );
    }
    
    /**
     * @dev Emergency override in case executor needs to be changed.
     */
    function emergencyExecute(
        address trap,
        bytes calldata data
    ) external onlyOwner {
        // Owner can always trigger response (for testing/recovery)
        (uint8 flags, uint256 utilization, uint256 badDebt, uint256 oracleUpdate, uint256 collectionTime) = 
            abi.decode(data, (uint8, uint256, uint256, uint256, uint256));
        
        emit TriFaultDetected(
            trap,
            flags,
            utilization,
            badDebt,
            oracleUpdate,
            collectionTime,
            block.timestamp
        );
    }
}

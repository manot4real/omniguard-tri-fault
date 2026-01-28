// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MockLendingMarket} from "../src/mock/MockLendingMarket.sol";

contract DeployMock is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        MockLendingMarket mock = new MockLendingMarket();
        
        vm.stopBroadcast();
        
        console.log("MockLendingMarket deployed at:", address(mock));
        return address(mock);
    }
}

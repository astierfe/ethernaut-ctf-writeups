// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/04_Telephone/TelephoneAttacker.sol";

contract DeployTelephoneAttacker is Script {
    function run() external {
        address telephoneTarget = vm.envAddress("TELEPHONE_TARGET");

        console.log("Deploying TelephoneAttacker to target:", telephoneTarget);

        vm.startBroadcast();
        TelephoneAttacker attacker = new TelephoneAttacker(telephoneTarget);
        vm.stopBroadcast();

        console.log("TelephoneAttacker deployed at:", address(attacker));
    }
}

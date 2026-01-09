// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/11_Elevator/BuildingAttacker.sol";

/**
 * @title DeployBuildingAttacker
 * @notice Deployment script for the BuildingAttacker contract
 */
contract DeployBuildingAttacker is Script {
    function run() external {
        // Read the target Elevator contract address from environment
        address elevatorTarget = vm.envAddress("ELEVATOR_TARGET");

        console.log("Deploying BuildingAttacker to target:", elevatorTarget);

        // Deploy the attacker contract
        vm.startBroadcast();
        BuildingAttacker attacker = new BuildingAttacker(elevatorTarget);
        vm.stopBroadcast();

        console.log("BuildingAttacker deployed at:", address(attacker));
    }
}

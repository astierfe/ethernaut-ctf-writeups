// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/08_Vault/VaultAttacker.sol";

contract DeployVaultAttacker is Script {
    function run() external {
        address vaultTarget = vm.envAddress("VAULT_TARGET");

        console.log("Deploying VaultAttacker to target:", vaultTarget);

        vm.startBroadcast();
        VaultAttacker attacker = new VaultAttacker(vaultTarget);
        vm.stopBroadcast();

        console.log("VaultAttacker deployed at:", address(attacker));
    }
}

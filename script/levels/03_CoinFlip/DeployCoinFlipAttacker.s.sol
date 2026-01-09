// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/03_CoinFlip/CoinFlipAttacker.sol";

contract DeployCoinFlipAttacker is Script {
    function run() external {
        address coinFlipTarget = vm.envAddress("COINFLIP_TARGET");

        console.log("Deploying CoinFlipAttacker to target:", coinFlipTarget);

        vm.startBroadcast();
        CoinFlipAttacker attacker = new CoinFlipAttacker(coinFlipTarget);
        vm.stopBroadcast();

        console.log("CoinFlipAttacker deployed at:", address(attacker));
    }
}

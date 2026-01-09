// SPDX-License-Identifier: MIT
// NOTE: This file is commented out to avoid build errors
// Reason: pragma solidity ^0.6.12 requires OpenZeppelin 0.6 dependencies not installed
// The actual target contract is already deployed on Sepolia at:
// 0x4bdaA92d8b1567BeaaBFc7aB3986fc47688E9a1C

/*
pragma solidity ^0.6.12;

import "openzeppelin-contracts-06/math/SafeMath.sol";

contract Reentrance {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}
*/
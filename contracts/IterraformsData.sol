// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IterraformsData {
    function tokenSVG(uint, uint, uint, uint, uint[] memory) 
        external 
        view 
        returns (string memory);
}

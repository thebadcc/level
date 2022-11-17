// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Iterraforms {
    
    function seed(uint) 
        external 
        view 
        returns (uint);
  
    function tokenToPlacement(uint) 
        external 
        view 
        returns (uint);
  
    function tokenToStatus(uint) 
        external 
        view 
        returns (uint);  
}


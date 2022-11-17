// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Iterraforms {
  function getStatus() public view returns (uint);
  function getSeed() public view returns (uint);
  function getPlacement() public view returns (uint);  
}


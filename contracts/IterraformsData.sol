// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IterraformsData {
  function getTokenSVG(uint indexed status, uint indexed placement, uint indexed seed, uint indexed decay, uint256[] indexed canvas) public view returns (string);
}

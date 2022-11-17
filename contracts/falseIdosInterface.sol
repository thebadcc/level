// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;
// contract interface
contract UsersAgesInterface {
  // function definition of the method we want to interact with
  function getAge(address _myAddress) public view returns (uint);
}

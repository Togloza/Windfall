// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IWinToken {
    

    function MintTo(address _to, string memory _tokenURI) external;

    function isApproved(address operator, uint tokenID) external view returns (bool);

    function getNextTokenID() external view returns (uint);

    function Burn(uint256 _tokenID) external;

    function getBurnedTokens() external view returns (bool[] memory);

    function OwnerOf(uint256 tokenID) external view returns (address);

}
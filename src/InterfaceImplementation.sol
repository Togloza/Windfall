// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./IWinToken.sol";

contract InterfaceImplementation is IWinToken{

IWinToken winTokenAddress;
constructor(IWinToken _winTokenAddress)
{
    require(address(_winTokenAddress) != address(0), "address 0");
    winTokenAddress = _winTokenAddress;
}

    function MintTo(address _to, string memory _tokenURI) external {
        winTokenAddress.MintTo(_to, _tokenURI);
    }

    function isApproved(address operator, uint tokenID) external view returns (bool){
       return winTokenAddress.isApproved(operator, tokenID);
    }

    function getNextTokenID() external view returns (uint) {
        return winTokenAddress.getNextTokenID();
    }

    function Burn(uint256 _tokenID) external {
        winTokenAddress.Burn(_tokenID);  
    }

    function getBurnedTokens() external view returns (bool[] memory) {
        return winTokenAddress.getBurnedTokens();
    }

    function OwnerOf(uint256 tokenID) external view returns (address) {
        return winTokenAddress.OwnerOf(tokenID);
    }

}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";
import "./Access.sol";
import "./IWinToken.sol";

/* UNCOMMENT FOR TURNSTILE REWARDS
interface Turnstile {
function assign(uint256 _tokenId) external returns (uint256);
} 
*/


contract WinToken is ERC721Base, Access, IWinToken  {
    // CSR rewards 

    /* UNCOMMENT FOR TURNSTILE REWARDS
    Turnstile immutable turnstile;
    uint public immutable turnstileTokenId;
    */

    // Mapping to track burned tokens
    mapping(uint => bool) burnedTokens; 


      constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    )
        ERC721Base(
            _name,
            _symbol,
            _royaltyRecipient,
            _royaltyBps
        )
    {     

        /* UNCOMMENT FOR TURNSTILE REWARDS
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstileTokenId = turnstile.assign(turnstileTokenID);
        */
    }


    function mintTo(address _to, string memory _tokenURI) public override(ERC721Base, IWinToken) {
        require(hasRole(MINTER, msg.sender), "Need Minter Role");
        _setTokenURI(nextTokenIdToMint(), _tokenURI);
        _safeMint(_to, 1, "");
    }

    function isApproved(address operator, uint tokenID) public view virtual returns (bool){
        return isApprovedOrOwner(operator, tokenID);
    }
  
    function getNextTokenID() public view virtual returns (uint) {
        return nextTokenIdToMint();
    }
     
    function Burn(uint256 _tokenID) external virtual {
        require(hasRole(MINTER, msg.sender), "Need Minter Role");
        burnedTokens[_tokenID] = true;
        super._burn(_tokenID, true);
    }
 
    function getBurnedTokens() external view returns (bool[] memory){
        bool[] memory burnedTokensArray = new bool[](getNextTokenID());
            for (uint i = 0; i < getNextTokenID(); i++){
                burnedTokensArray[i] = burnedTokens[i];
            }
        return burnedTokensArray;
    } 

    function OwnerOf(uint256 tokenID) external view virtual returns (address) {
        return super.ownerOf(tokenID);
    }



 
}
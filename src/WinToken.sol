// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";
import "./Access.sol";

/* UNCOMMENT FOR TURNSTILE REWARDS
interface Turnstile {
    function register(address) external returns (uint256);
    function withdraw(uint256 _tokenId, address _recipient, uint256 _amount) external returns (uint256);
    function balances(uint256 _tokenId) external view returns (uint256);
}
*/


contract WinToken is ERC721Base, Access, IWinToken  {
    // CSR rewards 
    /* UNCOMMENT FOR TURNSTILE REWARDS
    Turnstile immutable turnstile;
    uint public immutable turnstileTokenId;
    */

    // Wallet that collects CSR rewards
    address csrRewardWallet;
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
        csrRewardWallet = _royaltyRecipient;

        /* UNCOMMENT FOR TURNSTILE REWARDS
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstileTokenId = turnstile.register(tx.origin);
        */
    }


   
    function MintTo(address _to, string memory _tokenURI) external virtual {
        super.mintTo(_to, _tokenURI);
    }

    function isApproved(address operator, uint tokenID) public view virtual returns (bool){
        return isApprovedOrOwner(operator, tokenID);
    }
  
    function getNextTokenID() public view virtual returns (uint) {
        return nextTokenIdToMint();
    }
     
    function Burn(uint256 _tokenID) external virtual {
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

    function _canMint() internal view override returns (bool) { 
        return super.hasRole(MINTER, msg.sender);
    }

    function OwnerOf(uint256 tokenID) external view virtual returns (address) {
        return super.ownerOf(tokenID);
    }

    function Approve(address operator, uint tokenID) external {
        require(isApprovedOrOwner(operator, tokenID));
        super.approve(operator, tokenID);
    }

    function setRewardWallet(address newAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        csrRewardWallet = newAddress;
    }

    
    /*///////////////////////////////////////////////////////////////
                            Turnstile Functions
    //////////////////////////////////////////////////////////////*/
    event csrWithdrawn(uint csrBalance, string whichCSR);
    event tokenTurnstileId(uint tokenId);
 
    // Withdraw CSR rewards to the contract
    // Updates totalPool and rewardBalance variables

    /* UNCOMMENT FOR TURNSTILE REWARDS
    function WithdrawCSR() external payable onlyRole(SAFETY_ADDRESS) {
        uint csrBalance = turnstile.balances(turnstileTokenId);
        // Withdraw balance of staking contract CSR if greater than zero, also emit event
        if(csrBalance > 0){
        // Withdraw funds
        turnstile.withdraw(turnstileTokenId, payable(csrRewardWallet), csrBalance); 
        
        emit csrWithdrawn(csrBalance, "Staking Contract");
        } 
 

    }

    // See current CSR rewards unclaimed
    function CheckCSR() external view onlyRole(SAFETY_ADDRESS) returns (uint) {
        return turnstile.balances(turnstileTokenId);
    }
    */
 
}
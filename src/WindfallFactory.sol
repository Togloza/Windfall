// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;


import "./WinToken.sol";
import "./WinnerCalculator.sol";
import "./Staking.sol";
import "./Access.sol";


interface Turnstile {
    function register(address) external returns (uint256);
    function withdraw(uint256 _tokenId, address _recipient, uint256 _amount) external returns (uint256);
    function balances(uint256 _tokenId) external view returns (uint256);
}


contract WindfallFactory {


    // CSR rewards 
    /* UNCOMMENT FOR TURNSTILE REWARDS
    Turnstile immutable turnstile;
    uint public immutable turnstileTokenId;
    */

    WinToken public winToken;
    IWinToken public tokenContract;
    WinnerCalculator public winnerCalculator;
    Staking public staking;
    Access public access;


    

    constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    ) 
    {
        /* UNCOMMENT FOR TURNSTILE REWARDS
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstileTokenId = turnstile.register(tx.origin);
        */


        winToken = new WinToken(_name, _symbol, _royaltyRecipient, _royaltyBps);
        tokenContract = IWinToken(winToken);
        winnerCalculator = new WinnerCalculator(tokenContract);
        staking = new Staking(tokenContract);

        access = new Access();
        access.giveMintRole(address(staking));
        

        
        
    }

    function isReadyToDraw() public view returns (bool) {
        return winnerCalculator.isReadyToDraw();
    }

    function isWeekReward() public view returns (bool) {
        return winnerCalculator.isWeekReward();
    }
    
    function publishWinner() public {
        (address winnerAddress, ) = winnerCalculator.findWinningNFTAddress();
        winnerCalculator.publishWinningAddress(winnerAddress);
    }



    function getStakingContractBalance() public view returns (uint){
        return staking.getContractBalance();
    }
    
  /*///////////////////////////////////////////////////////////////
                            Turnstile Functions
    //////////////////////////////////////////////////////////////*/
    /* UNCOMMENT FOR TURNSTILE REWARDS
    event csrWithdrawn(uint csrBalance, string whichCSR);
    event tokenTurnstileId(uint tokenId);
 
    // Withdraw CSR rewards to the contract
    // Updates totalPool and rewardBalance variables

 
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
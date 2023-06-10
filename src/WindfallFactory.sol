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

    string memory _name = "winToken";
    string memory _symbol "wT";
    address _royaltyRecipient;
    uint128 _royaltyBps = 300; // 3% royalty

    

    constructor() 
    {
        /* UNCOMMENT FOR TURNSTILE REWARDS
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstileTokenId = turnstile.register(tx.origin);
        */
       _royaltyRecipient = msg.sender;

        winToken = new WinToken(_name, _symbol, _royaltyRecipient, _royaltyBps);
        tokenContract = IWinToken(winToken);
        winnerCalculator = new WinnerCalculator(tokenContract);
        staking = new Staking(tokenContract);

        access = new Access();
        access.giveMintRole(address(staking));
        access.giveSafetyRole(msg.sender);
        

        
        
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
    event csrWithdrawn(uint csrBalance);
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
    function CheckCSR() external view returns (uint) {
        return turnstile.balances(turnstileTokenId);
    }
    */






}
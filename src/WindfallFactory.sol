// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./WinToken.sol";
import "./Staking.sol";

interface Turnstile {
    function register(address) external returns (uint256);
    function withdraw(uint256 _tokenId, address _recipient, uint256 _amount) external returns (uint256);
    function balances(uint256 _tokenId) external view returns (uint256);
}

contract WindfallFactory {

    // CSR rewards 
    /* UNCOMMENT FOR TURNSTILE REWARDS
    Turnstile immutable turnstile;
    uint public immutable turnstileTokenID;
    */

    // Contract instances
    WinToken public winToken;
    Staking public staking;
    

    constructor(string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps)
    {
        /* UNCOMMENT FOR TURNSTILE REWARDS
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstileTokenID = turnstile.register(tx.origin);
        */
        // Create the token and staking contracts.
        winToken = new WinToken(_name, _symbol, _royaltyRecipient, _royaltyBps);
        staking = new Staking(winToken);

        
    }

    // The following functions are for easier access to functions required to run the contract
    function secondsSinceLastDraw() public view returns (uint) {
        return staking.secondsSinceLastDraw();
    }

    function isWeekReward() public view returns (bool) {
        return staking.isWeekReward();
    }

    function getStakingContractBalance() public view returns (uint){
        return staking.getContractBalance();
    }


    function publishWinner() external  {
        require(staking.hasPublisherPerms(msg.sender) || staking.highLevelPerms(msg.sender));
        (address winnerAddress, ) = staking.findWinningNFTAddress();
        staking.publishWinningAddress(winnerAddress);
    }

    function checkValidUnstaking() external view returns (uint[] memory, uint[] memory, uint[] memory) {
        require(staking.highLevelPerms(msg.sender));
        return staking.checkValidUnstaking();
    }

    function recentUnstaking(uint timestamp) external view returns(uint, uint) {
        return staking.recentUnstaking(timestamp);
    }

    function recentUnstakingDay() external view returns(uint, uint) {
        uint timestamp = block.timestamp - 1 days; 
        return staking.recentUnstaking(timestamp);
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


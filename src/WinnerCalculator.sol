// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// Import relevant contracts

import "./InterfaceImplementation.sol";
import "./Metadata.sol";
// Interface for ERC721 contract.

/* UNCOMMENT FOR TURNSTILE REWARDS
interface Turnstile {
function assign(uint256 _tokenId) external returns (uint256);
} 
*/
 
contract WinnerCalculator is InterfaceImplementation, Metadata {


    // What percentage staked rewards are given out. 
    uint public payoutPercent = 800; // 800 = 8%

    // Keep track if weekly reward due
    uint public dayCounter = 1;

    // Updated when winner is published
    uint public winnerTimestamp;


    constructor(IWinToken _winTokenAddress) InterfaceImplementation(_winTokenAddress)
    {
        winTokenAddress = _winTokenAddress;
        /* UNCOMMENT FOR TURNSTILE REWARDS
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstile.assign(csrTokenID);
        */

    }


    event winnerChosen(address winner, uint winningAmount);

    

    // // Generate a random number using current blockchain data and a random input.
    // function generateRandomNumber(uint256 input) internal view returns (uint256) {
    //     // While miners can influece block.timestamp, block.number, the function is a read function
    //     // And when we run the function is up to us and fairly random. 
    //     uint256 randomNumber = uint256(
    //         keccak256(abi.encodePacked(block.timestamp, block.number, input))
    //     );
    //     return randomNumber;
    // }

    function generateRandomNumber(uint256 input) internal view returns (uint256) {
    uint256 randomNumber = uint256(
        keccak256(abi.encodePacked(
            secondsSinceLastDraw(),
            blockhash(block.number - 1), // Use the previous block's hash instead of block.timestamp
            blockhash(block.number - 2), // Use an older block's hash for additional randomness
            input
        ))
    );
    return randomNumber;
}


    // Read function to find the winning address and tokenID
    function findWinningNFTAddress() public view returns (address, uint) {
        uint winningID = calculateWinningNFTID();
        address winner = winTokenAddress.OwnerOf(winningID);
        
        return (winner, winningID);
    }

    // Write function to update contract on winner and amount.
    function publishWinningAddress(address winnerAddress) external {
        require(highLevelPerms(msg.sender)  || hasRole(PUBLISHER, msg.sender),"Wrong permissions");
        uint winningAmount; 
        if (dayCounter % 7 == 0){
            winningAmount = getWeeklyWinningAmount();
        }
        else {
            winningAmount = getDailyWinningAmount(); 
        } 
        
        winnerRewards[winnerAddress] += winningAmount;
        totalRewards += winningAmount;
        winnerTimestamp = block.timestamp;
        dayCounter += 1;
        emit winnerChosen(winnerAddress, winningAmount);
    } 
 
   
    // Function to calculate the ID of the winning NFTID.
    // Chances of winning are proportional to the amount staked by the users.
    // Only NFTs with stakingStatus true are counted.
    function calculateWinningNFTID() internal view returns (uint) {
        uint totalStakingAmount = 0;

        // Calculate the cumulative staking amounts of users with stakingStatus set to true
        for (uint i = 0; i < winTokenAddress.getNextTokenID(); i++) {
            if (users[i].stakingStatus) {
                totalStakingAmount += users[i].stakingAmount;
            }
        }

        // Generate a random number within the range of the cumulative staking amounts
        uint randomNum = generateRandomNumber(totalStakingAmount) % totalStakingAmount;

        // Find the winner by iterating over the users and checking the cumulative staking amounts
        uint cumulativeAmount = 0;
        for (uint i = 0; i < winTokenAddress.getNextTokenID(); i++) {
            if (users[i].stakingStatus) {
                cumulativeAmount += users[i].stakingAmount;
                if (randomNum <= cumulativeAmount) {
                    return i; // Return the NFT ID of the winner
                }
            }
        }

        revert("No winner found"); // This should never happen if there is at least one eligible user
    }

    // Function to see how much is staked by users, seperated by stakingStatus
    function getTotalStakedAmounts() public view returns (uint, uint) {
        uint totalStakingAmount = 0;
        uint totalUnstaking = 0;

        // Calculate the cumulative staking amounts of users with stakingStatus set to true
        for (uint i = 0; i < winTokenAddress.getNextTokenID(); i++) {
            if (users[i].stakingStatus) {
                totalStakingAmount += users[i].stakingAmount;
            } else {
                totalUnstaking += users[i].stakingAmount;
            }
        }
        return (totalStakingAmount, totalUnstaking);
    } 

    function getDailyWinningAmount() public view returns (uint) {
        (uint winningAmount, ) = getTotalStakedAmounts();
        return calculateDailyWinningAmount(winningAmount);
    }
 
    function getWeeklyWinningAmount() public view returns (uint) {
        (uint winningAmount, ) = getTotalStakedAmounts();
        return calculateWeeklyWinningAmount(winningAmount);
    } 

    function calculateDailyWinningAmount(uint inputAmount) internal view returns (uint) {
        return (inputAmount * payoutPercent) / (365 * 200 * 100); // Half day's rewards
    }

    function calculateWeeklyWinningAmount(uint inputAmount) internal view returns (uint) {
        return (inputAmount * payoutPercent) / (365 * 25 * 100);// Full day's rewards plus 6 half day rewards. 
    } 

    function secondsSinceLastDraw() public view returns (uint) {
        return checkTimestamp(winnerTimestamp); 
    } 
    function checkTimestamp(uint timestamp) internal view returns (uint) {
        return block.timestamp - timestamp;
    }

    function isWeekReward() public view returns (bool) {
        return (dayCounter % 7) == 0; 
    } 

    function setPayoutPercent(uint _payoutPercent) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SAFETY_ADDRESS, msg.sender), "Wrong Permissions");
        payoutPercent = _payoutPercent;
    }



}


// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// Import relevant contracts

import "./InterfaceImplementation.sol";
import "./Metadata.sol";
// Interface for ERC721 contract.


 
contract WinnerCalculator is InterfaceImplementation, Metadata {


    // What percentage staked rewards are given out. 
    uint public payoutPercent = 800; // 800 = 8%

    // Keep track if weekly reward due
    uint public dayCounter = 1;

    // Updated when winner is published
    uint public winnerTimestamp;


    uint32 dayDenom = 365 * 200 * 100; // Half day's rewards
    uint32 weekDenom = 365 * 25 * 100; // Full day's rewards plus 6 half day rewards.

    constructor(IWinToken _winTokenAddress) InterfaceImplementation(_winTokenAddress)
    {
        winTokenAddress = _winTokenAddress;
    }

    event winnerChosen(address winner, uint winningAmount);

    // Generate a random number using current blockchain data and a random input.
    // While miners can influece block.timestamp, block.number, the function is a read function
    // And when we run the function is up to us and fairly random. 
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
        winningAmount = isWeekReward() ? getWeeklyWinningAmount() : getDailyWinningAmount(); 
        // Update state variables
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
            if (users[i].stakingStatus && (block.timestamp - users[i].stakeTimestamp >= 1 days)) {
                totalStakingAmount += users[i].stakingAmount;
            }
        }

        // Generate a random number within the range of the cumulative staking amounts
        uint randomNum = generateRandomNumber(totalStakingAmount) % totalStakingAmount;

        // Find the winner by iterating over the users and checking the cumulative staking amounts
        uint cumulativeAmount = 0;
        for (uint i = 0; i < winTokenAddress.getNextTokenID(); i++) {
            if (users[i].stakingStatus && (block.timestamp - users[i].stakeTimestamp >= 1 days)) {
                cumulativeAmount += users[i].stakingAmount;
                if (randomNum <= cumulativeAmount) {
                    return i; // Return the NFT ID of the winner
                }
            }
        }

        revert("No winner found"); // This should never happen if there is at least one eligible user
    }

    // Function to see how much is staked by users, seperated by stakingStatus, and 
    function getTotalStakedAmounts() public view returns (uint, uint, uint) {
        uint totalStakingAmount = 0;
        uint validStakingAmount = 0;
        uint totalUnstaking = 0;

        // Calculate the cumulative staking amounts of users 
        // Only validStakingAmount used in calculating winning amounts
        // Reason being is that new staked amounts don't generate rewards
        // until they are actually staked. Otherwise the winningAmounts
        // can be greater than the rewards generated. 
        for (uint i = 0; i < winTokenAddress.getNextTokenID(); i++) {
            if (!users[i].stakingStatus) {
                totalUnstaking += users[i].stakingAmount; // Incremented when stakingStatus is false
            } else if (block.timestamp - users[i].stakeTimestamp >= 1 days) {
                validStakingAmount += users[i].stakingAmount; // Incremented when stake is older than one day and stakingStatus is true
                totalStakingAmount += users[i].stakingAmount; // Incremented when stakingStatus is true
            } else {
                totalStakingAmount += users[i].stakingAmount; // Incremented when stakingStatus is true
            }
        }
        return (validStakingAmount, totalStakingAmount, totalUnstaking);
    } 

    // Function to get what the daily winning amount is
    function getDailyWinningAmount() public view returns (uint) {
        (uint winningAmount, , ) = getTotalStakedAmounts();
        return calculateDailyWinningAmount(winningAmount);
    }
    // Function to get what the weekly winning amount is
    function getWeeklyWinningAmount() public view returns (uint) {
        (uint winningAmount, , ) = getTotalStakedAmounts();
        return calculateWeeklyWinningAmount(winningAmount);
    } 

    // Function to calculate the amount to distribute daily 
    // Half of a day's generated rewards
    function calculateDailyWinningAmount(uint inputAmount) internal view returns (uint) {
        return (inputAmount * payoutPercent) / (dayDenom); 
    }
     // Function to calculate the amount to distribute daily 
    // Four times a day's generated rewards
    function calculateWeeklyWinningAmount(uint inputAmount) internal view returns (uint) {
        return (inputAmount * payoutPercent) / (weekDenom); 
    } 

    // How long its been since the last draw. Used in random number generator
    // Can be used to automate publishing rewards
    function secondsSinceLastDraw() public view returns (uint) {
        return checkTimestamp(winnerTimestamp); 
    } 

    // Helper function to find the difference between now and a given timestamp
    function checkTimestamp(uint timestamp) internal view returns (uint) {
        return block.timestamp - timestamp;
    }

    // Boolean function to return if the weekly return should be given
    function isWeekReward() public view returns (bool) {
        return (dayCounter % 7) == 0; 
    } 

    // Can be used to change the payout percentage after deployment if neccessary
    function setPayoutPercent(uint _payoutPercent) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SAFETY_ADDRESS, msg.sender), "Wrong Permissions");
        payoutPercent = _payoutPercent;
    }

    // Function to change reward amounts if neccessary.
    function setDenoms(uint32 _dayDenom, uint32 _weekDenom) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SAFETY_ADDRESS, msg.sender), "Wrong Permissions");
        dayDenom = _dayDenom;
        weekDenom = _weekDenom;
    }



}


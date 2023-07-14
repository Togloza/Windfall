// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "./WinToken.sol";
import "./Metadata.sol";

contract CalculateWinners is Metadata {
    Access public access;
    WinToken public wintoken;

    // What percentage staked rewards are given out.
    uint32 private payoutPercent = 800; // 800 = 8%

    // Keep track if weekly reward due
    uint public dayCounter = 1;

    // Updated when winner is published
    uint public winnerTimestamp;

    // Used for daily and weekly winning amounts.
    uint32 private dayDenom;
    uint32 private weekDenom;

    // Variables used for front end past winners.
    uint256[7] internal winningAmounts;
    address[7] internal winningAddresses;

    constructor(address _accessAddress, address _winTokenAddress) {
        access = Access(_accessAddress);
        wintoken = WinToken(_winTokenAddress);

        // A day's rewards should be validStakingAmount * (PayoutPercent / 10000) / daysInYear 
        dayDenom = 365 * 2 * 10000; // Half day's rewards
        weekDenom = 365 * 2500; // Full day's rewards plus 6 half day rewards.
    }

    // Event to emit when publishWinningAddress is called. 
    event winnerChosen(address winner, uint winningAmount);

    // Generate a random number using current blockchain data and a random input.
    // While miners can influece block.timestamp, block.number, the function is a read function
    // And when we run the function is up to us and fairly random.
    function generateRandomNumber(uint256 input) internal view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    secondsSinceLastDraw(),
                    blockhash(block.number - 1), // Use the previous block's hash instead of block.timestamp
                    blockhash(block.number - 2), // Use an older block's hash for additional randomness
                    input
                )
            )
        );
        return randomNumber;
    }

    // Read function to find the winning address and tokenID
    // This function can be called to simulate a winner draw, but doesn't change state. 
    function findWinningNFTAddress() public view returns (address, uint) {
        uint winningID = calculateWinningNFTId();
        address winner = wintoken.ownerOf(winningID);
        return (winner, winningID);
    }

    // Write function to update contract on winner and amount.
    function publishWinningAddress(address winnerAddress) external {
        require(access.hasPublisherRole(msg.sender), "Wrong Permissions");

        uint winningAmount = getWinningAmount();
        // Update state variables
        recordWinningData(winnerAddress, winningAmount);
        emit winnerChosen(winnerAddress, winningAmount);
    }

    // Function to calculate the ID of the winning NFTID.
    // Chances of winning are proportional to the amount staked by the users.
    // Only NFTs with stakingStatus true are counted.
    function calculateWinningNFTId() internal view returns (uint) {
        uint totalStakingAmount = 0;
        uint nextToken = wintoken.getNextTokenId();

        // Calculate the cumulative staking amounts of users with stakingStatus set to true and stake duration greater than 1 day
        for (uint i = 0; i < nextToken; i++) {
            if (users[i].stakingStatus && (block.timestamp - users[i].stakeTimestamp >= 1 days)) {
                totalStakingAmount += users[i].stakingAmount;
            }
        }
        if (totalStakingAmount == 0) {
            revert("No valid stakers");
        }
        // Generate a random number within the range of the cumulative staking amounts
        // The random number will fall within the totalStakingAmount
        uint randomNum = generateRandomNumber(totalStakingAmount) % totalStakingAmount;

        // Find the winner by iterating over the users and checking the cumulative staking amounts
        // Each wei gives the valid staker 1 "entree" into the draw. 
        uint cumulativeAmount = 0;
        for (uint i = 0; i < nextToken; i++) {
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
    function getTotalStakedAmounts() internal view returns (uint, uint, uint) {
        uint totalStakingAmount = 0;
        uint validStakingAmount = 0;
        uint totalUnstaking = 0;

        // Calculate the cumulative staking amounts of users
        // Only validStakingAmount used in calculating winning amounts
        // Reason being is that new staked amounts don't generate rewards
        // until they are actually staked. Otherwise the winningAmounts
        // can be greater than the rewards generated.
        for (uint i = 0; i < wintoken.getNextTokenId(); i++) {
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

    // Function to get results from getTotalStakedAmounts. 
    function getStakedAmounts() public view returns (uint, uint, uint) {
        (uint valid, uint total , uint unstake ) = getTotalStakedAmounts();
        return (valid, total, unstake);
    }

    // Function to get what the daily winning amount is
    function getWinningAmount() public view returns (uint) {
        (uint winningAmount, , ) = getTotalStakedAmounts();
        return calculateWinningAmount(winningAmount);
    }

    // Function to calculate the amount to distribute daily
    // Half of a day's generated rewards
    function calculateWinningAmount(
        uint inputAmount
    ) internal view returns (uint) {
        if (dayCounter % 7 == 0) {
            return (inputAmount * payoutPercent) / (weekDenom);
        } else {
            return (inputAmount * payoutPercent) / (dayDenom);
        }
    }

    function getWiningAmounts() public view returns (uint, uint){
        (uint inputAmount, , ) = getTotalStakedAmounts();
        return ((inputAmount * payoutPercent) / (weekDenom),(inputAmount * payoutPercent) / (dayDenom));
    }

    function recordWinningData(address _address, uint _amount) internal {
        require(_address != address(0) && _amount > 0, "Invalid Entry");
        // Shift the array elements to the right
        for (uint8 i = 6; i > 0; i--) {
            winningAmounts[i] = winningAmounts[i - 1];
            winningAddresses[i] = winningAddresses[i - 1];
        }
        
        winnerRewards[_address] += _amount;
        winnerTimestamp = block.timestamp;
        dayCounter += 1;
        // Add the new entry at the beginning
        winningAmounts[0] = _amount;
        winningAddresses[0] = _address;
    }

    // How long its been since the last draw. Used in random number generator
    // Can be used to automate publishing rewards
    function secondsSinceLastDraw() internal view returns (uint) {
        return checkTimestamp(winnerTimestamp);
    }

    // Helper function to find the difference between now and a given timestamp
    function checkTimestamp(uint timestamp) internal view returns (uint) {
        return block.timestamp - timestamp;
    }

    // Can be used to change the payout percentage after deployment if neccessary
    function setPayoutPercent(uint32 _payoutPercent) external {
        require(access.hasAdminRole(msg.sender) || access.hasSafetyRole(msg.sender), "Wrong Permissions");
        payoutPercent = _payoutPercent;
    }

    // Function to change reward amounts if neccessary.
    function setDenoms(uint32 _dayDenom, uint32 _weekDenom) external {
        require(access.hasAdminRole(msg.sender) || access.hasSafetyRole(msg.sender), "Wrong Permissions");
        dayDenom = _dayDenom;
        weekDenom = _weekDenom;
    }
}

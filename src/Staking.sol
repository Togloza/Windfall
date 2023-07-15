// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "./WinToken.sol";
import "./CalculateWinners.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is CalculateWinners, ReentrancyGuard {
    // Unstake time required by the CANTO network.
    //uint constant UNSTAKE_TIME = 24 days; // 21 days for unstaking on the network, 3 day for admin to unstake
    uint constant UNSTAKE_TIME = 24 days;

    // Used for CSR rewards
    Turnstile immutable turnstile;

    constructor(address _accessAddress, address _winTokenAddress, uint _turnstileTokenId) CalculateWinners(_accessAddress, _winTokenAddress) {
        // Initialize turnstile for CSR and assign rewards to factory contract NFT
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstile.assign(_turnstileTokenId);
    }

    event receivedFunds(address sender, uint _amount);
    event startedUnstaking(uint tokenId, uint unstakingAmount, uint timestamp);
    event depositedTokens(uint depositAmount, address sender, uint timestamp);
    event rewardsClaimed(address winnerAddress, uint rewardAmount);
    event startedStaking(address to, uint tokenId, uint timestamp);
    event tokensWithdrawn(address to, uint amount);

    // Staking function, creates new user, set tokenURI and metadata, and mint NFT to sender.
    function stake() public payable nonReentrant returns (uint) {
        require(msg.value > 0, "Staking 0 tokens");
        // Create a new User struct instance
        User memory newUser = User({
            stakingAmount: msg.value,
            stakingStatus: true,
            stakeTimestamp: block.timestamp,
            unstakeTimestamp: 1 // Set to 1 as init check rather than default
        });

        // Get the next token id from the ERC721 contract
        uint256 tokenId = wintoken.getNextTokenId();

        // Add the new user to the mapping using the NFT Id as the key
        users[tokenId] = newUser;

        // Dynamically generate the Token Metadata
        updateMetadata(tokenId);
        // Mint the token to the sender using the generated URI.
        wintoken.safeMint(msg.sender);
        emit startedStaking(msg.sender, tokenId, newUser.stakeTimestamp);
        return (tokenId);
    }

    // Function checks if the sender is permitted to send the token, and that it isn't already being unstaked.
    // Otherwise, store the unstake time, and set stakingStatus to false.
    // This removes elegibility for calculateWinningNFTId
    function startUnstake(uint tokenId) public {
        require(wintoken.ownerOf(tokenId) == msg.sender, "Not owner of token");
        // If unstakeTimestamp == 0 it wasn't properly initialized.
        if (users[tokenId].unstakeTimestamp == 0) {
            revert("Token unintialized");
        }

        // If already unstaking, revert and send message.
        if (users[tokenId].unstakeTimestamp != 1) {
            revert(
                string(
                    abi.encodePacked(
                        "Unstaking already in process, seconds since unstake: ",
                        Strings.toString(
                            checkTimestamp(users[tokenId].unstakeTimestamp)
                        )
                    )
                )
            );
        }
        // Set unstakeTimestamp to current time, and set stakingStatus to false.
        users[tokenId].unstakeTimestamp = block.timestamp;
        users[tokenId].stakingStatus = false;
        // Update the metadata to reflect the staking status and emit event.
        updateMetadata(tokenId);
        emit startedUnstaking(tokenId, users[tokenId].stakingAmount, block.timestamp);
    }

    // If isValidUnstake and approved, burn the NFT and send stakingAmount to tokenHolder.
    function unstake(uint tokenId) public nonReentrant {
        require(isValidUnstake(tokenId), "Not valid token to unstake");
        require(wintoken.isApproved(address(this), tokenId),"Contract not approved");
        // Find the owner of the token and the staking amount.
        address tokenHolder = wintoken.ownerOf(tokenId);
        uint stakingAmount = users[tokenId].stakingAmount;
        
        require(address(this).balance >= stakingAmount, "Not enough tokens held in contract at the moment");

        // Burn token and transfer funds.
        wintoken.burn(tokenId);

        payable(tokenHolder).transfer(stakingAmount);
    }

    // Function to check whether the token is vaild to unstake.
    // Conditions are the token isn't burned, the stakingStatus is false,
    // And the unstakeTimestamp is greater than or equal to UNSTAKE_TIME
    function isValidUnstake(uint tokenId) internal view returns (bool) {
        if (
            users[tokenId].stakingStatus == false &&
            checkTimestamp(users[tokenId].unstakeTimestamp) >= UNSTAKE_TIME &&
            wintoken.exists(tokenId)
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Function to check the amount needed to start unstaking.
    function recentUnstaking(uint timestamp) external view returns (uint, uint) {
        uint totalAmount = 0;
        for (uint i = 0; i < wintoken.getNextTokenId(); i++) {
            if (users[i].unstakeTimestamp >= timestamp) {
                totalAmount += users[i].stakingAmount;
            }
        }
        return (totalAmount, block.timestamp); // block.timestamp can be used in the next call of the function
    }

    // Function to check the rewards of a given address.
    function checkRewards() public view returns (uint) {
        return winnerRewards[msg.sender];
    }

    // Allows the user to withdraw their rewards.
    function claimRewards() external nonReentrant {
        uint userRewards = checkRewards();
        require(userRewards > 0, "No rewards claimable");
        require(address(this).balance >= userRewards, "Not enough tokens held in contract at the moment");
        // Reset user rewards, send rewards, emit event.
        winnerRewards[msg.sender] = 0;
        payable(msg.sender).transfer(userRewards);
        emit rewardsClaimed(msg.sender, userRewards);
    }

    // Function used to retrieve data of past winners for the front end. 
    function retrievePastData() external view returns (address[7] memory, uint[7] memory){
        return (winningAddresses, winningAmounts);
    }

    // Function to withdraw tokens. Since automatic staking/unstaking to node not currently possible,
    // Have to withdraw the tokens manually before staking.
    function withdrawTokens(uint _amount) external nonReentrant{
        require(access.hasAdminRole(msg.sender) || access.hasSafetyRole(msg.sender), "Wrong Permissions");
        require(address(this).balance >= _amount, "Not enough tokens in contract");

        payable(msg.sender).transfer(_amount);
        emit tokensWithdrawn(msg.sender, _amount);
    }

    // Function to deposit tokens into the contract as failsafe.
    function depositTokens() external payable {
        emit depositedTokens(msg.value, msg.sender, block.timestamp);
    }

    // Function to return balance of this address.
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // If the contract receives eth emit event.
    receive() external payable {
        emit receivedFunds(msg.sender, msg.value);
    }
}

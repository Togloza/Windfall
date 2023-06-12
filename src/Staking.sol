// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./WinnerCalculator.sol";
 
/* UNCOMMENT FOR TURNSTILE REWARDS
interface Turnstile {
function assign(uint256 _tokenId) external returns (uint256);
} 
*/

contract Staking is WinnerCalculator {
    /*///////////////////////////////////////////////////////////////
                        Global Variables
    //////////////////////////////////////////////////////////////*/
    // Turnstile required for CSR rewards
    /* UNCOMMENT FOR TURNSTILE REWARDS
    Turnstile immutable turnstile;
    */
 
    // Unstake time required by the CANTO network.
    //uint constant UNSTAKE_TIME = 21 days;
    uint constant UNSTAKE_TIME = 5 minutes;
    // Owner's address. 
    address private _owner;

    // Mapping tokenID to when users started to unstake
    mapping(uint => uint) public unstakeTimestamp;


    

    /*///////////////////////////////////////////////////////////////
                        Constructor
    //////////////////////////////////////////////////////////////*/
    constructor(IWinToken winTokenAddress) WinnerCalculator(winTokenAddress) {
        
        // Required for CSR rewards
        /* UNCOMMENT FOR TURNSTILE REWARDS
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstile.assign(csrTokenID);
        */
    
    } 

    /*///////////////////////////////////////////////////////////////
                                Events
    //////////////////////////////////////////////////////////////*/

    event receivedFunds(address sender, uint _amount);
    event startedUnstaking(uint tokenID, uint unstakingAmount, uint timestamp);
    event depositedTokens(uint depositAmount, address sender, uint timestamp);
    event rewardsClaimed(address winnerAddress, uint rewardAmount);


    /*///////////////////////////////////////////////////////////////
                        Main Functions
        -----------------------------------------------------
                        Staking Logic
    //////////////////////////////////////////////////////////////*/

    // Staking function, creates new user, set tokenURI and metadata, and mint NFT to sender.
    function stake() public payable {
        require(msg.value >= 0, "Staking 0 tokens");
        // Create a new User struct instance
        User memory newUser = User({
            stakingAmount: msg.value,
            stakingStatus: true
        });

        // Add the new user to the mapping using the NFT ID as the key
        users[winTokenAddress.getNextTokenID()] = newUser;

        // Get the next token id from the ERC721 contract
        uint256 tokenID = winTokenAddress.getNextTokenID();
        // Dynamically generate the URI data
        setTokenURI(tokenID);
        updateMetadata(tokenID);
        // Mint the token to the sender using the generated URI.
        winTokenAddress.MintTo(msg.sender, tokenURIs[tokenID]);
    } 

    // Function checks if the sender is permitted to send the token, and that it isn't already being unstaked.
    // Otherwise, store the unstake time, and set stakingStatus to false.
    // This removes elegibility for calculateWinningNFTID
    function startUnstake(uint tokenID) public {
        require(winTokenAddress.OwnerOf(tokenID) == msg.sender, "Not owner of token");
        // If already unstaking, revert and send message.
        if (unstakeTimestamp[tokenID] != 0) {
            revert(
                string(
                    abi.encodePacked(
                        "Unstaking already in process, seconds since unstake: ",
                        uint256ToString(checkTimestamp(unstakeTimestamp[tokenID]))
                    )
                )
            );
        }
        // Set unstakeTimestamp to current time, and set stakingStatus to false.
        unstakeTimestamp[tokenID] = block.timestamp;
        users[tokenID].stakingStatus = false;
        // Update the metadata to reflect the staking status and emit event.
        updateMetadata(tokenID); 
        emit startedUnstaking(tokenID, users[tokenID].stakingAmount, block.timestamp);
    }



    // If isValidUnstake and approved, burn the NFT and send stakingAmount to tokenHolder.
    function Unstake(uint tokenID) public {
        require(isValidUnstake(tokenID), "Not valid token to unstake");
        require(winTokenAddress.isApproved(address(this), tokenID), "Contract not approved");
        // Find the owner of the token 
        address tokenHolder = winTokenAddress.OwnerOf(tokenID);
        uint stakingAmount = users[tokenID].stakingAmount;

        require(address(this).balance >= stakingAmount, "Not enough tokens held in contract at the moment");
        // winTokenAddress.proxyApproval(address(this), tokenID); Approval required in front end
        // Burn token and transfer funds.
        winTokenAddress.Burn(tokenID); 
         
        payable(tokenHolder).transfer(stakingAmount);
    }

        // Calculate how much is staked and in the process of unstaking
    function checkValidUnstaking() external view returns (uint[] memory, uint[] memory, uint[] memory) {
        uint nextTokenID = winTokenAddress.getNextTokenID();
        uint[] memory storeID = new uint[](nextTokenID);
        uint[] memory storeAmounts = new uint[](nextTokenID);
        uint[] memory storeUnstakeTimestamp = new uint[](nextTokenID);
        uint count = 0; // Counter for non-zero values

        for (uint i = 0; i < nextTokenID; i++) {
            if (isValidUnstake(i)) {
                storeID[count] = i;
                storeAmounts[count] = users[i].stakingAmount;
                count++;
            }
            storeUnstakeTimestamp[i] = unstakeTimestamp[i];
        }

        // Create new arrays with only non-zero values
        uint[] memory nonZeroStoreID = new uint[](count);
        uint[] memory nonZeroStoreAmounts = new uint[](count);
        for (uint j = 0; j < count; j++) {
            nonZeroStoreID[j] = storeID[j];
            nonZeroStoreAmounts[j] = storeAmounts[j];
        }

        return (nonZeroStoreID, nonZeroStoreAmounts, storeUnstakeTimestamp);
    }

    
    /*///////////////////////////////////////////////////////////////
                        Main Functions
        -----------------------------------------------------
                        Reward Functions
    //////////////////////////////////////////////////////////////*/

    function checkRewards() public view returns (uint){
        return winnerRewards[msg.sender]; 
    }

    function claimRewards() public {
        uint userRewards = checkRewards();
        require(userRewards >= 0, "No rewards claimable");
        // Reset user rewards, send rewards, emit event.
        winnerRewards[msg.sender] = 0;
        assert(totalRewards >= userRewards);
        totalRewards -= userRewards;
        payable(msg.sender).transfer(userRewards);
        emit rewardsClaimed(msg.sender, userRewards);
    }


    /*///////////////////////////////////////////////////////////////
                        Helper Functions
        -----------------------------------------------------
                        Validation Functions
    //////////////////////////////////////////////////////////////*/
 
    function isValidUnstake(uint tokenID) internal view returns (bool) {
        bool[] memory burnedTokens = winTokenAddress.getBurnedTokens();

        if (
            users[tokenID].stakingStatus == false &&
            checkTimestamp(unstakeTimestamp[tokenID]) >= UNSTAKE_TIME &&
            burnedTokens[tokenID] == false
        ) {
            return true;
        } else {
            return false;
        }
    }

    /*///////////////////////////////////////////////////////////////
                         Helper Functions
        -----------------------------------------------------
                         Getter Functions
    //////////////////////////////////////////////////////////////*/


    function getContractBalance() external view returns (uint){
        return address(this).balance;
    }

    /*///////////////////////////////////////////////////////////////
                         Helper Functions
        -----------------------------------------------------
                         Utility Functions
    //////////////////////////////////////////////////////////////*/

    // Function to withdraw tokens in case tokens are locked in the contract.
    function WithdrawTokens(uint _amount) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SAFETY_ADDRESS, msg.sender));
        require(address(this).balance >= _amount, "Not enough tokens in contract");

        payable(msg.sender).transfer(_amount);
    }

    function DepositTokens() external payable {
        emit depositedTokens(msg.value, msg.sender, block.timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                            Contract Functions
    //////////////////////////////////////////////////////////////*/

    // If the contract receives eth with transfer, send to owner and emit event.
    receive() external payable {
        emit receivedFunds(msg.sender, msg.value);
    }
}

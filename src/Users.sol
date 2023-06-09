// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract Users {
    
    // Total Rewards in contract
    uint public totalRewards;

    // Keep track of claimable rewards for the winners
    mapping(address => uint) public winnerRewards;


    struct User {  
        uint stakingAmount;
        bool stakingStatus;
        uint initialTimestamp; // Currently unused, but may implement in the future.
    }

    mapping(uint => User) public users;


    function getUserByNFTID(uint _tokenID) public view returns (User memory) {
        User memory user = users[_tokenID];
        return user;
    }

    function getStatusByNFTID(uint _tokenID) public view returns (bool){
        return users[_tokenID].stakingStatus;
    }

    function getAmountByNFTID(uint _tokenID) public view returns (uint){
        return users[_tokenID].stakingAmount;
    }

}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract Users {
    
    // Total Rewards in contract, incremented in derivative contracts
    // Only real use is to display on front end.
    uint public totalRewards;

    // Keep track of claimable rewards for the winners
    // Maybe used in metadata contract, so kept in Users contract.
    mapping(address => uint) public winnerRewards;

    // Holds data needed for every token, can be expanded if needed.
    struct User {  
        uint stakingAmount;
        bool stakingStatus;
        uint stakeTimestamp;
        uint unstakeTimestamp;
    }

    // Map the tokenID to the user struct.
    mapping(uint => User) public users;

    // Getter functions for the user struct using the users mapping.
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

    function getStakeTimestampByNFTID(uint _tokenID) public view returns (uint) {
        return users[_tokenID].stakeTimestamp;
    }

    function getUnstakeTimestampByNFTID(uint _tokenID) public view returns (uint) {
        return users[_tokenID].unstakeTimestamp;
    }

}
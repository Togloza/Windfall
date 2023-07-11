// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

contract Users {
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

    // Map the tokenId to the user struct.
    mapping(uint => User) public users;

    // Getter functions for the user struct using the users mapping.
    function getUserByNFTId(uint _tokenId) public view returns (User memory) {
        return users[_tokenId];
    }

    function getAmountByNFTId(uint _tokenId) public view returns (uint) {
        return users[_tokenId].stakingAmount;
    }

    function getStatusByNFTId(uint _tokenId) public view returns (bool) {
        return users[_tokenId].stakingStatus;
    }

    function getStakeTimestampByNFTId(uint _tokenId) public view returns (uint) {
        return users[_tokenId].stakeTimestamp;
    }

    function getUnstakeTimestampByNFTId(uint _tokenId) public view returns (uint) {
        return users[_tokenId].unstakeTimestamp;
    }
}

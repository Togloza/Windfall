// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// Import relevant contracts
import "./Users.sol";
import "./TypeConversion.sol";


contract Metadata is Users, TypeConversion {
    // Track the metadata for each tokenId
    mapping(uint => string) public metadata;

    function getMetadata(uint tokenId) public view returns (string memory) {
        return metadata[tokenId];
    }

    // This function updates the metadata for changes in the user struct. 
    function updateMetadata(uint tokenId) internal {
        User memory user = getUserByNFTId(tokenId);
        string memory imageURL = user.stakingStatus ? "StakingImageURL" : "UnstakingImageURL";
        // Construct the metadata JSON object
        metadata[tokenId] = string(
            abi.encodePacked(
                "{",
                '"image": "',
                imageURL,
                '",',
                '"stakingAmount": "',
                uint256ToString(user.stakingAmount),
                '",',
                '"stakingStatus": "',
                boolToString(user.stakingStatus),
                '",',
                '"stakeTimestamp": "',
                uint256ToString(user.stakeTimestamp),
                '",',
                '"unstakeTimestamp": "',
                uint256ToString(user.unstakeTimestamp),
                '",',
                "}"
            )
        ); 

    }
}
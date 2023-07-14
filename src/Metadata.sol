// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// Import relevant contracts
import "./Users.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract Metadata is Users {
    // Track the metadata for each tokenId
    mapping(uint => string) public metadata;

    function getMetadata(uint tokenId) public view returns (string memory) {
        return metadata[tokenId];
    }

    // Function to construct the attributes string
    // Stack depth error when included in updateMetadata function
    function constructAttributes(User memory user) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{ "trait_type": "stakingAmount", "value": "',
                    Strings.toString(user.stakingAmount),
                    '" },',
                    '{ "trait_type": "stakingStatus", "value": "',
                    user.stakingStatus ? "true" : "false",
                    '" },',
                    '{ "trait_type": "stakeTimestamp", "value": "',
                    Strings.toString(user.stakeTimestamp),
                    '" },',
                    '{ "trait_type": "unstakeTimestamp", "value": "',
                    Strings.toString(user.unstakeTimestamp),
                    '" }'
                )
            );
    }

    // Updated updateMetadata function
    function updateMetadata(uint tokenId) internal {
        User memory user = getUserByNFTId(tokenId);
        string memory attributes = constructAttributes(user);

        metadata[tokenId] = string(
            abi.encodePacked(
                "{",
                '"image": "',
                getStatusByNFTId(tokenId)
                    ? "https://storage.googleapis.com/windfall-wintoken/windfall-images/Staking350.png"
                    : "https://storage.googleapis.com/windfall-wintoken/windfall-images/Staking350.png",
                '",',
                '"attributes": [',
                attributes,
                "],",
                "}"
            )
        );
    }
}

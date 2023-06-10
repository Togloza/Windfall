// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// Import relevant contracts
import "./Users.sol";
import "./TypeConversion.sol";
import "./Access.sol";


contract Metadata is Users, TypeConversion, Access {
    mapping(uint => string) public tokenURIs;
    mapping(uint => string) public metadata;
    string public baseURI = "https://example.com/api/token/";

 
    function setBaseURI(string memory newURI) external {
            baseURI = newURI;
    } 
    function setTokenURI(uint256 tokenID) external {

        // Set the token's metadata URI
        string memory tokenURI = string(
            abi.encodePacked(baseURI, uint256ToString(tokenID))
        );
        tokenURIs[tokenID] = tokenURI;

        // Store the metadata
        //_setTokenURI(tokenID, metadata);
    }

    function getMetadata(uint tokenID) public view returns (string memory) {
        return metadata[tokenID];
    }

    // This function updates the metadata for changes in the user struct. 
    function updateMetadata(uint tokenID) external {
        User memory user = getUserByNFTID(tokenID);
        // Convert the struct values to string
        string memory stakingAmountStr = uint256ToString(user.stakingAmount);
        string memory stakingStatusStr = boolToString(user.stakingStatus);
        string memory initialTimestampStr = uint256ToString(user.initialTimestamp);

        // Construct the metadata JSON object
        metadata[tokenID] = string(
            abi.encodePacked(
                "{",
                '"stakingAmount": "',
                stakingAmountStr,
                '",',
                '"stakingStatus": "',
                stakingStatusStr,
                '",',
                '"initialTimestamp": "',
                initialTimestampStr,
                '"',
                "}"
            )
        ); 

    }
}
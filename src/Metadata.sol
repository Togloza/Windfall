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

 
    function setBaseURI(string memory newURI) public {
            require(highLevelPerms(msg.sender), "Insufficient Permissions");
            baseURI = newURI;
    } 

    function getMetadata(uint tokenID) public view returns (string memory) {
        return metadata[tokenID];
    }

    function setTokenURI(uint256 tokenID) internal {

        // Set the token's metadata URI
        string memory tokenURI = string(
            abi.encodePacked(baseURI, uint256ToString(tokenID))
        );
        tokenURIs[tokenID] = tokenURI;

        // Store the metadata
        //_setTokenURI(tokenID, metadata);
    }

    // This function updates the metadata for changes in the user struct. 
    function updateMetadata(uint tokenID) internal {
        User memory user = getUserByNFTID(tokenID);
       

        // Construct the metadata JSON object
        metadata[tokenID] = string(
            abi.encodePacked(
                "{",
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
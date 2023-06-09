// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;


import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract Access is Permissions {

    bytes32 public constant MINTER = keccak256("MINTER_ROLE");
    bytes32 public constant SAFETY_ADDRESS = keccak256("SAFETY_ADDRESS_ROLE");
    bytes32 public constant PUBLISHER = keccak256("PUBLISHER_ROLE");

    constructor()
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function giveMintRole(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        grantRole(MINTER, contractAddress);
    }

    function giveSafteyRole(address walletAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(SAFETY_ADDRESS, walletAddress);
    }

    function givePublisherRole(address walletAddress) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SAFETY_ADDRESS, msg.sender));
        grantRole(PUBLISHER, walletAddress);
    }
}
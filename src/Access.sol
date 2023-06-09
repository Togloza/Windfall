// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract Access is Permissions {
    bytes32 public constant MINTER = keccak256("MINTER_ROLE");
    bytes32 public constant SAFETY_ADDRESS = keccak256("SAFETY_ADDRESS_ROLE");
    bytes32 public constant PUBLISHER = keccak256("PUBLISHER_ROLE");
    bytes32 public constant FACTORY = keccak256("FACTORY_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _setupRole(FACTORY, msg.sender);
    }
    

    function giveMintRole(address contractAddress) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
            hasRole(SAFETY_ADDRESS, msg.sender) ||
            hasRole(FACTORY, msg.sender),
            "Wrong Permissions"
        );
        grantRole(MINTER, contractAddress);
    }

    function giveSafetyRole(address walletAddress) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
            hasRole(FACTORY, msg.sender),
            "Wrong Permissions"
        );
        grantRole(SAFETY_ADDRESS, walletAddress);
    }

    function givePublisherRole(address walletAddress) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(SAFETY_ADDRESS, msg.sender) ||
                hasRole(FACTORY, msg.sender),
            "Wrong Permissions"
        );
        grantRole(PUBLISHER, walletAddress);
    }
}
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

    function highLevelPerms(address checkAddress) internal view returns (bool){
        return (
            hasRole(DEFAULT_ADMIN_ROLE, checkAddress) ||
            hasRole(SAFETY_ADDRESS, checkAddress) ||
            hasRole(FACTORY, checkAddress)
            );
    }
    

    function giveMintRole(address contractAddress) external {
        require(highLevelPerms(msg.sender), "Insufficient Permissions");
        grantRole(MINTER, contractAddress);
    }

    function giveSafetyRole(address walletAddress) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Insufficient Permissions");
        grantRole(SAFETY_ADDRESS, walletAddress);
    }

    function givePublisherRole(address walletAddress) external {
        require(highLevelPerms(msg.sender), "Insufficient Permissions");
        grantRole(PUBLISHER, walletAddress);
    }

    function checkRole(address checkAddress, bytes32 role) public view returns (bool) {
        return hasRole(role, checkAddress);
    }


}
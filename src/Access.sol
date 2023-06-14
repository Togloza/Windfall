// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/Permissions.sol";


contract Access is Permissions {
    // Roles
    bytes32 public constant MINTER = keccak256("MINTER_ROLE");
    bytes32 public constant SAFETY_ADDRESS = keccak256("SAFETY_ADDRESS_ROLE");
    bytes32 public constant PUBLISHER = keccak256("PUBLISHER_ROLE");
    bytes32 public constant FACTORY = keccak256("FACTORY_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin); // If deployed through a factory, deployer gets admin perms
        _setupRole(FACTORY, msg.sender);
    }

    function hasPublisherPerms(address checkAddress) public view returns (bool){
        return (hasRole(PUBLISHER, checkAddress));
    }
    function highLevelPerms(address checkAddress) public view returns (bool){
        return (
            hasRole(DEFAULT_ADMIN_ROLE, checkAddress) ||
            hasRole(SAFETY_ADDRESS, checkAddress) ||
            hasRole(FACTORY, checkAddress)
            );
    }
    

    function checkRole(address checkAddress, bytes32 role) public view returns (bool) {
        return hasRole(role, checkAddress);
    }


}
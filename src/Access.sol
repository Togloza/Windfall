// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";

contract Access is AccessControl {
    // Roles
    bytes32 public constant SAFETY_ADDRESS = keccak256("SAFETY_ADDRESS_ROLE");
    bytes32 public constant MINTER = keccak256("MINTER_ROLE");
    bytes32 public constant PUBLISHER = keccak256("PUBLISHER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
    }

    function getMinterRole() external pure returns (bytes32) {
        return MINTER;
    }

    function hasAdminRole(address checkAdmin) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, checkAdmin);
    }

    function hasSafetyRole(address checkSafety) external view returns (bool) {
        return hasRole(SAFETY_ADDRESS, checkSafety);
    }

    function hasPublisherRole(address checkPublisher) external view returns (bool) {
        return hasRole(PUBLISHER, checkPublisher);
    }

    function hasMinterRole(address checkMinter) external view returns (bool) {
        return hasRole(MINTER, checkMinter);
    }
}

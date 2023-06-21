// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Staking.sol";
import "../src/WindfallFactory.sol";
import "../src/WinToken.sol";
import "../src/Access.sol";

contract WindfallTest is Test {

    WindfallFactory public factory;
    Access public access;
    WinToken public wintoken;
    Staking public staking;

    function setUp() public {
        factory = new WindfallFactory();
        access = Access(factory.access());
        wintoken = WinToken(factory.wintoken());
        staking = Staking(factory.staking());
    }




}

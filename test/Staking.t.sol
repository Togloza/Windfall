// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Staking.sol";
import "../src/WindfallFactory.sol";
import "../src/WinToken.sol";

contract WindfallTest is Test {

    WindfallFactory public factory;
    WinToken public winToken;
    Staking public staking;

    function setUp() public {
        factory = new WindfallFactory("Test", "T", 0x0445fb4f68A65c442FaaCc8679Db371217A2100B, 300);
        winToken = factory.winToken();
        staking = factory.staking();
        console.log("Factory Address", address(factory));
        console.log("Token Address", address(winToken));
        console.log("Staking Address", address(staking));

    }



    function testInit() public view {
        assert(address(factory) != address(0));
        assert(address(winToken) != address(0));
        assert(address(staking) != address(0));
    }
/*
    function testRoles() public {
        
    }

    function _send(uint256 amount) internal {
        (bool ok,) = address(staking).call{value: amount}(abi.encodeWithSignature("stake()"));
        require(ok, "send ETH failed");
    }
    function testStake() public {
        hoax(address(1), 100);
        uint256 stakeAmount = 1 ether;
        //_send(stakeAmount);
        
        
    }
*/
}

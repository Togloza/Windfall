// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

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

    address contractDeployer = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38; 


    function setUp() public {
        vm.startPrank(contractDeployer);
        factory = new WindfallFactory();
        access = Access(factory.access());
        wintoken = WinToken(factory.wintoken());
        staking = Staking(factory.staking());
        access.grantRole(access.getMinterRole(), address(staking));
        vm.stopPrank();
    }

    function testInit() public {
        assertTrue(access.hasRole(access.MINTER(), address(staking)));
    }
/*
    function testPermissionRestrictions() public {
        address randomUser = address(0x0aa);

        vm.prank(randomUser);
        vm.expectRevert(bytes("Wrong Permissions"));
        staking.WithdrawTokens(1000);

        vm.prank(randomUser);
        vm.expectRevert(bytes("Wrong Permissions"));
        staking.publishWinningAddress(randomUser);

        vm.prank(randomUser);
        vm.expectRevert(bytes("Wrong Permissions"));
        factory.publishWinner();

        vm.prank(randomUser);
        vm.expectRevert(bytes("Wrong Permissions"));
        staking.setPayoutPercent(1000); 

        vm.prank(randomUser);
        vm.expectRevert(bytes("Wrong Permissions"));
        staking.setDenoms(1000, 5000);

    }

    function testWithdraw() public {
        uint funds = 1000;
        hoax(contractDeployer);
        staking.DepositTokens{value: funds}();

        vm.prank(contractDeployer);
        vm.expectRevert(bytes("Not enough tokens in contract"));
        staking.WithdrawTokens(2*funds);

    }
    */
 
    function testStaking() public {
        assertTrue(access.hasRole(access.MINTER(), address(staking)));
        address randomUser = address(0x0ab);
        uint amount = 1000;
        console.log(address(staking).balance);
        hoax(randomUser, 3000);
        staking.stake{value: amount}();
        
        console.log(randomUser.balance);
    
        console.log(address(staking).balance);
        
    }

     function testTokenMintedToStakerAddress() public {
        address randomUser = address(0x0ab);
        uint amount = 1000;
        hoax(randomUser, 3000);
        staking.stake{value: amount}();

        uint256 tokenId = wintoken.getNextTokenId() - 1;
        address tokenOwner = wintoken.ownerOf(tokenId);

        assertEq(tokenOwner, randomUser, "Token was not minted to the staker's address");
    }



}

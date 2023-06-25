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
    

   function updateBalances(address _contract, address _user) internal view returns (uint, uint){
        return(_contract.balance, _user.balance);
   }
 
    function testStaking(uint256 amount) public {

        address randomUser = address(0x0ab);

        hoax(randomUser, amount);

        (uint contractBalanceBefore, uint userBalanceBefore) = updateBalances(address(staking), randomUser);
        staking.stake{value: amount}();
        (uint contractBalanceAfter, uint userBalanceAfter) = updateBalances(address(staking), randomUser);

        assertEq(contractBalanceAfter - contractBalanceBefore, amount);
        assertEq(userBalanceBefore - userBalanceAfter, amount);

        uint256 tokenId = wintoken.getNextTokenId() - 1;
        address tokenOwner = wintoken.ownerOf(tokenId);

        assertEq(tokenOwner, randomUser, "Token was not minted to the staker's address");
        
        string memory tokenMetadata = staking.getMetadata(tokenId);
    }
*/
    function testBasicStakingLifetime() public {

        
        address ALICE = address(0x0ac);
        address BOB = address(0x0ad);
        address MALICIOUS = address(0x0ff);

        // Alice and bob start staking
        hoax(ALICE, 100e18);
        uint aliceToken = staking.stake{value: 60e18}();
        hoax(BOB, 100e18);
        uint bobToken = staking.stake{value: 10e18}();

        // Malicious account creates 2 tokens and fails to create third
        vm.startPrank(MALICIOUS);
        deal(MALICIOUS, 100e18);
        uint malTokenOne = staking.stake{value: 20e18}();
        uint malTokenTwo = staking.stake{value: 30e18}();
        vm.expectRevert(bytes("Staking 0 tokens"));
        uint malTokenThree = staking.stake{value: 0}();
        vm.stopPrank();          

        // Ownership of tokens is working properly
        assertTrue(wintoken.ownerOf(aliceToken) == ALICE);
        assertTrue(wintoken.ownerOf(bobToken) == BOB);
        assertTrue(wintoken.ownerOf(malTokenOne) == MALICIOUS);
        assertFalse(wintoken.ownerOf(bobToken) == MALICIOUS);

        // Malicious account tries to unstake other's tokens
        // Malicious account tries to unstake non-existing token
        // Malicious account tries to claim non-existant rewards
        vm.prank(MALICIOUS);
        vm.expectRevert(bytes("Not owner of token"));
        staking.startUnstake(bobToken);
        vm.startPrank(MALICIOUS);
        vm.expectRevert(bytes("Not owner of token"));
        staking.startUnstake(aliceToken);
        vm.expectRevert(bytes("ERC721: invalid token ID"));
        staking.startUnstake(666); // Token should not exist
        vm.expectRevert(bytes("No rewards claimable"));
        staking.claimRewards();




        vm.warp(600); // 10 minutes pass
        vm.roll(100); // canto block time is ~6 seconds
        
        // Carl and olivia start staking
        address CARL = address(0x0ae);
        address OLIVIA = address(0x0af);

        hoax(CARL, 100e18);
        uint carlToken = staking.stake{value: 100e18}();
        hoax(OLIVIA, 100e18);
        uint oliviaToken = staking.stake{value: 30e18}();

        assertTrue(wintoken.ownerOf(carlToken) == CARL);
        assertTrue(wintoken.ownerOf(oliviaToken) == OLIVIA);
    }

    function testFunctions() public {

    }



}

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

    uint totalStakingAmount = 0;

    function setUp() public {
        vm.startPrank(contractDeployer);
        factory = new WindfallFactory(contractDeployer);
        access = Access(factory.access());
        wintoken = WinToken(factory.wintoken());
        staking = Staking(factory.staking());
        access.grantRole(access.getMinterRole(), address(staking));
        access.grantRole(access.PUBLISHER(), contractDeployer);
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

        uint aliceToken = createUser(ALICE, 60e18);
        uint bobToken = createUser(BOB, 40e18);

        // Malicious account creates 2 tokens and fails to create third
        uint malTokenOne = createUser(MALICIOUS, 20e18);
        uint malTokenTwo = createUser(MALICIOUS, 30e18);
        vm.expectRevert(bytes("Staking 0 tokens"));
        uint malTokenThree = createUser(MALICIOUS, 0);

        // Ownership of tokens is working properly
        assertTrue(wintoken.ownerOf(aliceToken) == ALICE);
        assertTrue(wintoken.ownerOf(bobToken) == BOB);
        assertTrue(wintoken.ownerOf(malTokenOne) == MALICIOUS);
        assertFalse(wintoken.ownerOf(bobToken) == MALICIOUS);

        // Malicious account tries to unstake other's tokens
        // Malicious account tries to unstake non-existing token
        // Malicious account tries to claim non-existant rewards
        vm.startPrank(MALICIOUS);
        vm.expectRevert(bytes("Not owner of token"));
        staking.startUnstake(bobToken);
        vm.expectRevert(bytes("Not owner of token"));
        staking.startUnstake(aliceToken);
        vm.expectRevert(bytes("ERC721: invalid token ID"));
        staking.startUnstake(666); // Token should not exist
        vm.expectRevert(bytes("No rewards claimable"));
        staking.claimRewards();
        vm.stopPrank();

        // To be a vaild staker have to exceed certain staking time
        // Which is not yet achieved at this point
        vm.expectRevert(bytes("No valid stakers"));
        pickWinner();

        progressTime(600); // Enough time to start unstaking, not enough to win rewards

        // To be a vaild staker have to exceed certain staking time
        // Which is not yet achieved at this point
        vm.expectRevert(bytes("No valid stakers"));
        pickWinner();

        progressTime(96400); // Enough time for stakers to start winning

        // Carl and olivia start staking
        address CARL = address(0x0ae);
        address OLIVIA = address(0x0af);

        uint carlToken = createUser(CARL, 100e18);
        uint oliviaToken = createUser(OLIVIA, 50e18);

        assertTrue(wintoken.ownerOf(carlToken) == CARL);
        assertTrue(wintoken.ownerOf(oliviaToken) == OLIVIA);
/*
        assertEq(
            staking.getWinningAmount(),
            (staking.getValidStakedAmounts() * 800) / (365 * 2 * 10000)
        );

        */
    }

    function createUser(address _user, uint amount) internal returns (uint) {
        hoax(_user, 100e18);
        totalStakingAmount += amount;
        return staking.stake{value: amount}();
    }

    //    function checkMetadataAmount(uint tokenId) internal view returns(uint) {
    //        return staking.getMetadata(tokenId);
    //    }

    function progressTime(uint timeSeconds) internal {
        vm.warp(timeSeconds);
        vm.roll(6 * timeSeconds); // canto block time is ~6 seconds
    }

    function pickWinner() internal {
        vm.prank(contractDeployer);
        factory.publishWinner();
    }

    function testFunctions(uint tokenId) internal view {
        console.log(staking.getMetadata(tokenId));
    }
}

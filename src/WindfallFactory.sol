// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "./Access.sol";
import "./WinToken.sol";
import "./Staking.sol";

/*
ACCESS: 0xc9eC7C74B3227a64Cc9C93b0d6C3f48D116CdFA2
STAKING: 0xa7F2a8374eBa1666E7802EEEAFaa214972D25eba
WINTOKEN: 0xF3692D172d1105e01512EcEEEe5E2a6d4601adC4
*/

contract WindfallFactory {
    Access public access;
    WinToken public wintoken;
    Staking public staking;

    Turnstile immutable turnstile;
    uint public immutable turnstileTokenId;

    address public csrRewardWallet;

    // Roles must be granted by deployer after deployment.
    // Staking contract needs MINTER role to function.
    // Also wintoken's setBaseURI should be called if not changed in wintoken contract code.
    // Better to do this manually than give factory contract admin permissions even temporarily for security concerns.
    constructor(address _csrRewardWallet) {

        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstileTokenId = turnstile.register(msg.sender);
        csrRewardWallet = _csrRewardWallet;

        access = new Access();
        wintoken = new WinToken(address(access), turnstileTokenId);
        staking = new Staking(address(access), address(wintoken), turnstileTokenId);
    }

    // See Staking recentUnstaking
    function recentUnstakingDay() external view returns (uint, uint) {
        return staking.recentUnstaking(block.timestamp - 1 days);
    }

    // See Staking getStakingContractBalance
    function getStakingContractBalance() public view returns (uint) {
        return staking.getContractBalance();
    }

    // See WinnerCalculator publishWinningAddress
    function publishWinner() external {
        require(access.hasPublisherRole(msg.sender), "Wrong Permissions");
        (address winnerAddress, ) = staking.findWinningNFTAddress();
        staking.publishWinningAddress(winnerAddress);
    }


    event csrWithdrawn(uint csrBalance);

 
    // Withdraw CSR rewards to the contract

 
    function WithdrawCSR() external payable {
        require (access.hasAdminRole(msg.sender) || csrRewardWallet == msg.sender, "Restricted Access");
        uint csrBalance = turnstile.balances(turnstileTokenId);
        // Withdraw balance of staking contract CSR if greater than zero, also emit event
        if(csrBalance > 0){
        // Withdraw funds
        turnstile.withdraw(turnstileTokenId, payable(csrRewardWallet), csrBalance); 
        
        emit csrWithdrawn(csrBalance);
        } 
 
    }

    // See current CSR rewards unclaimed
    function CheckCSR() external view returns (uint) {
        return turnstile.balances(turnstileTokenId);
    }
}

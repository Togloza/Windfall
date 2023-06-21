// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "./Access.sol";
import "./WinToken.sol";
import "./Staking.sol";

contract WindfallFactory {
    Access public access;
    WinToken public wintoken;
    Staking public staking;

        // Roles must be granted by deployer after deployment. 
        // Staking contract needs MINTER role to function.
        // Also wintoken's setBaseURI should be called if not changed in wintoken contract code.
        // Better to do this manually than give factory contract admin permissions even temporarily for security concerns.
    constructor() {
        access = new Access();
        wintoken = new WinToken(address(access));
        staking = new Staking(address(access), address(wintoken));
    }

        // See Staking recentUnstaking
    function recentUnstakingDay() external view returns(uint, uint) {
        return staking.recentUnstaking(block.timestamp - 1 days);
    }

        // See Staking getStakingContractBalance
    function getStakingContractBalance() public view returns (uint){
        return staking.getContractBalance();
    }

    
    // See WinnerCalculator publishWinningAddress
    function publishWinner() external  {
        require(access.hasPublisherRole(msg.sender));
        (address winnerAddress, ) = staking.findWinningNFTAddress();
        staking.publishWinningAddress(winnerAddress);
    }


}
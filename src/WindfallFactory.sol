// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;


import "./WinToken.sol";
import "./WinnerCalculator.sol";
import "./Staking.sol";
import "./Access.sol";


contract WindfallFactory {


    WinToken public winToken;
    IWinToken public tokenContract;
    WinnerCalculator public winnerCalculator;
    Staking public staking;
    Access public access;


    

    constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    ) 
    {
        winToken = new WinToken(_name, _symbol, _royaltyRecipient, _royaltyBps);
        tokenContract = IWinToken(winToken);
        winnerCalculator = new WinnerCalculator(tokenContract);
        staking = new Staking(tokenContract);

        access = new Access();
        access.giveMintRole(address(staking));
        
        
        
    }

    function isReadyToDraw() public view returns (bool) {
        return winnerCalculator.isReadyToDraw();
    }

    function isWeekReward() public view returns (bool) {
        return winnerCalculator.isWeekReward();
    }
    
    function publishWinner() public {
        (address winnerAddress, ) = winnerCalculator.findWinningNFTAddress();
        winnerCalculator.publishWinningAddress(winnerAddress);
    }



    function getStakingContractBalance() public view returns (uint){
        return staking.getContractBalance();
    }
    

}
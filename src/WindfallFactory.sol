// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;


import "./WinToken.sol";
import "./WinnerCalculator.sol";
import "./Staking.sol";
import "./Access.sol";


contract FactoryContract {


    WinToken public winToken;
    IWinToken public tokenContract;
    WinnerCalculator public winnerCalculator;
    Staking public staking;


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
        
    }


}
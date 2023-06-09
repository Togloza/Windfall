// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;


import "./TypeConversion.sol";


contract FactoryContract {


    address public tokenAddress;
    constructor(
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    ) 
    {
        
    }


}
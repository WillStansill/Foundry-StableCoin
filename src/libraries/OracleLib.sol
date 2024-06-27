// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*
/*@title OracleLib
/*@author Will Stansill
/*@notice This library is used to check the Chainlink Oracle for stale data.
    if the price is stale, the function wil revert, and render the DSCEngine unusable - this is 
    We want the DSCEngine to freeze if the prices become stale.

    So if the chainlink newwork explodes and you have a lot of money locked in the protocall.... too bad
/*/

library OracleLib{

    error OracleLib_StalePrice();

    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)
    public
    view
    returns(uint80, int256, uint256, uint256, uint80)
     {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if(secondsSince > TIMEOUT) revert OracleLib_StalePrice();
        return (roundId,  answer,  startedAt,  updatedAt,  answeredInRound);
        
    }
}
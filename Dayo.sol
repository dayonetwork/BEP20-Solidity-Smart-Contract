// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DayoICO.sol";

contract Dayo is DayoICO{
    
    constructor(
                    address icoAddress, 
                    address devAddress, 
                    address teamAddress, 
                    address reserveAddress, 
                    address advisorsAddress
                ) 
        DayoBase(
            "DayoTest0", "DT0",
            icoAddress, 
            devAddress,
            teamAddress, 
            reserveAddress, 
            advisorsAddress)
    {
        //vestTeamTokens(); // Vest team tokens for 6 months
    }
}

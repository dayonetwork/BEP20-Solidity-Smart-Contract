// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DayoICO.sol";

/**
 * @title Dayo Network Contract
 * @dev Provides initialization addresses for token distribution 
 * and starts the vesting for the team reserverd tokens.
 */
contract Dayo is DayoICO{
    
    /// @dev the contructor that gets called on token deployment - starts the 1 year vesting for the team members address
    /// @param icoAddress The address where the tokens reserved for the ICO will be sent to
    /// @param devAddress The address where the tokens reserved for development purposes will be sent to
    /// @param teamAddress The address where the tokens reserved for the team will be sent to
    /// @param reserveAddress The address where the tokens reserved for further investment in adjacent projects (ex: DApps) will be sent to
    /// @param advisorsAddress The address where the tokens reserved for the advisors will be sent to
    constructor(
                    address icoAddress, 
                    address devAddress, 
                    address teamAddress, 
                    address reserveAddress, 
                    address advisorsAddress
                ) 
        DayoBase(
            "Dayo", "DYO",
            icoAddress, 
            devAddress,
            teamAddress, 
            reserveAddress, 
            advisorsAddress)
    {
        vestTeamTokens(); // Vest team tokens for 12 months
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";

/**
 * @title Daimyo Statute Contract for Powerful Users
 * @dev Daimyo reffers to a powerful address with the priviledge
 * of taking full advantage of the network infrastructure and 
 * functions without any conditions or limitations.
 * @notice It is only stipulated in the current contract that
 * a Daimyo address may not pay for changing A records of an 
 * already registered domain or for transfering it. The other
 * functions like registering domains or setting aliases will
 * be done through special onlyOwner functions in order to
 * prevent abuse. It is also stipulated that Daimyo addresses 
 * may not pay for extra traffic.
 */
abstract contract Daimyo is DayoBase{
    
    /// @dev grants Daimyo to the contract owner
    constructor(){
        grantDaimyo(msg.sender);
    }
    
    /// @dev grants Daimyo status to the provided address
    /// @param address_ the address to be granted Daimyo
    function grantDaimyo(address address_)
        public
        onlyOwner
    {
        daimyoList[address_] = true;
    }
}

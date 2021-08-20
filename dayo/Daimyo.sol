// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";

/**
 * @title Daimyo Statute Contract for Powerful Users
 * @dev Daimyo reffers to a powerful address with the priviledge
 * of taking full advantage of the network infrastructure and 
 * functions without any conditions or limitations.
 * @notice In the current context it does not interact with other contracts.
 */
abstract contract Daimyo is DayoBase{
    
    /// @return bool - if the address is Daimyo
    mapping (address => bool) public daimyoList;
    
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

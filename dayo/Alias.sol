// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";
import "./Name.sol";

/**
 * @title Alias Assignment Contract
 * @dev Aliases are a way of identifying an address in the network based
 * on a name which can be used easier than a hexadecimal string. This will
 * be used in DApps in order to simplify the identification process (ex:
 * a chat where you can communicate with other addresses).
 * @notice Old aliases remain stored in the aliasAddress mapping 
 * to prevent impersonation
 */
abstract contract Alias is DayoBase{
    
    /// @return the alias price in DAYO
    uint256 public aliasPrice = 0;
    
    /// @return the alias for a given address
    mapping (address => string) public addressAlias;
    
    /// @return the address for a given alias
    mapping (string => address) public aliasAddress;
    
    /// The alias `alias_` is already taken 
    /// @param alias_ alias
    error AliasAlreadyTaken(string alias_);
    
    /// The address `address_` already has alias `alias_`
    /// @param address_ address
    /// @param alias_ alias
    error AddressAlreadyHasAnAlias(address address_, string alias_);
    
    /// @dev sets the alias dayo to the contract creator
    constructor(){
        setAlias("dayo");
    }
    
    /// @dev called by the owner of the contract to change the "aliasPrice" state variable
    /// @param aliasPrice_ the alias set and update price
    function setAliasPrice(uint256 aliasPrice_) 
        external 
        onlyOwner
    {
        aliasPrice = aliasPrice_;
    }
    
    /// @dev sets the alias for the message caller address
    /// @param alias_ the alias to be set
    function setAlias(string memory alias_)
        public
    {
        Name.validateAlias(alias_);                                         // check if the lias complies
        if(aliasAddress[alias_] != address(0))                              // check if the alias is not taken
            revert AliasAlreadyTaken(alias_);
            
        _burn(msg.sender, aliasPrice);                                      // price (in DAYO) gets burned
            
        addressAlias[msg.sender] = alias_;                                  // set the alias to the address mapping
        aliasAddress[alias_] = msg.sender;                                  // set the address to the alias mapping
    }
    
    /// @dev the owner of the contract sets an alias on behalf of an address (without fees)
    /// @notice the alias cannot be changed (in case the address already has an alias)
    /// @param alias_ the alias to be set
    /// @param address_ the address the alias will be set to
    function setAliasForAddress(string memory alias_, address address_)
        public
    {
        Name.validateAlias(alias_);                                         // check if the lias complies
        if(aliasAddress[alias_] != address(0))                              // check if the alias is not taken
            revert AliasAlreadyTaken(alias_);
            
        addressAlias[address_] = alias_;                                    // set the alias to the address mapping
        aliasAddress[alias_] = address_;                                    // set the address to the alias mapping
    }
}

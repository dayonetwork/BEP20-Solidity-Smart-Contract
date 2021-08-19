// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";
import "./Name.sol";

abstract contract Alias is DayoBase{
    
    uint256 public aliasPrice = 0;
    
    mapping (address => string) public addressAlias;
    
    mapping (string => address) public aliasAddress;
    
    error AliasAlreadyTaken();
    
    constructor(){
        setAlias("Dayo");
    }
    
    function setAliasPrice(uint256 aliasPrice_) 
        external 
        onlyOwner
    {
        aliasPrice = aliasPrice_;
    }
    
    function setAlias(string memory alias_)
        public
    {
        Name.validateAlias(alias_);
        if(aliasAddress[alias_] != address(0))
            revert AliasAlreadyTaken();
            
        _burn(msg.sender, aliasPrice);
        aliasAddress[addressAlias[msg.sender]] = address(0);
        addressAlias[msg.sender] = alias_;
        aliasAddress[alias_] = msg.sender;
    }
}

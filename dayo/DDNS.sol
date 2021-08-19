// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";
import "./Name.sol";

abstract contract DDNS is DayoBase{
    
    uint256 public domainPrice = 0;
    
    struct Domain{
        address owner;
        string ip;
    }
    
    mapping (address => string[]) inventory;
    
    mapping (string => Domain) domains;
    
    error DomainAlreadyRegistered();
    error DomainIsNotOwnedByThisAddress();
    
    modifier onlyDomainOwner(string calldata domain_)
    {
        if(domains[domain_].owner != msg.sender)
            revert DomainIsNotOwnedByThisAddress();
        _;
    }
    
    constructor(){
        
        buyDomain("dayo", "0.0.0.0");
        buyDomain("search", "0.0.0.0");
    }
    
    function setDomainPrice(uint256 domainPrice_) 
        external 
        onlyOwner
    {
        domainPrice = domainPrice_;
    }
    
    function buyDomain(string memory domain_, string memory ip_)
        public
    {
        Name.validateDomainName(domain_);
        Name.validateIP(ip_);
        if(domains[domain_].owner != address(0))
            revert DomainAlreadyRegistered();
            
        _burn(msg.sender, domainPrice);
        inventory[msg.sender].push(string(abi.encodePacked(domain_, ".dayo")));
        domains[domain_].owner = msg.sender;
        domains[domain_].ip = ip_;
    }
    
    function updateARecord(string calldata domain_, string calldata ip_)
        external
        onlyDomainOwner(domain_)
    {
        _burn(msg.sender, domainPrice);
        domains[domain_].ip = ip_;
    }
    
    function transferDomain(string calldata domain_, address owner_)
        external
        onlyDomainOwner(domain_)
    {
        _burn(msg.sender, domainPrice);
        domains[domain_].owner = owner_;
    }
    
    function myDomains()
        external
        view
        returns(string[] memory)
    {
        return inventory[msg.sender];
    }
    
    function resolveDomainName(string calldata domain_)
        external
        view
        returns(string memory)
    {
        return domains[domain_].ip;
    }
    
    function whoIs(string calldata domain_)
        external
        view
        returns(address)
    {
        return domains[domain_].owner;
    }
}

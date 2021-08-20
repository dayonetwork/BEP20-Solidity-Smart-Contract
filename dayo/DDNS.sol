// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";
import "./Name.sol";

/**
 * @title Decentralized Dns Contract for the Dayo Network
 * @dev Provides a way to register domains and set A records, so a 
 * ".dayo" domain can be resolved to an IP address. It will be used
 * in DApps and a currently centralized resolver is set up to resolve 
 * DNS queries for ".dayo" domains. Domains can be registered and 
 * transfered, the A record can be updated, but they cannot be blocked
 * or deleted as this would contradict the decentralized aim of
 * the Dayo Network. 
 */
abstract contract DDNS is DayoBase{
    
    /// @return the domain price in DAYO
    uint256 public domainPrice = 0;
    
    /** 
     * @dev struct which stores the owner address of a domain and 
     * the IP it will be resolved to when queried through Web3
     */
    struct Domain{
        address owner;
        string ip;
    }
    
    /// @dev the domains inventory of an adress
    mapping (address => string[]) inventory;
    
    /// @dev the domain details struct of a domain address
    mapping (string => Domain) domains;
    
    /// Domain `domain_` is already registered
    /// @param domain_ domain
    error DomainAlreadyRegistered(string domain_);
    /// Domain `domain_` is not owned by the address `address_`
    /// @param domain_ domain
    /// @param address_ address
    error DomainIsNotOwnedByThisAddress(string domain_, address address_);
    
    /// @dev restricts function calls only to the owner of the domain
    /// @param domain_ the domain to be verified for ownership against the current sender
    modifier onlyDomainOwner(string calldata domain_)
    {
        if(domains[domain_].owner != msg.sender)
            revert DomainIsNotOwnedByThisAddress(domain_, msg.sender);
        _;
    }
    
    /// @dev registers the "dayo.dayo" and "search.dayo" official domains to the contract owner
    constructor(){
        registerDomainForAddress("dayo", "0.0.0.0", msg.sender);    // register dayo.dayo
        registerDomainForAddress("search", "0.0.0.0", msg.sender);  // register search.dayo
    }
    
    /// @dev called by the owner of the contract to change the "domainPrice" state variable 
    /// @param domainPrice_ the domain registration, domain transfer and record update price
    function setDomainPrice(uint256 domainPrice_) 
        external 
        onlyOwner
    {
        domainPrice = domainPrice_;
    }
    
    /// @dev registration of a domain by the owner of the contract on behalf of an address (without fees)
    /// @param domain_ the domain to be registered
    /// @param ip_ the A record IP
    /// @param address_ the address the domain will be registered to
    function registerDomainForAddress(string memory domain_, string memory ip_, address address_)
        public
        onlyOwner
    {
        Name.validateDomainName(domain_);
        Name.validateIP(ip_);
        if(domains[domain_].owner != address(0))                                    // if the domain is taken, then revert
            revert DomainAlreadyRegistered(domain_);
            
        inventory[address_].push(string(abi.encodePacked(domain_, ".dayo")));       // append .dayo
        domains[domain_].owner = address_;
        domains[domain_].ip = ip_;
    }
    
    /// @dev registers a domain for the message sender address
    /// @param domain_ the domain to be registered
    /// @param ip_ the A record IP
    function registerDomain(string memory domain_, string memory ip_)
        external
    {
        Name.validateDomainName(domain_);
        Name.validateIP(ip_);
        if(domains[domain_].owner != address(0))                                    // if the domain is taken, then revert
            revert DomainAlreadyRegistered(domain_);
            
        _burn(msg.sender, domainPrice);                                             // price (in DAYO) gets burned
        inventory[msg.sender].push(string(abi.encodePacked(domain_, ".dayo")));     // append .dayo
        domains[domain_].owner = msg.sender;
        domains[domain_].ip = ip_;
    }
    
    /// @dev updates domain A record
    /// @param domain_ the domain to be updated
    /// @param ip_ the A record IP
    function updateARecord(string calldata domain_, string calldata ip_)
        external
        onlyDomainOwner(domain_)
    {
        _burn(msg.sender, domainPrice);
        domains[domain_].ip = ip_;
    }
    
    /// @dev transferts a domain from the message caller address to thea new owner
    /// @param domain_ the domain to be transfered
    /// @param owner_ the new owner address
    function transferDomain(string calldata domain_, address owner_)
        external
        onlyDomainOwner(domain_)
    {
        _burn(msg.sender, domainPrice);     // price (in DAYO) gets burned
        domains[domain_].owner = owner_;    // change ownership
    }
    
    /// @return the domain invertory of the message caller address
    function myDomains()
        external
        view
        returns(string[] memory)
    {
        return inventory[msg.sender];
    }
    
    /// @param domain_ the domain to be translated to IPv4
    /// @return the IP address of the domain
    function resolveDomainName(string calldata domain_)
        external
        view
        returns(string memory)
    {
        return domains[domain_].ip;
    }
    
    /// @param domain_ the domain to get the owner for
    /// @return the address who owns the domain
    function whoIs(string calldata domain_)
        external
        view
        returns(address)
    {
        return domains[domain_].owner;
    }
}

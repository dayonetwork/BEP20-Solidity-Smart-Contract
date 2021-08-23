// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./openzeppelin/ERC20.sol";
import "./openzeppelin/Ownable.sol";

/**
 * @title Dayo Base contract
 * @dev The base contract which contains state variables used by 
 * derived contracts and initializations of token distribution
 * addresses and mandatory functions for withdrawal and self 
 * destruct which will be used in the process of migrating
 * from the BEP20 token to the Dayo blockchain.
 */
contract DayoBase is ERC20, Ownable{
    
    /// @return bool - if the address is Daimyo
    mapping (address => bool) public daimyoList;
    
    // Token volumes
    // Initial supply: 1_000_000_000
    // Maximum supply: 1_500_000_000
    uint256 public constant initalSupply = 1_000_000_000;
    uint256 public vestedVolume = 0;
    uint256 public stakedVolume = 0;
    uint256 immutable public maxSupply; // MAX SUPPLY IS 1_500_000_000 DAYO
    
    // Token distribution (% of initial supply minted in the Dayo contrat)
    
    struct TokenDistributionAddress{
        uint256 percentage;
        address holder;
    }
    
    struct Tokenomics{
        TokenDistributionAddress ico;           // 30% - 300_000_000 DAYO
        TokenDistributionAddress dev;           // 20% - 200_000_000 DAYO
        TokenDistributionAddress team;          // 10% - 100_000_000 DAYO
        TokenDistributionAddress reserve;       // 30% - 300_000_000 DAYO
        TokenDistributionAddress advisors;      // 10% - 100_000_000 DAYO
    }
    
    Tokenomics public tokenomics;
    
    // Token allocation
    uint256 constant public icoPercentage = 30;
    uint256 constant public devPercentage = 20;
    uint256 constant public teamPercentage = 10;
    uint256 constant public reservePercentage = 30;
    uint256 constant public advisorsPercentage = 10;
    
    /// @dev Mints the initial token supply and tokenomics 
    /// @param name_ The name of the token 
    /// @param symbol_ The symbol of the token
    /// @param icoAddress The address where the tokens reserved for the ICO will be sent to
    /// @param devAddress The address where the tokens reserved for development purposes will be sent to
    /// @param teamAddress The address where the tokens reserved for the team will be sent to
    /// @param reserveAddress The address where the tokens reserved for further investment in adjacent projects (ex: DApps) will be sent to
    /// @param advisorsAddress The address where the tokens reserved for the advisors will be sent to
    constructor (   string memory name_, string memory symbol_,
                    address icoAddress, 
                    address devAddress, 
                    address teamAddress, 
                    address reserveAddress, 
                    address advisorsAddress
                ) 
        ERC20(name_, symbol_) 
    {
        _mint(msg.sender, initalSupply * (10 ** uint256(decimals()))); // Mint initial supply

        maxSupply = totalSupply() * 3 / 2; // 1_500_000_000 DAYO
        
        tokenomics = Tokenomics(    // Initialize the token distribution addresses and token amounts to be granted
             TokenDistributionAddress(icoPercentage, icoAddress),
             TokenDistributionAddress(devPercentage, devAddress),
             TokenDistributionAddress(teamPercentage, teamAddress),
             TokenDistributionAddress(reservePercentage, reserveAddress),
             TokenDistributionAddress(advisorsPercentage, advisorsAddress)
        );
        
        // Inital token distribution effective immediately
        transfer(tokenomics.ico.holder, tokenomics.ico.percentage * totalSupply() / 100);
        transfer(tokenomics.dev.holder, tokenomics.dev.percentage * totalSupply() / 100);
        transfer(tokenomics.team.holder, tokenomics.team.percentage * totalSupply() / 100);
        transfer(tokenomics.reserve.holder, tokenomics.reserve.percentage * totalSupply() / 100);
        transfer(tokenomics.advisors.holder, tokenomics.advisors.percentage * totalSupply() / 100);
    }
    
    /// @param amount_ The amount of BNB to be withdrawn from the contract address
    function withdraw(uint amount_) 
        external
        onlyOwner
    {
        require(amount_ <= (payable(address(this))).balance);
        payable(address(msg.sender)).transfer(amount_);
    }
    
    /// @param address_ Address to send remaining BNB to
    /// @dev To be used when migrating from BEP20 token to Dayo blockchain
    function seppuku(address payable address_)
        external
        onlyOwner
    {
        selfdestruct(address_);
    }
}

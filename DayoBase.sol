// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./openzeppelin/ERC20.sol";
import "./openzeppelin/Ownable.sol";

contract DayoBase is ERC20, Ownable{
    
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
    
    uint256 constant public icoPercentage = 30;
    uint256 constant public devPercentage = 20;
    uint256 constant public teamPercentage = 10;
    uint256 constant public reservePercentage = 30;
    uint256 constant public advisorsPercentage = 10;
    
    constructor (   string memory name_, string memory symbol_,
                    address icoAddress, 
                    address devAddress, 
                    address teamAddress, 
                    address reserveAddress, 
                    address advisorsAddress
                ) 
        ERC20(name_, symbol_) 
    {
        _mint(msg.sender, initalSupply * (10 ** uint256(decimals())));

        maxSupply = totalSupply() * 3 / 2; // 1_500_000_000 DAYO
        
        tokenomics = Tokenomics(
             TokenDistributionAddress(icoPercentage, icoAddress),
             TokenDistributionAddress(devPercentage, devAddress),
             TokenDistributionAddress(teamPercentage, teamAddress),
             TokenDistributionAddress(reservePercentage, reserveAddress),
             TokenDistributionAddress(advisorsPercentage, advisorsAddress)
        );
        
        // Inital token distribution
        transfer(tokenomics.ico.holder, tokenomics.ico.percentage * totalSupply() / 100);
        transfer(tokenomics.dev.holder, tokenomics.dev.percentage * totalSupply() / 100);
        transfer(tokenomics.team.holder, tokenomics.team.percentage * totalSupply() / 100);
        transfer(tokenomics.reserve.holder, tokenomics.reserve.percentage * totalSupply() / 100);
        transfer(tokenomics.advisors.holder, tokenomics.advisors.percentage * totalSupply() / 100);
    }
    
    function withdraw(uint amount_) 
        external
        onlyOwner
    {
        require(amount_ <= (payable(address(this))).balance);
        payable(address(msg.sender)).transfer(amount_);
    }
    
    
    function seppuku(address payable address_)
        external
        onlyOwner
    {
        selfdestruct(address_);
    }
}

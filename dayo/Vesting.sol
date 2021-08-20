// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";
import "./Time.sol";

/**
 * @title Simple Time Based Vesting Contract
 * @dev Simple vesting scheme. Only the owner can set a vested amount to 
 * an address. When tokens are vested, they are burned from the circulating
 * supply and the vested value is saved in the "vestors" mapping.
 * 
 * The vesting is applied to the team address, which will be vesting for 
 * 365 days (1 year) starting from the contract deployment time, and to
 * ICO participants which will be enforced a 60 days vesting period.
 * 
 * After the vesting period has ended, the amount can be retrieved and
 * minted into the circulating supply. This can be done either by the
 * address owner or by the contract owner (this will be done for those
 * who will not have retrieved their vested amount at the time of
 * migration from BEP20 smart contrac to the Dayo blockchain).
 */
abstract contract Vesting is DayoBase{
    
    struct Vestor {
        uint256 amount;
        uint256 releaseDate;
    }
    
    mapping(address => Vestor) vestors;
    
    // Used in the onlyOwner vest() function
    error AddressIsAlreadyVesting();
    error InvalidVestingAmount();
    error VestedAmountCannotBe0();
    
    /// There is no vested amount for this address
    error AddressIsNotVesting();
    /// The vesting period has not yet ended. You have to wait until `until`
    error StillVesting(uint256 until);
    /// The vested amount has already been redeemed
    error VestedAmountAlreadyRedeemed();

    function vest(address address_, uint256 amount_)
        public
        onlyOwner
    {
        if(amount_ == 0)
            revert VestedAmountCannotBe0();

        if(vestors[address_].releaseDate != 0)
            revert AddressIsAlreadyVesting();
            
        if(amount_ == 0)
            revert InvalidVestingAmount();
        
        _burn(tokenomics.ico.holder, amount_);
        vestedVolume += amount_;
        vestors[address_].amount = amount_;
        vestors[address_].releaseDate = Time.getTime() + 60 days;
    }

    function vestTeamTokens()
        internal
    {
        uint256 tokenAmount = balanceOf(tokenomics.team.holder);
        _burn(tokenomics.team.holder, tokenAmount);
        vestedVolume += tokenAmount;
        vestors[tokenomics.team.holder].amount = tokenAmount;
        vestors[tokenomics.team.holder].releaseDate = Time.getTime() + 365 days;
    }

    function showVesting()
        external
        view
        returns(Vestor memory)
    {
        return vestors[msg.sender];
    }
    
    function retrieveVestedAmount()
        external
    {
        if(vestors[msg.sender].releaseDate == 0)
            revert AddressIsNotVesting();
            
        if(vestors[msg.sender].releaseDate < Time.getTime())
            revert StillVesting(vestors[msg.sender].releaseDate);
            
        if(vestors[msg.sender].amount == 0)
            revert VestedAmountAlreadyRedeemed();
            
        _mint(msg.sender, vestors[msg.sender].amount);
        vestedVolume -= vestors[msg.sender].amount;
        vestors[msg.sender].amount = 0;
    }
    
    function retrieveVestedAmountToBeneficiary(address beneficiary_)
        external
        onlyOwner
    {
        if(vestors[beneficiary_].releaseDate == 0)
            revert AddressIsNotVesting();
            
        if(vestors[beneficiary_].releaseDate < Time.getTime())
            revert StillVesting(vestors[beneficiary_].releaseDate);
            
        if(vestors[beneficiary_].amount == 0)
            revert VestedAmountAlreadyRedeemed();
            
        _mint(beneficiary_, vestors[beneficiary_].amount);
        vestedVolume -= vestors[beneficiary_].amount;
        vestors[beneficiary_].amount = 0;
    }
}

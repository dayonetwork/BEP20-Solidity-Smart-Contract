// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";
import "./Time.sol";

abstract contract Vesting is DayoBase{
    
    struct Vestor {
        uint256 amount;
        uint256 releaseDate;
    }
    
    mapping(address => Vestor) vestors;
    
    // Used in the onlyOwner vest() function
    error AddressIsAlreadyVesting();
    error InvalidVestingAmount();
    error AmountCannotBe0();
    
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
            revert AmountCannotBe0();

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
        vestors[tokenomics.team.holder].releaseDate = Time.getTime() + 180 days;
    }

    function showVesting()
        external
        view
        returns(Vestor memory)
    {
        return vestors[msg.sender];
    }
    
    function redeemVestedAmount()
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
    
    function redeemVestedAmountToBeneficiary(address beneficiary_)
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

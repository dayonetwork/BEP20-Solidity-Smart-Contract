
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";

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
    
    /// The vested amount cannot be 0
    error VestedAmountCannotBe0();
    
    /// An address cannot vest twice
    error AddressIsAlreadyVesting();
    
    /// The vesting amount must be lower than the balance of the ICO address
    error InvalidVestingAmount();
    
    /// There is no vested amount for this address
    error AddressIsNotVesting();
    /// The vesting period has not yet ended. You have to wait until `until`
    error StillVesting(uint256 until);
    /// The vested amount has already been redeemed
    error VestedAmountAlreadyRedeemed();

    /** 
     * @dev only the owner can issue vesting for an address and the
     * vested volume is burned from the ICO address balance, as only 
     * ICO participants and the team will be vesting. 
     */
    /// @param address_ the vestor's address
    /// @param amount_ the amount to be vested
    function vest(address address_, uint256 amount_)
        public
        onlyOwner
    {
        if(amount_ == 0)                                                // if amount to be vested is 0, then revert
            revert VestedAmountCannotBe0();

        if(vestors[address_].releaseDate != 0)                          // if the address is already vesting, then revert
            revert AddressIsAlreadyVesting();
            
        if(amount_ > balanceOf(tokenomics.ico.holder))                  // if the balance of the ICO address is lower than the amount to be vested, then revert
            revert InvalidVestingAmount();
        
        _burn(tokenomics.ico.holder, amount_);                          // burn the vested amount from the ICO address
        vestedVolume += amount_;                                        // increase the total vested volume
        vestors[address_].amount = amount_;                             // set the amount in the mapping
        vestors[address_].releaseDate = block.timestamp + 60 days;      // establish the vesting time and set it in the mapping
    }

    /// @dev start team token vesting - called automatically at contract deployment
    function vestTeamTokens()
        internal
    {
        uint256 tokenAmount = balanceOf(tokenomics.team.holder);                    // get the balance of the team address
        _burn(tokenomics.team.holder, tokenAmount);                                 // burn it 
        vestedVolume += tokenAmount;                                                // increase the total vested volume
        vestors[tokenomics.team.holder].amount = tokenAmount;                       // set the amount in the mapping
        vestors[tokenomics.team.holder].releaseDate = block.timestamp + 365 days;   // establish the vesting time and set it in the mapping
    }

    /// @dev show the vested amount of the message sender address
    /// @return the vested amount and the release date
    function showVesting()
        external
        view
        returns(Vestor memory)
    {
        return vestors[msg.sender];
    }
    
    /// @dev request the retrieval of the vested amount - mint it to the message sender's address balance
    function retrieveVestedAmount()
        external
    {
        if(vestors[msg.sender].releaseDate == 0)                        // if the release date is 0, the address is not vesting, so revert
            revert AddressIsNotVesting();
            
        if(vestors[msg.sender].releaseDate < block.timestamp)           // if the release date hasn't passed, then revert
            revert StillVesting(vestors[msg.sender].releaseDate);
            
        if(vestors[msg.sender].amount == 0)                             // if the amount is 0, but the releaseDate is not, than the amount has been redemed, so revert
            revert VestedAmountAlreadyRedeemed();
            
        _mint(msg.sender, vestors[msg.sender].amount);                  // mint the vested amount to the message sender's address balance
        vestedVolume -= vestors[msg.sender].amount;                     // decrease the total vested volume
        vestors[msg.sender].amount = 0;                                 // set the vested amount to 0 to make it clear that it has been redeemed
    }
    
    /** 
     * @dev retrieve the vested amount on the beneficiary's behalf
     * used when seppuku is issued (selfdestruct) in order to pass
     * relevant balances to the Dayo blockchain
     */
    /// @param beneficiary_ the address of the beneficiary
    function retrieveVestedAmountToBeneficiary(address beneficiary_)
        external
        onlyOwner
    {
        if(vestors[beneficiary_].releaseDate == 0)                      // if the release date is 0, the beneficiary is not vesting, so revert
            revert AddressIsNotVesting();
            
        if(vestors[beneficiary_].releaseDate < block.timestamp)         // if the release date hasn't passed, then revert
            revert StillVesting(vestors[beneficiary_].releaseDate);
            
        if(vestors[beneficiary_].amount == 0)                           // if the amount is 0, but the releaseDate is not, than the amount has been redemed, so revert
            revert VestedAmountAlreadyRedeemed();
            
        _mint(beneficiary_, vestors[beneficiary_].amount);              // mint the vested amount to the beneficiary's address balance
        vestedVolume -= vestors[beneficiary_].amount;                   // decrease the total vested volume
        vestors[beneficiary_].amount = 0;                               // set the vested amount of the beneficiary to 0 to make it clear that it has been redeemed
    }
}

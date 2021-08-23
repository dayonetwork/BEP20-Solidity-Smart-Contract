// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";

/**
 * @title Rewarded Staking Contract
 * @dev Provides an address the possibility to earn rewards by keeping a 
 * certain amount of tokens in a separate storage. These tokens are burned 
 * from the balance and cannot be sent or used to pay for domains or aliases.
 * The staked amount can be removed at any given time and the token amount
 * is minted back into the balance. The reward can be redeemed and is 
 * calculated based on the block time - a 2% reward each 30 days.
 *
 * If the totalSupply reaches the maximum volume, rewards are still calculated,
 * but can only be redeemed after tokens are burned (not staked or vested).
 * Domains must be registered or updated or aliases must be set in order
 * for the totalSupply to decrease.
 * 
 * @notice If the reward is not redeemed before the staking is removed it will 
 * be lost!
 */
abstract contract Staking is DayoBase{
    
    /// @dev struct that holds staking data
    struct StakeHolder {
        uint256 stake;
        uint256 lastReward;
    }
    
    /// @dev contains stakeholders by address
    mapping(address => StakeHolder) stakeholders;
    
    /// Cannot stake 0 tokens
    error CannotStake0();
    
    /// The requested amount: `stake_` exceeds the total balance: `balance_`
    /// @param stake_ amount requested to be staked
    /// @param balance_ total address balance
    error StakeExceedsBalance(uint stake_, uint balance_);
    
    /// Cannot remove 0 tokens from stake
    error CannotRemove0Stake();
    
    /// The requested stake to be removed: `stake_` is greater than the total staking volume of the address: `volume_`
    /// @param stake_ the requested amount to be removed from staking
    /// @param volume_ the total volume staked by the address
    error InsufficientStakingVolume(uint stake_, uint volume_);
    
    /// The maximum token supply has been reached
    error MaxVomuleReached();
    
    /// The address is not staking
    error AddressIsNotStaking();
    
    /// The amount to be redeemed cannot be 0
    error RedeemedAmountCannotBe0();
    
    /// The amount requested to be redeemed: `amount_` exceeds the total reward: `reward_`
    error AmountExceedsReward(uint amount_, uint reward_);

    /// @dev create new stake
    /// @param stake_ amount to be staked
    function createStake(uint256 stake_)
        external
    {
        if(stake_ == 0)                                         // stake cannot be 0
            revert CannotStake0();
        
        if(stake_ > balanceOf(msg.sender))                      // if staking amount is greater than address balance, then revert
            revert StakeExceedsBalance(stake_, balanceOf(msg.sender));

        _burn(msg.sender, stake_);                              // staking volume is burned 
        stakedVolume += stake_;                                 // increase the total staked vokume
        stakeholders[msg.sender].stake += stake_;               // add stake to 
        stakeholders[msg.sender].lastReward = block.timestamp;   // reset the reward timer
    }

    /// @dev remove staked amount 
    /// @notice the reward gets reset even if the stake is partially removed
    /// @param stake_ amount to be removed from stake
    function removeStake(uint256 stake_)
        external
    {
        if(stake_ == 0)                                         // 0 cannot be removed from stake
            revert CannotRemove0Stake();
        
        if(stake_ > stakeholders[msg.sender].stake)             // if the requested amount to be removed is greater than the total staking, then revert
            revert InsufficientStakingVolume(stake_, stakeholders[msg.sender].stake);
        
        stakeholders[msg.sender].stake -= stake_;               // reduce the staked volume of the address
        stakeholders[msg.sender].lastReward = block.timestamp;   // reset the reward timer
        stakedVolume -= stake_;                                 // reduce the total staked volume
        _mint(msg.sender, stake_);                              // mint the removed stake to the address balance
    }

    /// @dev shows the amount staked by the message sender address
    /// @return staked amount
    function showStake()
        external
        view
        returns(uint256)
    {
        return stakeholders[msg.sender].stake;
    }

    /// @dev check if an address is staking
    /// @param address_ the address to be checked
    /// @return staking status
    function isStakeholder(address address_)
        private
        view
        returns(bool)
    {
        return stakeholders[address_].stake != 0;
    }

    /// @dev calculate reward for staking address
    /// @param address_ staking address
    function calculateReward(address address_) 
        private
        view
        returns(uint256)
    {
        uint256 reward = (block.timestamp - stakeholders[address_].lastReward) / (30 days) * (stakeholders[address_].stake / 50);
        
        return reward;
    }
    
    /// @dev only shows the message sender address reward
    /// @return staking reward
    function showReward()
        external
        view
        returns(uint256)
    {
        return calculateReward(msg.sender);
    }

    /// @dev redeem an amount from the total reward
    /// @notice even if you do not redeem the total reward, the rest is lost, as the timer is reset
    /// @param amount_ the amount to be redeemed
    function redeemReward(uint256 amount_) 
        external
    {
        if(!isStakeholder(msg.sender))                                      // if the address is not staking, then revert
            revert AddressIsNotStaking();
            
        if(amount_ == 0)                                                    // 0 cannot be redeemed
            revert RedeemedAmountCannotBe0();
            
        if(stakedVolume + totalSupply() + amount_ > maxSupply)              // if the amount to be redeemed exceeds the maximum network supply, then revert
            revert MaxVomuleReached();
            
        if(calculateReward(msg.sender) < amount_)                           // if the requested amount is greater than the total reward, then revert
            revert AmountExceedsReward(amount_, calculateReward(msg.sender));
        
        stakeholders[msg.sender].lastReward = block.timestamp;               // reset the reward timer (even if not all the reward is redeemed)
        _mint(msg.sender, amount_);
    }
}

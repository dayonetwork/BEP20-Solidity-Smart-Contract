// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";
import "./Time.sol";

abstract contract Staking is DayoBase{
    
    struct StakeHolder {
        uint256 stake;
        uint256 lastReward;
    }
    
    mapping(address => StakeHolder) stakeholders;
    
    error CannotStake0();
    error StakeExceedsFunds();
    error CannotRemove0Stake();
    error InsufficientStakingVolume();
    error MaxVomuleReached();
    error AddressIsNotStaking();
    error AmountCannotBe0();
    error AmountExceedsReward();

    // ---------- STAKES ----------

    function createStake(uint256 stake_)
        external
    {
        if(stake_ == 0)
            revert CannotStake0();
        
        if(stake_ > balanceOf(msg.sender))
            revert StakeExceedsFunds();

        _burn(msg.sender, stake_);
        stakedVolume += stake_;
        stakeholders[msg.sender].stake += stake_;
        stakeholders[msg.sender].lastReward = Time.getTime();
    }


    function removeStake(uint256 stake_)
        external
    {
        if(stake_ == 0)
            revert CannotRemove0Stake();
        
        if(stake_ > stakeholders[msg.sender].stake)
            revert InsufficientStakingVolume();
        
        stakeholders[msg.sender].stake -= stake_;
        stakeholders[msg.sender].lastReward = Time.getTime();
        stakedVolume -= stake_;
        _mint(msg.sender, stake_);
    }


    function showStake()
        external
        view
        returns(uint256)
    {
        return stakeholders[msg.sender].stake;
    }

    function isStakeholder(address address_)
        private
        view
        returns(bool)
    {
        return stakeholders[address_].stake != 0;
    }


    // ---------- REWARDS ----------
    
    function calculateReward(address address_) 
        private
        view
        returns(uint256)
    {
        // uint265 reward = (Time.getTime() - stakeholders[stake_holder].lastReward) / (60 * 60 * 24 * 30) * (stakeholders[stake_holder].stake / 10);
        uint256 reward = (Time.getTime() - stakeholders[address_].lastReward) / (30) * (stakeholders[address_].stake / 100);
        
        return reward;
    }
    
    function showReward()
        external
        view
        returns(uint256)
    {
        return calculateReward(msg.sender);
    }

    function redeemReward(uint256 amount_) 
        external
    {
        if(!isStakeholder(msg.sender))
            revert AddressIsNotStaking();
            
        if(amount_ == 0)
            revert AmountCannotBe0();
            
        if(stakedVolume + totalSupply() + amount_ > maxSupply)
            revert MaxVomuleReached();
            
        if(calculateReward(msg.sender) < amount_)
            revert AmountExceedsReward();
        
        stakeholders[msg.sender].lastReward = Time.getTime();
        _mint(msg.sender, amount_);
    }
}

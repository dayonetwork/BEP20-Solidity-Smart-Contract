// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./dayo/Alias.sol";
import "./dayo/Staking.sol";
import "./dayo/Vesting.sol";
import "./dayo/DDNS.sol";
import "./dayo/Network.sol";

/**
 * @title Initial Coin Offering Contract
 * @dev Provides functionality for buying tokens through 3 
 * rounds of decentralized investing managed by the "sale"
 * state variable. The rounds are controlled by the owner 
 * of the contract, but the amount and funding target for 
 * each round are preset.
 */
abstract contract DayoICO is Alias, Staking, Vesting, DDNS, Network{
    
    /// @dev 5 stages of the ICO
    enum ICOStage{
        NOT_STARTED,
        ROUND_ONE,
        ROUND_TWO,
        ROUND_THREE,
        OVER
    }
    
    /// @dev struct to be used when receiving BNB
    struct Round {
        ICOStage icoStage;
        uint256 slotPrice; // BNB that must be paid
        uint256 slotValue; // DAYO that will be received in exchange
        uint256 slotsLeft; // decreasing from initial 1000
        uint256 startTime;
    }
    
    /// @dev struct that holds data about the 3 investing rounds
    struct Sale{
        Round round_1;
        Round round_2;
        Round round_3;
    }
    
    /// @dev holds the current ICO stage (and roud)
    ICOStage public currentICOStage;
    Sale public sale;
    
    /// @dev the ICO investment window - starting from the "nextRound" call
    uint256 constant public window = 12 hours;
    
    /// @dev price in BNB
    uint256 constant public round_1_slotPrice = 1;
    /// @dev price in BNB
    uint256 constant public round_2_slotPrice = 1;
    /// @dev price in BNB
    uint256 constant public round_3_slotPrice = 1;
    
    /// @dev value in DAYO (to be received)
    uint256 constant public round_1_slotValue = 150_000;
    /// @dev value in DAYO (to be received)
    uint256 constant public round_2_slotValue = 100_000;
    /// @dev value in DAYO (to be received)
    uint256 constant public round_3_slotValue = 50_000;
    
    /// @dev 1000 participants each ICO round
    uint256 constant public initialSlotsNumber = 1000;

    /// The ICO has not yet started
    error ICONotYetStarted();
    /// The ICO has ended
    error ICOIsOver();
    /// The target for this round has been reached
    error ICOTargetReached();
    /// This round of the ICO has ended
    error ICORoundEnded();
    /// The wrong amount was sent: needed `needed_`, but `sent_` was sent
    /// @param needed_ amount needed for current investment round participation
    /// @param sent_ amount sent to contract address
    error WrongAmountSent(uint needed_, uint sent_);
    
    /// @dev initializes the public sale
    constructor(){
        sale = Sale( // Public sale rounds initialization
            Round(ICOStage.ROUND_ONE, round_1_slotPrice, round_1_slotValue, initialSlotsNumber, 0), 
            Round(ICOStage.ROUND_TWO, round_2_slotPrice, round_2_slotValue, initialSlotsNumber, 0), 
            Round(ICOStage.ROUND_THREE, round_3_slotPrice, round_3_slotValue, initialSlotsNumber, 0));
    }
    
    /// @dev starts the next round of investment
    function nextRound()
        external
        onlyOwner
    {
        if(currentICOStage == ICOStage.NOT_STARTED){                    // starts the first ICO round
            currentICOStage = ICOStage.ROUND_ONE;
            sale.round_1.startTime = Time.getTime();
        } else if(currentICOStage == ICOStage.ROUND_ONE){               // starts the second ICO round
            require(sale.round_1.startTime + window < Time.getTime());
            
            currentICOStage = ICOStage.ROUND_TWO;
            sale.round_2.startTime = Time.getTime();
        } else if(currentICOStage == ICOStage.ROUND_TWO){
            require(sale.round_2.startTime + window < Time.getTime());  // starts the third ICO round
            
            currentICOStage = ICOStage.ROUND_THREE;
            sale.round_3.startTime = Time.getTime();
        } else {                                                        // ends the ICO
            require(sale.round_3.startTime + window < Time.getTime());
            
            currentICOStage = ICOStage.OVER;
        }
    }
    
    /// @dev ends the ICO prematurely
    function endICO()
        external
        onlyOwner
    {
        currentICOStage = ICOStage.OVER;
    }
    
    /// @dev receive BNB in the contract address based on the ICO stage
    receive() 
        external 
        payable 
    {
        if(currentICOStage == ICOStage.NOT_STARTED)                 // if ICO is not started, then revert and return funds
            revert ICONotYetStarted();
        else if(currentICOStage == ICOStage.ROUND_ONE){             // if the firs ICO round is started
            if(sale.round_1.slotsLeft == 0)                         // checks if there are any slots left
                revert ICOTargetReached();
                
            if(sale.round_1.startTime + window > Time.getTime())    // checks if the round ended
                revert ICORoundEnded();
                
            if(msg.value != sale.round_1.slotPrice)                 // checks if the right amount is being sent
                revert WrongAmountSent(sale.round_1.slotPrice, msg.value);
            
            vest(msg.sender, sale.round_1.slotValue);
            sale.round_1.slotsLeft--;
        } else if(currentICOStage == ICOStage.ROUND_TWO){           // if the second ICO round is started
            if(sale.round_2.slotsLeft == 0)                         // checks if there are any slots left
                revert ICOTargetReached();
                
            if(sale.round_2.startTime + window > Time.getTime())    // checks if the round ended
                revert ICORoundEnded();
                
            if(msg.value != sale.round_2.slotPrice)                 // checks if the right amount is being sent
                revert WrongAmountSent(sale.round_2.slotPrice, msg.value);
            
            vest(msg.sender, sale.round_2.slotValue);
            sale.round_2.slotsLeft--;
        } else if(currentICOStage == ICOStage.ROUND_THREE){         // if the third ICO round is started
            if(sale.round_3.slotsLeft == 0)                         // checks if there are any slots left
                revert ICOTargetReached();
                
            if(sale.round_3.startTime + window > Time.getTime())    // checks if the round ended
                revert ICORoundEnded();
                
            if(msg.value != sale.round_3.slotPrice)                 // checks if the right amount is being sent
                revert WrongAmountSent(sale.round_3.slotPrice, msg.value);
            
            vest(msg.sender, sale.round_3.slotValue);
            sale.round_3.slotsLeft--;
        } else if(currentICOStage == ICOStage.OVER)                 // if the third ICO ended, then revert and return funds
            revert ICOIsOver();
    }
}

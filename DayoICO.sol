// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./dayo/Alias.sol";
import "./dayo/Staking.sol";
import "./dayo/Vesting.sol";
import "./dayo/DDNS.sol";

abstract contract DayoICO is Alias, Staking, Vesting, DDNS{
    
    enum ICOStage{
        NOT_STARTED,
        ROUND_ONE,
        ROUND_TWO,
        ROUND_THREE,
        OVER
    }
    
    struct Round {
        ICOStage icoStage;
        uint256 slotPrice; // BNB that must be paid
        uint256 slotValue; // DAYO that will be received in exchange
        uint256 slotsLeft; // decreasing from initial 2048
        uint256 startTime;
    }
    
    struct Sale{
        Round round_1;
        Round round_2;
        Round round_3;
    }
    
    ICOStage public currentICOStage;
    Sale public sale;
    
    uint256 constant public window = 12 hours;
    
    uint256 constant public round_1_slotPrice = 1;
    uint256 constant public round_2_slotPrice = 1;
    uint256 constant public round_3_slotPrice = 1;
    
    uint256 constant public round_1_slotValue = 600000;
    uint256 constant public round_2_slotValue = 400000;
    uint256 constant public round_3_slotValue = 200000;
    
    uint256 constant public initialSlotsNumber = 2048;

    error ICONotYetStarted();
    error ICOIsOver();
    error ICOTargetReached();
    error ICORoundEnded();
    error WrongAmountSent();
    
    constructor(){
        // sale = Sale(
        //     Round(ICOStage.ROUND_ONE, round_1_slotPrice, round_1_slotValue, initialSlotsNumber, 0), 
        //     Round(ICOStage.ROUND_TWO, round_2_slotPrice, round_2_slotValue, initialSlotsNumber, 0), 
        //     Round(ICOStage.ROUND_THREE, round_3_slotPrice, round_3_slotValue, initialSlotsNumber, 0));
    }
    
    function nextRound()
        external
        onlyOwner
    {
        if(currentICOStage == ICOStage.NOT_STARTED){
            currentICOStage = ICOStage.ROUND_ONE;
            sale.round_1.startTime = Time.getTime();
        } else if(currentICOStage == ICOStage.ROUND_ONE){
            require(sale.round_1.startTime + window < Time.getTime());
            
            currentICOStage = ICOStage.ROUND_TWO;
            sale.round_2.startTime = Time.getTime();
        } else if(currentICOStage == ICOStage.ROUND_TWO){
            require(sale.round_2.startTime + window < Time.getTime());
            
            currentICOStage = ICOStage.ROUND_THREE;
            sale.round_3.startTime = Time.getTime();
        } else {
            require(sale.round_3.startTime + window < Time.getTime());
            
            currentICOStage = ICOStage.OVER;
        }
    }
    
    function endICO()
        external
        onlyOwner
    {
        currentICOStage = ICOStage.OVER;
    }
    
    receive() external payable {
        
        if(currentICOStage == ICOStage.NOT_STARTED)
            revert ICONotYetStarted();
        else if(currentICOStage == ICOStage.ROUND_ONE){
            if(sale.round_1.slotsLeft == 0)
                revert ICOTargetReached();
                
            if(sale.round_1.startTime + window > Time.getTime())
                revert ICORoundEnded();
                
            if(msg.value != sale.round_1.slotPrice)
                revert WrongAmountSent();
            
            vest(msg.sender, sale.round_1.slotValue);
            sale.round_1.slotsLeft--;
        } else if(currentICOStage == ICOStage.ROUND_TWO){
            if(sale.round_2.slotsLeft == 0)
                revert ICOTargetReached();
                
            if(sale.round_2.startTime + window > Time.getTime())
                revert ICORoundEnded();
                
            if(msg.value != sale.round_2.slotPrice)
                revert WrongAmountSent();
            
            vest(msg.sender, sale.round_2.slotValue);
            sale.round_2.slotsLeft--;
        } else if(currentICOStage == ICOStage.ROUND_THREE){
            if(sale.round_3.slotsLeft == 0)
                revert ICOTargetReached();
                
            if(sale.round_3.startTime + window > Time.getTime())
                revert ICORoundEnded();
                
            if(msg.value != sale.round_3.slotPrice)
                revert WrongAmountSent();
            
            vest(msg.sender, sale.round_3.slotValue);
            sale.round_3.slotsLeft--;
        } else if(currentICOStage == ICOStage.OVER)
            revert ICOIsOver();
    }
}

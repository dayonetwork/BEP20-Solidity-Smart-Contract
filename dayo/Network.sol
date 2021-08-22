// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DayoBase.sol";

/**
 * @title Netowrk Traffic Management Contract
 * @dev Provides an interface for the middleware to store traffic consumption data 
 * and to incentivise traffic relay entities for providing relay of traffic.
 * These entities will take the form of nodes in the Dayo blockchain.
 * @notice Initially, the netowrk will be free to use.
 */
abstract contract Network is DayoBase{
 
    /// @return the cost in DAYO for a network traffic unit in Mb
    uint public cost = 0;
    
    /// @return the amount of Mb of a network traffic unit
    uint public value = 0;
    
    /// @dev stores consumed traffic in Mb
    mapping (address => uint) totalTraffic;
    
    /// @dev stores traffic left in MB
    mapping (address => uint) trafficLeft;
    
    /// Daimyo addresses shall not burn funds for traffic (pay) and traffic shall not be burned (metered)
    error DaimyoShallNotBurn();
    
    /// @dev burn DAYO to increase the traffic limit
    function burnDayoForTraffic()
        external
    {
        if(daimyoList[msg.sender] == true)      // if the message sender address is Daimyo, then revert - Daimyo shall not pay
            revert DaimyoShallNotBurn();
            
        _burn(msg.sender, cost);                // price (in DAYO) gets burned
        trafficLeft[msg.sender] += value;       // increase the traffic limit
    }
    
    /// @dev traffic meter to decrease the remaining traffic 
    /// @param address_ address which used the network
    /// @param traffic_ the amount of traffic it consumed
    function burnTraffic(address address_, uint traffic_)
        external
        onlyOwner
    {
        if(daimyoList[address_] == true)        // if the message sender address is Daimyo, then revert - no limitations are imposed to Daimyo
            revert DaimyoShallNotBurn();
            
        totalTraffic[address_] += traffic_;     // increase the total traffic for the supplied address
        
        if(trafficLeft[address_] < traffic_)    // if the traffic left underflows
            trafficLeft[address_] = 0;          // set to 0
        else                                    // else
            trafficLeft[address_] -= traffic_;  // decrease the consumed traffic
    }
    
    /// @dev set the cost of netowrk consumption per Mb 
    /// @param cost_ the effective cost in DAYO
    function setCost(uint cost_)
        external
        onlyOwner
    {
        cost = cost_;
    }
    
    /// @dev set the amount of traffic received by calling "burnDayoForTraffic()" function (value of the purchase in Mb)
    /// @param value_ the effective value in Mb of burnDayoForTraffic
    function setValue(uint value_)
        external
        onlyOwner
    {
        value = value_;
    }
}

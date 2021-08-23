// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Safe Block Time Library
 * @dev This library uses a correlation between blocks and timestamps
 * to retrieve the correct unix time relative to an initial block.
 * This is done in order to avoid block timestamp manipulation:
 * https://www.bookstack.cn/read/ethereumbook-en/spilt.14.c2a6b48ca6e1e33c.md
 * 
 * @notice This is applicable only to Binance Smart Chain due to the initial block 
 * number and the 3 seconds block processing time which is characteristic to BSC!
 */
library Time{
    
    /// @dev the block processing time in the BSC network
    uint256 constant blockProcessingTime = 3 seconds;
    
    /// @dev a block for which the time is known and verified
    /// @return the block number
    function getInitialBlock()
        private
        pure
        returns(uint256)
    {
        return 10727189;
    }
    
    /// @dev the timestamp for the block aforementioned
    /// @return timestamp
    function getInitialTime()
        private
        pure
        returns(uint256)
    {
        return 1626696693;
    }
    
    /** 
     * @dev the difference between the current block and the verified 
     * block multiplied by the block processing time added to the initial 
     * verified time
     * @return the current time
     */ 
    function getTime() 
        public
        view
        returns(uint256)
    {
        return (block.number - getInitialBlock()) * blockProcessingTime + getInitialTime();
    }
}

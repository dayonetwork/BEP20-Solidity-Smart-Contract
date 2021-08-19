// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Applicable for BSC only
library Time{
    
    function getInitialBlock()
        private
        pure
        returns(uint256)
    {
        return 10727189;
    }
    
        function getInitialTime()
        private
        pure
        returns(uint256)
    {
        return 1626696693;
    }
    
    function getTime() 
        internal
        view
        returns(uint256)
    {
        return (block.number - getInitialBlock()) * 3 + getInitialTime();
    }
}

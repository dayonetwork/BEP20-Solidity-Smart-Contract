// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Name{
    
    uint256 constant public domainMinLength = 3;
    uint256 constant public domainMaxLength = 15;
    
    uint256 constant public aliasMinLength = 3;
    uint256 constant public aliasMaxLength = 15;
    
    uint256 constant ipMinLength = 7;
    uint256 constant ipMaxLength = 15;

    error DomainNameTooShort();
    error DomainNameTooLong();
    error DomainNameContainsInvalidCharacters();
    
    error AliasTooShort();
    error AliasTooLong();
    error AliasContainsInvalidCharacters();
    
    error InvalidIP();

    function validateDomainName(string memory domain_)
        internal
        pure
    {
        
        bytes memory b = bytes(domain_);

        if(b.length < 3)
            revert DomainNameTooShort();
            
        if(b.length > 15)
            revert DomainNameTooLong();
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
    
            if(
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) //a-z
            )
                revert DomainNameContainsInvalidCharacters();
        }
    }
    
    function validateAlias(string memory alias_)
        internal
        pure
    {
        
        bytes memory b = bytes(alias_);
        
        if(b.length < 3)
            revert AliasTooShort();
            
        if(b.length > 15)
            revert AliasTooLong();
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
    
            if(
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) && //a-z
                !(char == 0x5F) // _
            )
                revert AliasContainsInvalidCharacters();
        }
    }
    
    function validateIP(string memory ip_)
        internal
        pure
    {
        bytes memory b = bytes(ip_);
        
        if(b.length < 3)
            revert InvalidIP();
            
        if(b.length > 15)
            revert InvalidIP();
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
    
            if(
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char == 0x2E) // .
            )
                revert InvalidIP();
        }
        
        // number of occurences
        uint dots;
        // index of each '.'
        uint[3] memory separators;
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
         
            if(char == 0x2E){
                separators[dots] = i;
                dots ++;
            }
        }
        
        if(dots != 3)
            revert InvalidIP();
            
        if( separators[0] == 0 || // IP begins with '.' 
            separators[2] == b.length - 1 || // IP ends with '.'
            separators[0] == separators[1] - 1 || // '..' 
            separators[1] == separators[2] - 1) // '..'
            revert InvalidIP();
            
        uint256 octet1 = stringToUint(substring(ip_, 0, separators[0]));
        uint256 octet2 = stringToUint(substring(ip_, separators[0], separators[1]));
        uint256 octet3 = stringToUint(substring(ip_, separators[1], separators[2]));
        uint256 octet4 = stringToUint(substring(ip_, separators[2], b.length));
        
        if(octet1 > 255 || octet2 > 255 || octet3 > 255 || octet4 > 255)
            revert InvalidIP();
    }
    
    function substring(string memory str, uint startIndex, uint endIndex) 
        private 
        pure
        returns(string memory) 
    {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }
    
    function stringToUint(string memory s) 
        private 
        pure
        returns(uint256 result) 
    {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Name and IP Validation Library
 * @dev A utility library used for string verifications for domain names,
 * aliases and IP validations.
 */
library Name{
    
    /// @return Minimum length of a domain (in char count)
    uint constant public domainMinLength = 3;
    /// @return Maximum length of a domain (in char count)
    uint constant public domainMaxLength = 15;
    
    /// @return Minimum length of an alias (in char count)
    uint constant public aliasMinLength = 3;
    /// @return Maximum length of an alias (in char count)
    uint constant public aliasMaxLength = 15;
    
    /// @dev Minimum length of an IP (in char count)
    uint constant ipMinLength = 7;
    /// @dev Maximum length of an IP (in char count)
    uint constant ipMaxLength = 15;

    /// The domain name is `length_` characters long. The minimum length is 3 characters
    /// @param length_ domain name length
    error DomainNameTooShort(uint length_);
    
    /// The domain name is `length_` characters long. The maximum length is 15 characters
    /// @param length_ domain name length
    error DomainNameTooLong(uint length_);
    
    /// The domain name contains invalid character `char_`. Only lower case latin alphabet letters, digits and underscores (_) are allowed
    /// @param char_ invalid character
    error DomainNameContainsInvalidCharacters(bytes1 char_);
    
    /// The alias is `length_` characters long. The minimum length is 3 characters
    /// @param length_ alias length
    error AliasTooShort(uint length_);
    
    /// The alias is `length_` characters long. The maximum length is 15 characters
    /// @param length_ alias length    
    error AliasTooLong(uint length_);
    
    /// The alias contains invalid character `char_`. Only lower case latin alphabet letters, digits and underscores (_) are allowed
    /// @param char_ invalid character
    error AliasContainsInvalidCharacters(bytes1 char_);
    
    /// The ip ip is invalid
    error InvalidIP();

    /// @dev validate domain name - reverts if not compliant instead of returning bool
    /// @param domain_ domain name to be validated 
    function validateDomainName(string memory domain_)
        internal
        pure
    {
        bytes memory b = bytes(domain_);                            // convert domain name to bytes

        if(b.length < 3)                                            // if the domain name is too short, then revert
            revert DomainNameTooShort(b.length);
            
        if(b.length > 15)                                           // if the domain name is too long, then revert
            revert DomainNameTooLong(b.length);
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
    
            if(                                                     // if the domain name contains other characters than the accepted ones, then revert
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x61 && char <= 0x7A) //a-z
            )
                revert DomainNameContainsInvalidCharacters(char);
        }
    }
    
     /// @dev validate alias - reverts if not compliant instead of returning bool
    /// @param alias_ alias to be validated 
    function validateAlias(string memory alias_)
        internal
        pure
    {
        
        bytes memory b = bytes(alias_);                             // convert alias to bytes
        
        if(b.length < 3)                                            // if the alias is too short, then revert
            revert AliasTooShort(b.length);
            
        if(b.length > 15)                                           // if the alias is too long, then revert
            revert AliasTooLong(b.length);
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
    
            if(                                                     // if the alias contains other characters than the accepted ones, then revert
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x61 && char <= 0x7A) && //a-z
                !(char == 0x5F) // _
            )
                revert AliasContainsInvalidCharacters(char);
        }
    }
    
    /// @dev validate IP - reverts if not compliant instead of returning bool
    /// @param ip_ IP to be validated 
    function validateIP(string memory ip_)
        internal
        pure
    {
        bytes memory b = bytes(ip_);                                // convert IP to bytes
        
        if(b.length < 3)                                            // if the IP is too short, then revert
            revert InvalidIP();
            
        if(b.length > 15)                                           // if the IP is too long, then revert
            revert InvalidIP();
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
    
            if(                                                     // if the IP contains other characters than the valid ones, then revert
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char == 0x2E) // .
            )
                revert InvalidIP();
        }
        
        uint dots;                                                  // number of occurences
        
        uint[3] memory separators;                                  // index of each '.'
        
        for(uint i; i<b.length; i++){                               // count '.' separators and store indexes
            bytes1 char = b[i];
         
            if(char == 0x2E){
                separators[dots] = i;
                dots ++;
            }
        }
        
        if(dots != 3)                                               // if there are more than 3 '.' separators in the IP, then revert
            revert InvalidIP();
            
        if( separators[0] == 0 ||                                   // IP begins with '.' 
            separators[2] == b.length - 1 ||                        // IP ends with '.'
            separators[0] == separators[1] - 1 ||                   // first 2 '..' separators one next to the other
            separators[1] == separators[2] - 1)                     // next 2 '..' separators one next to the other
            revert InvalidIP();
            
        uint octet1 = stringToUint(substring(ip_, 0, separators[0]));                   // store each octet as uint256 (converted from string representation)
        uint octet2 = stringToUint(substring(ip_, separators[0], separators[1]));
        uint octet3 = stringToUint(substring(ip_, separators[1], separators[2]));
        uint octet4 = stringToUint(substring(ip_, separators[2], b.length));
        
        if(octet1 > 255 || octet2 > 255 || octet3 > 255 || octet4 > 255)                // if any octet is greater than 255 decimal, then revert
            revert InvalidIP();
            
        if(                                                                             // octets should only begin with 0 if they are 0 themselves, else revert
            (octet1 > 0 && b[0] == 0x30) ||
            (octet2 > 0 && b[separators[0] + 1] == 0x30) ||
            (octet3 > 0 && b[separators[1] + 1] == 0x30) ||
            (octet4 > 0 && b[separators[2] + 1] == 0x30)
        )
            revert InvalidIP();
    }
    
    /// @dev string substractin based on start and end indexes
    /// @param string_ the initial string
    /// @param startIndex_ the start index
    /// @param endIndex_ the end index
    /// @return the substring
    function substring(string memory string_, uint startIndex_, uint endIndex_) 
        private 
        pure
        returns(string memory) 
    {
        bytes memory strBytes = bytes(string_);
        bytes memory result = new bytes(endIndex_ - startIndex_);
        for(uint i = startIndex_; i < endIndex_; i++) {
            result[i-startIndex_] = strBytes[i];
        }
        return string(result);
    }
    
    /// @dev Converts a number in string format to uint256
    /// @param string_ string representation of a number
    /// @return uint256 of the string representation
    function stringToUint(string memory string_) 
        private 
        pure
        returns(uint) 
    {
        bytes memory b = bytes(string_);
        uint i;
        uint result = 0;
        for (i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
}

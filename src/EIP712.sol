//SPDX-License-Identifier: MIT


contract EIP712 {

    bytes32 private DOMAIN_SEPARATOR;
    
    constructor(string memory name, string memory version) {
        
    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash) public returns (bytes32) {
        
    }

}
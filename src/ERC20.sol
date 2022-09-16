//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ERC20 {

    bytes32 private DOMAIN_SEPARATOR;
    ERC20 drm;

    mapping(address => uint256) private _nonces;
    mapping(address => uint256) private balances; 
    mapping(address => mapping(address => uint256)) private allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimal;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Pause();
    bool public paused = false;

    bytes32 _hash = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name, string memory version) {
        _name = name;
        _symbol = version;
        _decimal = 18;
        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
    }

function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimal;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(structHash));
    }

    function _mint(address _from, uint256 _value) public {
        require(_from != address(0), "Non exist address");
        _totalSupply += _value;
        unchecked{
            balances[_from] += _value;
        }
        emit Transfer(address(0), _from, _value);
    }

    function _burn(address _to, uint256 _value) public {
        require(_to != address(0));
        require(balances[_to] - _value >= 0 );
        unchecked{
        balances[_to] -= _value;
        _totalSupply -= _value;
        }
        emit Transfer(_to, address(0), _value);
    }

    function permit(address _owner, address _spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(block.timestamp <= deadline, "Permit: expired deadline");
        uint now_nonce = _nonces[_owner];
        _nonces[_owner]+=1;

        bytes32 structHash = keccak256(abi.encode(_hash, _owner, _spender, value, now_nonce, deadline));
        bytes32 hash_ = _toTypedDataHash(structHash);
        address signer = ecrecover(hash_, v, r, s);
        require(signer == _owner, "INVALID_SIGNER");
        approve(_owner, _spender, value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        transfer( msg.sender, _to, _value);
        return true;
    }

    function transfer(address _from, address _to, uint256 _value) public returns (bool success){
        require(_from != address(0), "Invalid From address");
        require(_to != address(0), "Invalid To address");
        require(balances[msg.sender] >= _value, "Value exceeds balance");

        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(_from, _to, _value);
    }

    function pause() public {
        require(paused);
        emit Pause();
    }

    function approve(address _to, uint256 _value) public returns (bool success){
        address _from = msg.sender;
        approve(_from, _to, _value);
        return true;
    }

    function approve(address _from, address _to, uint256 _value) public returns (bool success){
        require(_from != address(0));
        require(_to != address(0));
        require(balances[_from] >= _value, "Value exceeds balance");

        allowances[_from][_to] = _value;
        if (allowances[_from][_to] > 0){
            return true;
        } else{
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        require(msg.sender != address(0)); 
        require(_to != address(0));
        require(balances[_from] >= _value, "Value exceeds balance"); 

        uint256 curretnAllowance = allowance(_from, msg.sender);
        
        require(curretnAllowance >= _value, "insufficient allowance");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }
        require(balances[_from] >= _value);

        unchecked {
            balances[_to] += _value;
            balances[_from] -= _value;
        }

        emit Transfer( _from, _to, _value); 

        return true;
    }
    
    function allowance(address _owner, address _spender) public returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

    function nonces(address _who) public returns (uint256) {
        return _nonces[_who];
    }
}
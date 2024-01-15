// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyToken.sol";
contract TokenBank{
    MyToken my_token;
    mapping(address=>uint) public balance;
    address public owner;

    constructor(address token){
        owner = msg.sender;
        my_token = MyToken(token);
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"not owner!!");
        _;
    }

    

    function deposit(uint value)public returns (bool){
        require(value <= my_token.allowance(msg.sender, address(this)),"allowance not enough"); //需要先判断用户对于合约地址的授权额度
        bool success = my_token.transferFrom(msg.sender, address(this), value); 
        require(success,"transfer failed!!");
        balance[msg.sender] += value;
        return success;
    }

    function withdraw()public onlyOwner{
        uint token_balance = my_token.balanceOf(address(this));
        require(0 < token_balance,"No balance");
        bool success = my_token.transfer(owner, token_balance);
        require(success,"transfer failed!!");
        
    }
    
}
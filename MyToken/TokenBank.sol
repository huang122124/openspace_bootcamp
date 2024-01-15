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

    receive() external payable { 

    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function deposit(uint value)public payable {
        bool success = my_token.transfer(address(this), value);
        require(success,"transfer failed!!");
        balance[msg.sender] += value;
    }

    function withdraw()public onlyOwner{
        uint token_balance = my_token.balanceOf(address(this));
        require(0 < token_balance,"No balance");
        my_token.approve(owner,token_balance);
        bool success = my_token.transferFrom(address(this),owner,token_balance);
        require(success,"transfer failed!!");
        
    }
    
}
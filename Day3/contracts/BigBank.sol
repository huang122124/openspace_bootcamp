// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Bank.sol";

contract BigBank is Bank{
    address public big_owner;

    constructor(){
        big_owner = msg.sender;
    }
    
    modifier only_limited_ether(){
        require(msg.value > 0.001 ether);
        _;
    }

    function set_Owner(address _owner)external only_Owner{
        big_owner = _owner;
    }

    

    event Receive_ETH(uint amount);

    receive() external override payable only_limited_ether{
        emit Receive_ETH(msg.value);
    }

    function deposit(uint amount) public payable only_limited_ether{
        (bool success,) = address(this).call{value:amount}("");
    }

    function withdraw() external override only_Owner{
        payable(msg.sender).transfer(address(this).balance);
    }
}

interface IBigBank {
    function withdraw() external;
}

contract Ownable{

    address public owner;
    constructor(){
        owner = msg.sender;
    }

    receive() external payable{

    }

    function withdraw_from_BigBank(address big_bank) external{
        IBigBank(big_bank).withdraw();
    }

    function withdraw() external payable{
        require(msg.sender == owner,"not owner!");
        uint balance = address(this).balance;
        (bool success,) = msg.sender.call{value:balance}("");
        require(success,"withdraw failed!");
    }
    
}


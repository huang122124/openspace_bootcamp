// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract counter{
    uint public count;
    

    function add(uint x) public{
        count = count + x;
    }
}
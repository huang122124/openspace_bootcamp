// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface Implementation{
    function init(
        string memory name,
        string memory symbol
    )external;

    function mint(address minter,uint value)external payable;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract CounterTest is Test {
    Bank public bank;

    function setUp() public {
        bank = new Bank();
    }

    function test_Get_balance() public {
        bank.get_balance();
        assertEq(bank.get_balance(), address(bank).balance);
    }

}

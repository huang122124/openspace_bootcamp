//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV2Pair} from "../src/contracts/UniswapV2Pair.sol";

contract PairTest is Test {
    UniswapV2Pair public pair;

    function setUp() public {
        pair = new UniswapV2Pair();
    }

    function testBytecode() public pure{
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        console2.logBytes(bytecode);//66a4aeae777a80564816b4da78c7b8fab2e175fbfe734a864002f47a7bcb4e15
    }

    
}

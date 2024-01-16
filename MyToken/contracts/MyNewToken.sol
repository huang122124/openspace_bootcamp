// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyNewToken is ERC20{
    
    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }

    
    //回调功能的 ERC20Token
    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        callTokenReceive(recipient,amount);
        return transfer(recipient, amount);
    }
    

    
    function callTokenReceive(address to,uint amount) internal {
        if(isContract(to)){
            (bool success,) = to.call(abi.encodeWithSignature("tokenReceive(uint)",amount));
            if(!success){
                revert("contract have no function of tokenReceive()!!");
            }
        }
        
    }
    function isContract(address to) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(to)
        }
        return size > 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CloneFactory.sol";
import "./Erc20_Token.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
contract Factory is CloneFactory{
    address public my_token;

    constructor(address _token) {
        token = _token;
    }

    
    
    function deployInscription(string memory name, 
      string memory symbol, 
      uint totalSupply, 
      uint perMint) public returns (address){
        address clone = createClone(my_token);
        Erc20_Token(clone).init(name,symbol,totalSupply,perMint);
        return clone;
    }

    function mintInscription(address tokenAddr) public{
        Erc20_Token(tokenAddr).mint();
    }
}





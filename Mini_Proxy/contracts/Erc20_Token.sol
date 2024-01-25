// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
contract Erc20_Token is ERC20Upgradeable{

    uint immutable public perMint;
    uint public totalSupply;
    mapping(address=>uint) private mint_amount;
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    event Mint(address,uint);
    
    function init(string memory name,string memory symbol, 
      uint _totalSupply, 
      uint _perMint) public Initializable{
        require(_totalSupply > _perMint,"too small totalSupply!");
        __ERC20_init(name,symbol);
        perMint = _perMint;
        totalSupply = _totalSupply;
         }

    function mint() public{
        require(mint_amount[_msgSender()]<perMint,"already minted!");
        _mint(_msgSender(),perMint);
        mint_amount[_msgSender()] += perMint;
        totalSupply -= perMint;
        emit Mint(_msgSender(),perMint);
    }

    
    //回调功能的 ERC20Token
    function transferWithCallback_ERC20(address recipient, uint amount) external {
        transfer(recipient, amount);
        callTokenReceive(recipient,amount,"");
    }

    function transferWithCallback_NFT(address recipient, uint amount,bytes memory token_id) external {
        transfer(recipient, amount);
        callTokenReceive(recipient,amount,token_id);
    }
    

    
    function callTokenReceive(address to,uint amount,bytes memory data) internal {
        if(isContract(to)){
            (bool success,) = to.call(abi.encodeWithSignature("tokenReceive(address,uint,bytes)",msg.sender,amount,data));
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
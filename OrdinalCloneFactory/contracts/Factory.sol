// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/Implementation.sol";
import "./interface/IDexRouter.sol";
contract Factory {
    address public immutable token;
    address public dex;
    address public owner;
    uint rate; //1 eth ==> 1*rate token
    address[] public tokenList;  //tokens to be minted
    mapping(address=>bool)isOrdinalToken;
    
    event TokenCreated(address token,address creator);
    event Mint(address minter,address token,uint amount);

    constructor(address _token, address _dex, uint _rate) {
        token = _token;
        dex = _dex;
        rate = _rate;
        owner = msg.sender;
    }

    modifier is_OrdinalToken(address _token){
        require(isOrdinalToken[_token]==true,"this token not create by factory");
        _;
    }

    function create(string memory name, string memory symbol) external {
        address new_token = Clones.clone(token);
        Implementation(new_token).init(name, symbol);
        tokenList.push(new_token);
        isOrdinalToken[new_token] = true;
        emit TokenCreated(new_token,msg.sender);
    }

    function mint(address ord_token) external payable is_OrdinalToken(ord_token){
        uint amount = (msg.value * rate) / 2;
        require(amount > 0, "eth must be over 0!");
        Implementation(ord_token).mint(msg.sender, amount);
        Implementation(ord_token).mint(address(this), amount);
        //用户铸币的费用一半费用（ETH）和 获得的一半的铭⽂ Token 组合加入到 DEX 中作为流动性
        IERC20(ord_token).approve(dex, msg.value/2);
        IDexRouter(dex).addLiquidityETH{value:msg.value/2}(ord_token,amount,0, 0,address(this),block.timestamp);
        emit Mint(msg.sender, ord_token,amount);
    }
}

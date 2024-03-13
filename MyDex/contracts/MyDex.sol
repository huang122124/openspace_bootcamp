//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyDex {
    address public uniswapV2Router02;
    address public owner;
    address public WETH;

    constructor(address _uniswapV2Router02,address _WETH) {
        require(_uniswapV2Router02 != address(0), "empty address!");
        uniswapV2Router02 = _uniswapV2Router02;
        WETH = _WETH;
        owner = msg.sender;
    }

    /**
     * @dev 卖出ETH，兑换成 buyToken
     *      msg.value 为出售的ETH数量
     * @param buyToken 兑换的目标代币地址
     * @param minBuyAmount 要求最低兑换到的 buyToken 数量
     */
    function sellETH(address buyToken, uint256 minBuyAmount) external payable {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = buyToken;
        (bool success, ) = uniswapV2Router02.call{value: msg.value}(
            abi.encodeWithSignature(
                "swapETHForExactTokens(uint,address[],address,uint)",
                minBuyAmount,
                path,
                msg.sender,
                block.timestamp
            )
        );
        require(success, "swap faield!");
    }

    /**
     * @dev 买入ETH，用 sellToken 兑换
     * @param sellToken 出售的代币地址
     * @param sellAmount 出售的代币数量
     * @param minBuyAmount 要求最低兑换到的ETH数量
     */
    function buyETH(
        address sellToken,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external {
        require(
            IERC20(sellToken).transferFrom(
                msg.sender,
                address(this),
                sellAmount
            ),
            "tx failed!"
        );
        IERC20(sellToken).approve(uniswapV2Router02,sellAmount);
        //require(,"approve failed");
        address[] memory path = new address[](2);
        path[0] = sellToken;
        path[1] = WETH;
        (bool success, ) = uniswapV2Router02.call{value: sellAmount}(
            abi.encodeWithSignature(
                "swapTokensForExactETH(uint,uint,address[],address,uint)",
                sellAmount,
                minBuyAmount,
                path,
                msg.sender,
                block.timestamp
            )
        );
        require(success, "swap faield!");
    }
}

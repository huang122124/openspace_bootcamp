// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//reference:  https://learnblockchain.cn/article/4410

contract NftMarketplace is ReentrancyGuard,IERC721Receiver{
    address public immutable nft;
    address public immutable erc20_token;
    mapping (uint =>uint) public tokenPrice;
    mapping (uint =>address) public tokenSeller;

    constructor(address nft_addr,address token_addr){
        nft = nft_addr;
        erc20_token = token_addr;
    }

    modifier notList(uint token_id){
        _;
    }

    modifier isOwner(uint token_id){
        _;
    }

    modifier notLowerPrice(uint tokenID,uint amount){
        require(tokenPrice[tokenID]<= amount,"price too low");
        _;
    }

    event ItemListed(address,uint,uint);
    event NFTSold(address,uint,uint);
    error NotApprovedForMarketplace();

    function cancelListing(address nft_addr,uint token_id) external {

    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4) {
      return this.onERC721Received.selector;
    }

    function listItem(
        uint token_id,
        uint amount
        ) 
        external notList(token_id) isOwner(token_id)
    {
        bool approved = checkApproval(token_id);
        if (!approved){
            revert NotApprovedForMarketplace();
        }
        IERC721(nft).safeTransferFrom(msg.sender,address(this),token_id,"");
        tokenPrice[token_id] = amount;
        tokenSeller[token_id] = msg.sender;
        emit ItemListed(msg.sender, token_id, amount);
    }


    function buyNFT(uint tokenID,uint amount)public notLowerPrice(tokenID,amount){
        require(IERC721(nft).ownerOf(tokenID) == address(this),"owner not in this ");
        bool success = IERC20(erc20_token).transferFrom(msg.sender,tokenSeller[tokenID],amount);  //发送token到卖家
        if(success){
            IERC721(nft).safeTransferFrom(address(this),msg.sender,tokenID,"");
        }
        emit NFTSold(msg.sender,tokenID,amount);
    }

    function checkApproval(uint token_ID)internal view returns (bool){
        address x = IERC721(nft).getApproved(token_ID);
        return x == address(this);
    }


}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

//V2 version NftMarketplace  第二版本,加入离线签名上架 NFT 功能方法(签名内容:tokenId, 价格),实现用户一次性
//setApproveAll 给 NFT 市场合约,每次上架时使用签名上架。

// Author:Kason
contract Permit_NftMarketplaceV2 is IERC721Receiver, Initializable {
    address public owner;
    address public nft;
    address public erc20_token;
    mapping(uint => uint) public tokenPrice;
    mapping(uint => address) public tokenSeller;
    bytes32 private sign; //签名

    using SafeERC20 for IERC20;
    using MessageHashUtils for bytes32;
    using ECDSA for bytes;

    function initialize(
        address nft_addr,
        address token_addr
    ) public initializer {
        nft = nft_addr;
        erc20_token = token_addr;
        owner = msg.sender;
    }

    modifier isOwner(uint token_id) {
        require(
            IERC721(nft).ownerOf(token_id) == msg.sender,
            "Not item's owner!"
        );
        _;
    }

    

    event NFTSold(address from,address to, uint token_ID, uint amount);
    event ApprovedAllForMarketplace(address);
    event Thanks();
    error NotApprovedForMarketplace();

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function tokenReceived(
        address sender,
        uint amount,
        bytes memory data
    ) external {
        if(address(this).balance >= amount){
            IERC20(erc20_token).safeTransfer(owner,address(this).balance);
            emit Thanks();
        }
    }


   

    function buyNFT(
        uint tokenID,
        uint amount,
        uint _salt,
        bytes memory _signature
    ) public {
        require(
            verify_signature(tokenID, amount, _salt, _signature),
            "signature not avialble!"
        ); //检查nft owner是否签名上架
        address nft_owner = IERC721(nft).ownerOf(tokenID);
        IERC20(erc20_token).safeTransferFrom(
            msg.sender,
            nft_owner,
            amount
        ); //发送token到卖家
        IERC721(nft).safeTransferFrom(
                nft_owner,
                msg.sender,
                tokenID
            );
        emit NFTSold(nft_owner,msg.sender, tokenID, amount);
    }

    


    //this function should be called by front-end
    function checkNFTApproved(uint tokenId) public view returns(bool){
        address _owner = IERC721(nft).ownerOf(tokenId);
        bool approved = IERC721(nft).isApprovedForAll(
            _owner,
            address(this)
        );
        return approved;
    }

    function isNFTOwner(uint token_id) public view returns (bool){
        return IERC721(nft).ownerOf(token_id) == msg.sender;
    }


    function verify_signature(
        uint tokenID,
        uint amount,
        uint _salt,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 msg_hash = keccak256(abi.encodePacked(tokenID, amount, _salt));
        bytes32 eth_sign_msg_hash = MessageHashUtils.toEthSignedMessageHash(
            msg_hash
        );
        return IERC721(nft).ownerOf(tokenID) == ECDSA.recover(eth_sign_msg_hash, signature);
    }
}

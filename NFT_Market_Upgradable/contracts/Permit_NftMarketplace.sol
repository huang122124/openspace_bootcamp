// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

//reference:  https://learnblockchain.cn/article/4410

contract Permit_NftMarketplace is IERC721Receiver, Initializable{
    address public owner;
    address public nft;
    address public erc20_token;
    mapping(uint => uint) public tokenPrice;
    mapping(uint => address) public tokenSeller;
    bytes32 private sign; //签名

    using MessageHashUtils for bytes32;
    using ECDSA for bytes;

    function initialize(address nft_addr, address token_addr) public initializer {
        nft = nft_addr;
        erc20_token = token_addr;
        owner = msg.sender;
    }

    modifier notList(uint token_id) {
        require(
            tokenSeller[token_id] == address(0) && tokenPrice[token_id] == 0,
            "item is in the list!"
        );
        _;
    }

    modifier isOwner(uint token_id) {
        require(
            IERC721(nft).ownerOf(token_id) == msg.sender,
            "Not item's owner!"
        );
        _;
    }

    modifier isSeller(uint token_id) {
        require(
            tokenSeller[token_id] == msg.sender,
            "You are not item's seller!"
        );
        _;
    }

    modifier notLowerPrice(uint tokenID, uint amount) {
        require(tokenPrice[tokenID] <= amount, "price too low");
        _;
    }

    event ItemListed(address, uint, uint);
    event ItemUnList(address, uint);
    event NFTSold(address, uint, uint);

    error NotApprovedForMarketplace();

    function cancelListing(uint token_id) external isSeller(token_id) {
        nft_unlist(token_id); //下架
    }

    function nft_unlist(uint token_id) internal {
        address nft_owner = tokenSeller[token_id]; //下架nft
        require(
            IERC721(nft).ownerOf(token_id) == address(this),
            "nft not in this market!"
        );
        IERC721(nft).safeTransferFrom(address(this), msg.sender, token_id); //退还nft给卖家
        delete tokenSeller[token_id];
        delete tokenPrice[token_id];
        emit ItemUnList(nft_owner, token_id);
    }

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
        uint amout,
        bytes memory data
    ) external {
        buyNFTwithTokenReceived(sender, amout, data);
    }

    function listItem(
        uint token_id,
        uint amount
    ) external notList(token_id) isOwner(token_id) {
        bool approved = checkApproval(token_id);
        if (!approved) {
            revert NotApprovedForMarketplace();
        }
        IERC721(nft).safeTransferFrom(msg.sender, address(this), token_id, "");
        tokenPrice[token_id] = amount;
        tokenSeller[token_id] = msg.sender;
        emit ItemListed(msg.sender, token_id, amount);
    }

    function buyNFTwithTokenReceived(
        address buyer,
        uint amout,
        bytes memory data
    ) internal {
        uint256 token_id = abi.decode(data, (uint256));
        require(amout >= tokenPrice[token_id], "not enough money!");
        if (checkApproval(token_id)) {
            IERC721(nft).safeTransferFrom(
                tokenSeller[token_id],
                buyer,
                token_id
            );
            IERC20(erc20_token).transfer(buyer, amout);
            nft_unlist(token_id); //买完从列表下架
        }
    }

    function buyNFT(
        uint tokenID,
        uint amount,
        address _user,
        uint _salt,
        bytes memory _signature
    ) public notLowerPrice(tokenID, amount){
        require(
            IERC721(nft).ownerOf(tokenID) == address(this),
            "owner not in this market!!"
        );
        require(verify_signature(tokenID,amount,_user,_salt, _signature));
        bool success = IERC20(erc20_token).transferFrom(
            msg.sender,
            tokenSeller[tokenID],
            amount
        ); //发送token到卖家
        if (success) {
            IERC721(nft).safeTransferFrom(
                address(this),
                msg.sender,
                tokenID,
                ""
            );
            nft_unlist(tokenID);
        }
        emit NFTSold(msg.sender, tokenID, amount);
    }

    function checkApproval(uint token_ID) internal view returns (bool) {
        address x = IERC721(nft).getApproved(token_ID);
        return x == address(this);
    }

    function verify_signature(
        uint tokenID,
        uint amount,
        address _user,
        uint _salt,
        bytes memory signature
    ) public view returns (bool) {
        bytes32  msg_hash = keccak256(abi.encodePacked(tokenID,amount,_user,_salt));
        bytes32  eth_sign_msg_hash = MessageHashUtils.toEthSignedMessageHash(msg_hash);
    
        return owner == ECDSA.recover(eth_sign_msg_hash, signature);
    }

    

    
}

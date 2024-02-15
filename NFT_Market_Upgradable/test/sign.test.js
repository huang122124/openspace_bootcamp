const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("对多个地址用户进行签名，在合约中进行验签", function () {
  it("verify sign", async function () {
    // Contracts are deployed using the first signer/account by default
    const [signer, addr1] = await ethers.getSigners()
    const white_list = [addr1.address, '0x123456', '0x654321']    //WhitleList
    const nft_market = await ethers.deployContract("Permit_NftMarketplace")
    console.log("signer:"+signer.address)
    console.log("addr1:"+addr1.address);
    const nft = await nft_market.getAddress()
    console.log("nft_market deployed to :"+nft)
    await nft_market.initialize('0xf0f93144CECa5F5bbE6B953bDC3dD4991c2Ab7d3','0x9bE7bbB4659109E56EdC7637A5619DCB5B9a43bF')
    expect(white_list).to.include(addr1.address)    //判断是否在白名单内。实际应发送用户地址到后端进行判断
    // 对消息进行签名
    const token_id = 1
    const amount = 3
    const salt = 888
    const msg_hash = ethers.solidityPackedKeccak256(["uint256","uint256","address","uint256"], [ token_id,amount, addr1.address,salt]);
    const sign = await signer.signMessage(ethers.getBytes(msg_hash));
    console.log("msg_hash:"+msg_hash);
    //调用合约进行验证
    let verified = await nft_market.verify_signature(token_id,amount,addr1.address,salt,sign)
    console.log("期望验证成功：", verified);
    expect(verified).to.equal(true);

  })
});


const {
  loadFixture
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MultiSigWallet", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployContract() {
    const [a1, a2, a3, a4, a5, a6] = await ethers.getSigners();
    console.log([a1.address, a2.address, a3.address, a4.address, a5.address]);
    wallet = await ethers.deployContract("MultiSigWallet", [[a1.address, a2.address, a3.address, a4.address, a5.address], 2])
    return { wallet, a1, a2, a3, a4, a5, a6 }
  }

  it("Should set the right owners", async function () {
    const { wallet, a1, a2, a3, a4, a5, a6 } = await loadFixture(deployContract);
    expect(await wallet.getOwners()).to.deep.equal([a1.address, a2.address, a3.address, a4.address, a5.address]);
    expect(await wallet.min_confirm()).to.equal(2);
  });

  it("transaction number should be 1", async function () {
    const{wallet} = await loadFixture(deployContract);
    let data = ethers.encodeBytes32String("aaa")
    await wallet.submitTransaction('0x06129EBA0638D48D819b422ef24917e06F11cb1F', 0, data)
    expect(await wallet.getTransactionNumber()).to.equal(1)
  })

  it("non-owner can't submit tx", async function () {
    const{wallet,a6} = await loadFixture(deployContract);
    let data = ethers.encodeBytes32String("aaa")
    expect(wallet.connect(a6).submitTransaction('0x06129EBA0638D48D819b422ef24917e06F11cb1F', 0, data))
     .to.be.revertedWith("not Owner!")
  })


});

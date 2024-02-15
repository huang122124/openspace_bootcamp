// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades } = require("hardhat");
const nft_market_addr = '0x9CCdFf057dD4dcA9CC845378eC4960A56ED150b6'
async function main() {
  console.log(nft_market_addr," original market(proxy) address")
  const Nft_marketV2 = await ethers.getContractFactory("Permit_NftMarketplaceV2");
  console.log("upgrade to marketV2...")
  let nft_marketV2 = await upgrades.upgradeProxy(nft_market_addr,Nft_marketV2)

  console.log("nft_market(proxy)V2 address(should be the same):",await nft_marketV2.getAddress());
  console.log(await upgrades.erc1967.getImplementationAddress(await nft_marketV2.getAddress())," getImplementationAddress")
  console.log(await upgrades.erc1967.getAdminAddress(await nft_marketV2.getAddress()), " getAdminAddress")  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
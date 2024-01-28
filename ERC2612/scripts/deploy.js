// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const nft_market = await hre.ethers.deployContract("Permit_NftMarketplace", 
    [0xf0f93144CECa5F5bbE6B953bDC3dD4991c2Ab7d3,0x9bE7bbB4659109E56EdC7637A5619DCB5B9a43bF], {});
  await nft_market.waitForDeployment();

  console.log(
    'deployed to ${nft_market.target}'
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

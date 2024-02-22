// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const [a1, a2, a3, a4, a5, a6] = await hre.ethers.getSigners();
  const mswallet = await hre.ethers.deployContract("MultiSigWallet", [[a1, a2, a3, a4, a5, a6],2]);

  await mswallet.waitForDeployment();

  console.log(
    `contract deployed to ${mswallet.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

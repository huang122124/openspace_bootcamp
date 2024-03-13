require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.23",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/3b8a4ff7ba6240e7b42be7f38d44e346`,
      accounts: ['8f5f5c4a6abf7ff59f4d48bc35c3b8ec0dd69d333354f8e397d6f2babca7d0b2']
    }
  },
  etherscan: {
    apiKey: "M2J52SCD1GJ4633TZ495MDRPIMPVYZZWF6",
  },
  sourcify: {
    enabled: true
  }
};
const { ProxyAgent, setGlobalDispatcher } = require("undici")
const proxyAgent = new ProxyAgent("http://127.0.0.1:7890") // change to yours
setGlobalDispatcher(proxyAgent)
// test/1.market_proxy
// Load dependencies
const { expect } = require('chai');


let nft_market;
let nft_marketV2;

let proxyAddress
let implementationAddress
let adminAddress

// Start test block
describe('Nft_market (proxy) V2', function () {
    beforeEach(async function () {
        let Nft_market = await ethers.getContractFactory("Permit_NftMarketplace");
        let Nft_marketV2 = await ethers.getContractFactory("Permit_NftMarketplace");
        nft_market = await upgrades.deployProxy(Nft_market, ["0xf0f93144CECa5F5bbE6B953bDC3dD4991c2Ab7d3", "0x9bE7bbB4659109E56EdC7637A5619DCB5B9a43bF"],
            { initializer: 'initialize' });
        proxyAddress = await nft_market.getAddress()
        implementationAddress = await upgrades.erc1967.getImplementationAddress(nft_market_addr)
        adminAddress = await upgrades.erc1967.getAdminAddress(nft_market_addr)

        nft_marketV2 = await upgrades.upgradeProxy(nft_market_addr,Nft_marketV2)
        
    });

    // Test case
    it('V2 should be same with V1 addresses ', async function () {
        let proxyAddressV2 = await nft_marketV2.getAddress()
        let implementationAddressV2 = await upgrades.erc1967.getImplementationAddress(proxyAddressV2)
        let adminAddressV2 = await upgrades.erc1967.getAdminAddress(proxyAddressV2)
        expect(proxyAddressV2.toString()).not.to.equal(proxyAddress)    //新部署的proxyV2地址不一样
        expect(implementationAddressV2.toString()).to.equal(implementationAddress)
        expect(adminAddressV2.toString()).to.equal(adminAddress)
        // Test if the returned value is the same one
        // Note that we need to use strings to compare the 256 bit integers
        let nft_addrV2 = await nft_marketV2.nft()
        expect(nft_addrV2.toString()).to.equal('0xf0f93144CECa5F5bbE6B953bDC3dD4991c2Ab7d3');
    });

    it('should retrieve value previously stored ', async function () {
        expect(await nft_marketV2.nft()).to.equal('0xf0f93144CECa5F5bbE6B953bDC3dD4991c2Ab7d3')
        expect(await nft_marketV2.erc20_token()).to.equal('0x9bE7bbB4659109E56EdC7637A5619DCB5B9a43bF')
    })
});
// test/1.market_proxy
// Load dependencies
const { expect } = require('chai');

let Nft_market;
let nft_market;

// Start test block
describe('Nft_market (proxy)', function () {
    beforeEach(async function () {
        const signers = await ethers.getSigners()
        console.log(signers[0].address," signer");
        Nft_market = await ethers.getContractFactory("Permit_NftMarketplace");
        nft_market = await upgrades.deployProxy(Nft_market, ["0xf0f93144CECa5F5bbE6B953bDC3dD4991c2Ab7d3", "0x9bE7bbB4659109E56EdC7637A5619DCB5B9a43bF"],
            { initializer: 'initialize' });
    });

    // Test case
    it('retrieve returns a value previously initialized', async function () {
        nft_market_addr = await nft_market.getAddress()
        console.log(nft_market_addr, " nft_market(proxy) address")
        console.log(await upgrades.erc1967.getImplementationAddress(nft_market_addr), " getImplementationAddress")
        console.log(await upgrades.erc1967.getAdminAddress(nft_market_addr), " getAdminAddress")
        // Test if the returned value is the same one
        // Note that we need to use strings to compare the 256 bit integers
        let nft_addr = await nft_market.nft()
        console.log("nft_addr:",nft_addr);
        let owner_addr = await nft_market.owner()
        console.log("owner_addr:",owner_addr);
        expect(nft_addr.toString()).to.equal('0xf0f93144CECa5F5bbE6B953bDC3dD4991c2Ab7d3');
    });
});
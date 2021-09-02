const NftContract = artifacts.require("./NftContract.sol");

contract("NftContract test", async accounts => {

    it("mint", async () => {
        let instance = await NftContract.deployed();
        let supply = await instance.TOTAL_SUPPLY();

        for (let i = 0; i < supply; i++) {
            await instance.mintNft();
        }
    });

})
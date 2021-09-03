const SharpeFinanceCattle = artifacts.require("./SharpeFinanceCattle.sol");

contract("SharpeFinanceCattle", async accounts => {

    beforeEach(async function () {
        this.instance = await SharpeFinanceCattle.new({from: accounts[0]})
    })

    it("mint", async function () {
        let supply = await this.instance.MAX_SUPPLY();

        for (let i = 0; i < supply; i++) {
            let user = accounts[getRandomInt(accounts.length)]
            await this.instance.mintNft({from: user, value: 61800000000000000});
        }

        for (let i = 0; i < accounts.length; i++) {
            let s = accounts[i] + ":::" + await this.instance.balanceOf(accounts[i]);
            console.log(s)
        }

        let balance = await this.instance.getBalance({from: accounts[0]})
        console.log("contract balance:::" + balance)
        console.log("balance:::" + await web3.eth.getBalance(accounts[0]));

        await this.instance.withdraw(balance, {from: accounts[0]})

        balance = await this.instance.getBalance({from: accounts[0]})
        console.log("contract balance:::" + balance)
        console.log("balance:::" + await web3.eth.getBalance(accounts[0]));
    });

    function getRandomInt(max) {
        return Math.floor(Math.random() * max);
    }
})
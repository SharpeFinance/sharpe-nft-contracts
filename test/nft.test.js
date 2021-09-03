const SharpeFinanceCattle = artifacts.require("./SharpeFinanceCattle.sol");

contract("SharpeFinanceCattle", async accounts => {

    beforeEach(async function () {
        this.instance = await SharpeFinanceCattle.new({from: accounts[0]})
    })

    it("mint", async function () {
        let supply = await this.instance.MAX_SUPPLY();

        for (let i = 0; i < supply; i++) {
            let user = accounts[getRandomInt(accounts.length)]
            await this.instance.mintNft({from: user});

            let ownerTokens = await this.instance.ownerTokens({from:user});
            let s = toString(ownerTokens);
            console.log(s)
        }

        for (let i = 0; i < accounts.length; i++) {
            let user = accounts[i];
            let ownerTokens = await this.instance.ownerTokens({from:user});
            let s = user + ":::" + ownerTokens
            console.log(s)
        }
    });

    it("one", async function () {
        let supply = await this.instance.MAX_SUPPLY();

        for (let i = 0; i < supply; i++) {
            let user = accounts[getRandomInt(accounts.length)]
            await this.instance.mintNft({from: user});

            let ownerTokens = await this.instance.ownerTokens({from:user});
            let s = toString(ownerTokens);
            console.log(s)
        }

        for (let i = 0; i < accounts.length; i++) {
            let user = accounts[i];
            let ownerTokens = await this.instance.ownerTokens({from:user});
            let s = user + ":::" + ownerTokens
            console.log(s)
        }
    });

    it("two", async function () {
        let supply = await this.instance.MAX_SUPPLY();

        for (let i = 0; i < supply; i++) {
            let user = accounts[getRandomInt(accounts.length)]
            await this.instance.mintNft({from: user});

            let ownerTokens = await this.instance.ownerTokens({from:user});
            let s = toString(ownerTokens);
            console.log(s)
        }

        for (let i = 0; i < accounts.length; i++) {
            let user = accounts[i];
            let ownerTokens = await this.instance.ownerTokens({from:user});
            let s = user + ":::" + ownerTokens
            console.log(s)
        }
    });

    function toString(tokens) {
        let s = "";
        for (let i = 0; i < tokens.length; i++) {
            let token = tokens[i];
            s = s + token.toNumber() + ","
        }
        return s
    }

    function getRandomInt(max) {
        return Math.floor(Math.random() * max);
    }
})
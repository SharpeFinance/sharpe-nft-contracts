const SharpeFinanceCattle = artifacts.require("./SharpeFinanceCattle.sol");
const BN = web3.utils.BN;

contract("SharpeFinanceCattle", async accounts => {

    let admin = accounts[0];
    let whiteListCount = 5;
    let nonOwner = accounts[3];

    const whiteListAddress = [
        web3.eth.accounts.create().address,
        web3.eth.accounts.create().address,
        web3.eth.accounts.create().address,
    ];

    beforeEach(async function () {
        this.instance = await SharpeFinanceCattle.new("", 1, 1, {from: admin})
    })

    async function mintAll(instance) {
        await instance.startMint({ from: admin });
        let supply = await instance.MAX_SUPPLY();
        let tokenPrice = await instance.TOKEN_PRICE();
        let accountPer = 10;
        let totalAmount = new BN(0);
        let totalMint = 0;
        let totalGasUsed = 0;

        for (let index = 0; index < accounts.length; index++) {
            const account = accounts[index];
            for (let index = 0; index < accountPer; index++) {
                totalAmount = totalAmount.add(new BN(tokenPrice));
                const mintResult = await instance.mintNft({from: account, value: tokenPrice });
                totalMint++;
                totalGasUsed += mintResult.receipt.gasUsed
            }
        }
        return {
            supply,
            accounts: accounts,
            totalAmount,
            totalMint,
            accountPer,
            totalGasUsed,
            tokenPrice
        }
    }

    async function mintByWhiteList(instance, account, accountPer = 5) {
        const presaleStart_ = Math.floor(Date.now() / 1000);
        const mintStart_ = presaleStart_ + 100000;
        await instance.setStartTime(mintStart_, presaleStart_);
        await instance.startMint({ from: admin });
        let supply = await instance.MAX_SUPPLY();
        let tokenPrice = await instance.TOKEN_PRICE();
        let totalAmount = new BN(0);
        let totalMint = 0;
        let totalGasUsed = 0;

        for (let index = 0; index < accountPer; index++) {
            totalAmount = totalAmount.add(new BN(tokenPrice));
            const mintResult = await instance.mintNft({from: account, value: tokenPrice });
            totalMint++;
            totalGasUsed += mintResult.receipt.gasUsed
        }

        return {
            supply,
            accounts: accounts,
            totalAmount,
            totalMint,
            accountPer,
            totalGasUsed,
            tokenPrice
        }
    }

    it("mint one token", async function () {
        let nonOwner = accounts[3];
        let tokenPrice = await this.instance.TOKEN_PRICE();
        await this.instance.startMint({ from: admin });
        await this.instance.mintNft({from: nonOwner, value: tokenPrice });
        const userHold = await this.instance.balanceOf(nonOwner);
        assert.equal(userHold.toString(), '1', "user should hold one");
    });

    it("mint multiple token", async function () {
        const result = await mintAll(this.instance);
        const nowTotal = await this.instance.totalSupply();
        assert.equal(nowTotal.toString(), result.totalMint.toString(), "totalSupply should be same");
        for (let i = 0; i < result.accounts.length; i++) {
            const balanceOf = await this.instance.balanceOf(accounts[i]);
            assert.equal(balanceOf.toString(), result.accountPer.toString(), "account Holder Balance should be same");
        }
    });

    it("after mint token check balance", async function () {
        const beforeBalance =  await web3.eth.getBalance(this.instance.address);
        const result = await mintAll(this.instance);
        const afterBalance = await web3.eth.getBalance(this.instance.address);
        const nftSaleAmount  = new BN(afterBalance).sub(new BN(beforeBalance));
        assert.equal(nftSaleAmount.toString(), result.totalAmount.toString(), 'total sale amount not match');
    });

    it("addToWhiteList", async function () {
        await this.instance.addToWhiteList(whiteListAddress);
        for (let index = 0; index < whiteListAddress.length; index++) {
           const whiteListAddr = whiteListAddress[index];
           const count = await this.instance.whiteList(whiteListAddr);
           assert.equal(count.toString(), whiteListCount+ '', "account Holder Balance should be same");
       }
    })

    it("addToRewardList by nonOwner", async function () {
        let capError = null
        try {
            await this.instance.addToRewardList(whiteListAddress, {
                from: nonOwner 
            });
        } catch (e) {
            capError = e;
        }
        assert.ok(capError && capError.toString().indexOf('revert Admin role requested.') > -1, 'should reverted');
    });

    it("withdraw by admin", async function () {
        const result = await mintAll(this.instance);
        const beforeBalanceOfAdmin = await web3.eth.getBalance(admin);
        const afterMintContractBalance = await web3.eth.getBalance(this.instance.address);
        let capError = null;
        try {
            await this.instance.withdraw({ from: admin });
        } catch (e) {
            capError = e;
        }
        const contractBalance = await web3.eth.getBalance(this.instance.address);
        assert.equal(contractBalance, '0', 'after withdraw should be zero');
        const afterBalanceOfAdmin = await web3.eth.getBalance(admin);
        const balanceAmount = (afterBalanceOfAdmin - beforeBalanceOfAdmin);
        const gasCost = afterMintContractBalance - balanceAmount;
        if (result.tokenPrice > 0) {
            assert.ok(gasCost < 1e14, 'after withdraw should be admin shoule hold all Contract Balance');
        } else {
            assert.ok(capError.toString().indexOf('Insufficient fund') > -1, 'should reverted');
        }
    });

    it("withdraw by none admin", async function () {
        await mintAll(this.instance);
        let capError = null
        try {
            await this.instance.withdraw({ from: nonOwner });
        } catch (e) {
            capError = e;
        }
        assert.ok(capError && capError.toString().indexOf('revert Admin role requested.') > -1, 'should reverted');
    });

    it("claimReward by not in rewardList", async function () {
        let capError = null
        try {
            await this.instance.claimReward({ from: nonOwner });
        } catch (e) {
            capError = e;
        }
        assert.ok(capError && capError.toString().indexOf('Reward qualification requested') > -1, 'should reverted');
    });

    it("claimReward by in rewardList", async function () {
        await this.instance.addToRewardList([
            nonOwner
        ], {
            from: admin
        });
        let capError = null
        try {
            await this.instance.claimReward({ from: nonOwner });
        } catch (e) {
            capError = e;
        }
        assert.ok(capError == null, 'should reverted');
    });

    it("giveaway by admain", async function () {
        let capError = null
        try {
            await this.instance.giveaway([nonOwner], { from: admin });
        } catch (e) {
            capError = e;
        }
        assert.ok(capError == null, 'should not reverted');
        const userHold = await this.instance.balanceOf(nonOwner);
        assert.ok( userHold == '1', 'userHold reverted');
    });

    it("mint by whiteList with limit", async function () {
        await this.instance.addToWhiteList([nonOwner]);
        await mintByWhiteList(this.instance, nonOwner);
        const userHold = await this.instance.balanceOf(nonOwner);
        assert.ok( userHold == '5', 'userHold reverted');
    });

    it("mint by whiteList with over limit", async function () {
        await this.instance.addToWhiteList([nonOwner]);
        let capError = null
        try {
            await mintByWhiteList(this.instance, nonOwner, 6);
        } catch (e) {
            capError = e;
        }
        const userHold = await this.instance.balanceOf(nonOwner);
        assert.ok(userHold == '5', 'userHold reverted');
        assert.ok(capError != null, 'over limit reverted');
    });

    it("mint by not in whiteList", async function () {
        let capError = null
        try {
            await mintByWhiteList(this.instance, nonOwner, 6);
        } catch (e) {
            capError = e;
        }
        const userHold = await this.instance.balanceOf(nonOwner);
        assert.ok(userHold == '0', 'userHold reverted');
        assert.ok(capError != null, 'over limit reverted');
    });
})

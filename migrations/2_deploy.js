const SharpeFinanceCattle = artifacts.require("SharpeFinanceCattle");

module.exports = function (deployer) {
    //deployer.deploy(SharpeFinanceCattle, "ipfs://Qma4zuWaK11J1qcChzWMSmz3pfYYFu9dxg3eh4T5E3LVeJ/",1,1);
    deployer.deploy(
        SharpeFinanceCattle,
        "ipfs://QmdCURxxBqu54FkUHaZrX4ySRhSScvouaamhg7mWPmAcj7/",
        1,
        1
    );
};

const SharpeFinanceCattle = artifacts.require("SharpeFinanceCattle");

module.exports = function (deployer) {
    deployer.deploy(SharpeFinanceCattle, "ipfs://Qma4zuWaK11J1qcChzWMSmz3pfYYFu9dxg3eh4T5E3LVeJ/");
};

const SharpeFinanceCattle = artifacts.require("SharpeFinanceCattle");

module.exports = function (deployer) {
    deployer.deploy(SharpeFinanceCattle, "");
};

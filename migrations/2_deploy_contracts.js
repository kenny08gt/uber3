const SimpleStorage = artifacts.require("SimpleStorage");
const Uber3 = artifacts.require("Uber3");

module.exports = function(deployer) {  
  deployer.deploy(SimpleStorage);
  deployer.deploy(Uber3);
};
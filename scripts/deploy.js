// // We require the Hardhat Runtime Environment explicitly here. This is optional
// // but useful for running the script in a standalone fashion through `node <script>`.
// //
// // When running the script with `npx hardhat run <script>` you'll find the Hardhat
// // Runtime Environment's members available in the global scope.
const { ethers, upgrades } = require("hardhat");

const CONTRACT_ADR = "0x07701BFFF3Fce1B1e26805f3F32Dbfb91882bAAb";

async function main() {
  await initialDeploy();
}
async function initialDeploy() {
  // We get the contract to deploy
  const Contents = await ethers.getContractFactory("Contents");
  const contents = await upgrades.deployProxy(Contents,[], {initializer : "initialize"});
  await contents.deployed();
  console.log("deployed to " + contents.address);
  
}

async function upgrade() {
  const Contents = await ethers.getContractFactory("Contents");
  const contents = await upgrades.upgradeProxy(CONTRACT_ADR, Contents);
  await contents.deployed();
  console.log("upgrade to " + contents.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

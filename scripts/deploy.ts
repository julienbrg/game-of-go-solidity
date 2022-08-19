import { ethers } from "hardhat";

async function main() {

  const white = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";
  const black = "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2";
  const Go = await ethers.getContractFactory("Go");
  const go = await Go.deploy(white, black);
  await go.deployed();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

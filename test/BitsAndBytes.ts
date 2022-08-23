import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("BitsAndBytes", function () {
  async function bitsAndBytesDeployed() {
    const [francis] = await ethers.getSigners();
    const BitsAndBytes = await ethers.getContractFactory("BitsAndBytes");
    const bitsAndBytes = await BitsAndBytes.deploy();
    return { bitsAndBytes, francis};
  }

  describe("", function () {
    it("deployed", async function () {
      const { bitsAndBytes } = await loadFixture(bitsAndBytesDeployed);
    });
    
  });

  describe("", function () {
    it("tested", async function () {
        const { bitsAndBytes } = await loadFixture(bitsAndBytesDeployed);
        console.log("    ", await bitsAndBytes.checkMe());
        console.log("    ");
    });
  });
});

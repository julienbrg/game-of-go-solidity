import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Playground", function () {
  async function playgroundDeployed() {
    const [francis] = await ethers.getSigners();
    const Playground = await ethers.getContractFactory("Playground");
    const playground = await Playground.deploy();
    return { playground, francis};
  }

  describe("Deployment", function () {
    it("should deploy the contract", async function () {
      const { playground } = await loadFixture(playgroundDeployed);
      expect(await playground.state()).to.equal("0x00");
    });
    
  });

  describe("Interactions", function () {
    it("should change state", async function () {
        const { playground } = await loadFixture(playgroundDeployed);
        console.log("");
        await playground.fromEmptyToBlack();
        await playground.fromEmptyToWhite();
        await playground.fromBlackToEmpy();
        await playground.fromWhiteToEmpy();
    });
  });
});

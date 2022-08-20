import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Go", function () {
  async function startNewMatch() {
    const [deployer, white, black, attacker] = await ethers.getSigners();
    const Go = await ethers.getContractFactory("Go");
    const go = await Go.deploy(white.address, black.address);
    return { go, deployer , white, black, attacker};
  }

  describe("Deployment", function () {
    it("Should set the right players", async function () {
      const { go, white, black, attacker } = await loadFixture(startNewMatch);
      expect(await go.white()).to.equal(white.address);
      expect(await go.black()).to.equal(black.address);
      expect(go.connect(attacker).play(1,1)).to.be.revertedWith("CALLER_IS_NOT_ALLOWED_TO_PLAY");
    });
  });

  describe("Interactions", function () {
    it("Should play one move", async function () {
      const {go, white, black, attacker } = await loadFixture(startNewMatch);
      expect(go.connect(white).play(1,1)).to.be.revertedWith("NOT_YOUR_TURN");
      await go.connect(black).play(1,1);
      expect(go.connect(white).play(1,1)).to.be.revertedWith("CANNOT_PLAY_HERE");
      expect(go.connect(attacker).play(1,1)).to.be.revertedWith("CALLER_IS_NOT_ALLOWED_TO_PLAY");
    });
  });
});

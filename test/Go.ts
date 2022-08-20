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
    it("Should return the intersection id", async function () {
      const {go, black } = await loadFixture(startNewMatch);
      await go.connect(black).play(1,1);
      expect(await go.getIntersectionId(1,1)).to.equal(4);
    });
    it("Should be out off board", async function () {
      const {go, black, white } = await loadFixture(startNewMatch);
      await go.connect(black).play(1,1);
      expect(await go.getIntersectionId(1,3)).to.be.gt(8);
      expect(await go.isOffBoard(1,3)).to.equal(true);
      expect(go.connect(white).play(1,4)).to.be.revertedWith("OFF_BOARD");
    });
    it("Should return the 4 neighbors", async function () {
      const {go, black } = await loadFixture(startNewMatch);
      await go.connect(black).play(1,1);
      const target = await go.getIntersectionId(1,1) ;
      expect((await go.getNeighbors(target)).east ).to.equal(3);
      expect((await go.getNeighbors(target)).west ).to.equal(5);
      expect((await go.getNeighbors(target)).north ).to.equal(7);
      expect((await go.getNeighbors(target)).south ).to.equal(1);
    });
    it("Should pass", async function () {
      const {go, black } = await loadFixture(startNewMatch);
      await go.connect(black).pass();
      expect(await go.blackPassedOnce()).to.equal(true);
    });
    it("Should end the game", async function () {
      const {go, black, white } = await loadFixture(startNewMatch);
      await go.connect(black).pass();
      await go.connect(white).play(1,2);
      expect(go.connect(black).pass()).to.be.revertedWith("MISSING_TWO_CONSECUTIVE_PASS");
      await go.connect(black).pass();
      await go.connect(white).pass();
      await go.connect(black).pass();
      expect(await go.blackScore()).to.equal(1);
    });
  });
});

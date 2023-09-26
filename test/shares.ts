import { BondingToken, DiBsShares } from "../typechain-types";
import { ethers } from "hardhat";
import { BancorFormula } from "../typechain-types/BancorFormula";

import { expect } from "chai";

const zeroAddress = "0x0000000000000000000000000000000000000000";

describe("Shares", () => {
  let shares: DiBsShares;
  let bondingToken: BondingToken;
  let curve: BancorFormula;
  let admin;

  const initPrice = 500000000;

  beforeEach(async () => {
    [admin] = await ethers.getSigners();
    const DiBsShares = await ethers.getContractFactory("DiBsShares");
    const BancorFormula = await ethers.getContractFactory("BancorFormula");

    curve = await BancorFormula.deploy();
    shares = await DiBsShares.deploy();
  });

  it("should have correct init price ", async () => {
    await shares.deployBondingToken(
      "DiBs",
      "DiBs",
      zeroAddress,
      1000000,
      100000000000,
      initPrice
    );

    const bondingToken = await ethers.getContractAt(
      "BondingToken",
      await shares.allBondingTokens(0)
    );

    const _initPrice = await bondingToken.spotPrice();
    expect(_initPrice).to.equal(initPrice);
  });
});

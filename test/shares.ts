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
    const BondingToken = await ethers.getContractFactory("BondingToken");
    const BancorFormula = await ethers.getContractFactory("BancorFormula");

    curve = await BancorFormula.deploy();
    shares = await DiBsShares.deploy();

    bondingToken = await BondingToken.deploy(
      "Dibs",
      "dibs",
      zeroAddress,
      500000,
      curve.getAddress(),
      admin.address,
      10000000000000,
      initPrice
    );
  });

  it("should have correct init price ", async () => {
    const initPrice = await bondingToken.spotPrice();
    expect(initPrice).to.equal(initPrice);
  });
});

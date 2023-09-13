import { BondingToken, DiBsShares } from "../typechain-types";
import { ethers } from "hardhat";
import { BancorFormula } from "../typechain-types/BancorFormula";


const zeroAddress = "0x0000000000000000000000000000000000000000";

describe("Shares", () => {
  let shares: DiBsShares;
  let bondingToken: BondingToken;
  let curve: BancorFormula;
  let admin;

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
      19,
      curve.getAddress(),
      admin.address,
      1000,
      10
    );
  });

  it("deploy new shares", async () => {
    await shares.deployBondingToken("DiBs", "DiBs", zeroAddress, 19, 1000, 10);
  });
});

import { ethers } from "hardhat";

async function deploy() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying DiBsShares with the account:", deployer.address);

  const DiBsShares = await ethers.getContractFactory("DiBsShares");
  const dibsShares = await DiBsShares.deploy();

  console.log("DiBsShares address:", await dibsShares.getAddress());
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

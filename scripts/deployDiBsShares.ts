import hre, { ethers } from "hardhat";

async function deploy() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying DiBsShares with the account:", deployer.address);

  const DiBsShares = await ethers.getContractFactory("DiBsShares");
  const dibsShares = await DiBsShares.deploy();
  const bondingTokenImpl = await dibsShares.bondingTokenImplementation();

  console.log("DiBsShares address:", await dibsShares.getAddress());
  console.log("BondingToken implementation address:", bondingTokenImpl);

  if (hre.network.name != "hardhat") {
    await hre.run("verify:verify", {
      address: dibsShares.getAddress(),
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
      address: bondingTokenImpl,
      constructorArguments: [],
    });
  }
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

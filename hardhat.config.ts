import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
    },
  },

  networks: {
    "base-mainnet": {
      url: "https://mainnet.base.org",
      accounts: [process.env.ADMIN_PRIVATE_KEY!],
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [process.env.ADMIN_PRIVATE_KEY!],
      gasPrice: 60000000000,
    },
  },

  etherscan: {
    customChains: [
      {
        network: "base-mainnet",
        chainId: 8453,

        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org/",
        },
      },
    ],
    apiKey: {
      goerli: process.env.ETHERSCAN_API_KEY!,
      "base-mainnet": process.env.BASESCAN_API_KEY!,
    },
  },
};

export default config;

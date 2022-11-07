import { ethers } from "hardhat";

async function main() {

  const Doc3Creds = await ethers.getContractFactory("Doc3Cred");
  const doc3Creds = await Doc3Creds.deploy()

  await doc3Creds.deployed();

  console.log(`Doc3Creds deployed to ${doc3Creds.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

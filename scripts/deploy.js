const hre = require("hardhat");

async function main() {
  const NFTicketingHub = await hre.ethers.getContractFactory("NFTicketingHub");
  const nfticketingHub = await NFTicketingHub.deploy();

  await nfticketingHub.deployed();

  console.log(
    `NFTicketingHub deployed to Core Blockchain at address: ${nfticketingHub.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

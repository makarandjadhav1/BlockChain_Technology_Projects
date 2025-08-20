const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deployer:", deployer.address);

  const StakeToken = await ethers.getContractFactory("StakeToken");
  const stakeToken = await StakeToken.deploy("Stake Token", "STK", deployer.address);
  await stakeToken.waitForDeployment();
  console.log("StakeToken:", await stakeToken.getAddress());

  const RewardToken = await ethers.getContractFactory("RewardToken");
  const rewardToken = await RewardToken.deploy("Reward Token", "RWD", deployer.address);
  await rewardToken.waitForDeployment();
  console.log("RewardToken:", await rewardToken.getAddress());

  // 1e14 reward per staked token per second (~0.0001 RWD/sec/token)
  const rewardRatePerSecond = ethers.parseUnits("0.0001", 18);

  const Staking = await ethers.getContractFactory("Staking");
  const staking = await Staking.deploy(
    await stakeToken.getAddress(),
    await rewardToken.getAddress(),
    rewardRatePerSecond,
    deployer.address
  );
  await staking.waitForDeployment();
  console.log("Staking:", await staking.getAddress());

  // Transfer ownership of RewardToken to staking so it can mint rewards
  const tx = await rewardToken.transferOwnership(await staking.getAddress());
  await tx.wait();
  console.log("Transferred RewardToken ownership to Staking");

  // Mint some stake tokens to deployer for convenience
  await (await stakeToken.mint(deployer.address, ethers.parseUnits("1000000", 18))).wait();
  console.log("Minted STK to deployer");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

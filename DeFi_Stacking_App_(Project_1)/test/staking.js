const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking", function () {
  async function deployFixture() {
    const [owner, user] = await ethers.getSigners();

    const StakeToken = await ethers.getContractFactory("StakeToken");
    const stakeToken = await StakeToken.deploy("Stake Token", "STK", owner.address);
    await stakeToken.waitForDeployment();

    const RewardToken = await ethers.getContractFactory("RewardToken");
    const rewardToken = await RewardToken.deploy("Reward Token", "RWD", owner.address);
    await rewardToken.waitForDeployment();

    const rate = ethers.parseUnits("0.01", 18); // 0.01 RWD per token per second
    const Staking = await ethers.getContractFactory("Staking");
    const staking = await Staking.deploy(
      await stakeToken.getAddress(),
      await rewardToken.getAddress(),
      rate,
      owner.address
    );
    await staking.waitForDeployment();

    await (await rewardToken.transferOwnership(await staking.getAddress())).wait();
    await (await stakeToken.mint(user.address, ethers.parseUnits("1000", 18))).wait();

    return { owner, user, stakeToken, rewardToken, staking, rate };
  }

  it("accrues rewards over time and allows claim", async function () {
    const { user, stakeToken, staking } = await deployFixture();

    await (await stakeToken.connect(user).approve(await staking.getAddress(), ethers.MaxUint256)).wait();
    await (await staking.connect(user).stake(ethers.parseUnits("100", 18))).wait();

    // advance time by ~10 seconds
    await ethers.provider.send("evm_increaseTime", [10]);
    await ethers.provider.send("evm_mine", []);

    const earnedBefore = await staking.earned(user.address);
    expect(earnedBefore).to.be.gt(0n);

    const tx = await staking.connect(user).claimRewards();
    await tx.wait();

    const rewardTokenAddr = await staking.rewardToken();
    const reward = await ethers.getContractAt("RewardToken", rewardTokenAddr);
    const balance = await reward.balanceOf(user.address);
    expect(balance).to.be.gte(earnedBefore);
  });
});

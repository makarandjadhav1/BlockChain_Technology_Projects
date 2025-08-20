// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IRewardMinter {
    function mint(address to, uint256 amount) external;
}

/// @title Staking
/// @notice Simple single-sided staking with streamed rewards. Rewards are minted by a RewardToken owned by this contract.
contract Staking is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable stakeToken;
    IRewardMinter public immutable rewardToken;

    uint256 public rewardRatePerSecond; // reward tokens per staked token per second, scaled by 1e18
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored; // scaled by 1e18
    uint256 public totalStaked;

    mapping(address => uint256) public userStakeBalance;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewardsAccrued;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);

    constructor(address stakeToken_, address rewardToken_, uint256 rewardRatePerSecond_, address initialOwner)
        Ownable(initialOwner)
    {
        require(stakeToken_ != address(0) && rewardToken_ != address(0), "zero addr");
        stakeToken = IERC20(stakeToken_);
        rewardToken = IRewardMinter(rewardToken_);
        rewardRatePerSecond = rewardRatePerSecond_;
        lastUpdateTime = block.timestamp;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            rewardsAccrued[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) return rewardPerTokenStored;
        uint256 timeDelta = block.timestamp - lastUpdateTime;
        // scaled by 1e18: rewardRatePerSecond (1e18 scaled) * time / totalStaked
        return rewardPerTokenStored + (timeDelta * rewardRatePerSecond * 1e18) / totalStaked;
    }

    function earned(address account) public view returns (uint256) {
        uint256 userBalance = userStakeBalance[account];
        uint256 delta = rewardPerToken() - userRewardPerTokenPaid[account];
        return rewardsAccrued[account] + (userBalance * delta) / 1e18;
    }

    function setRewardRatePerSecond(uint256 newRate) external onlyOwner updateReward(address(0)) {
        rewardRatePerSecond = newRate;
        emit RewardRateUpdated(newRate);
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "zero amount");
        totalStaked += amount;
        userStakeBalance[msg.sender] += amount;
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "zero amount");
        require(userStakeBalance[msg.sender] >= amount, "insufficient");
        totalStaked -= amount;
        userStakeBalance[msg.sender] -= amount;
        stakeToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function claimRewards() public updateReward(msg.sender) {
        uint256 reward = rewardsAccrued[msg.sender];
        if (reward > 0) {
            rewardsAccrued[msg.sender] = 0;
            // This contract must own the RewardToken to mint
            rewardToken.mint(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        uint256 balance = userStakeBalance[msg.sender];
        if (balance > 0) {
            withdraw(balance);
        }
        claimRewards();
    }
}

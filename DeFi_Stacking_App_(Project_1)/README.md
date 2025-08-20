# DeFi Staking DApp

A decentralized finance (DeFi) staking application built with Solidity smart contracts and Hardhat development framework. Users can stake tokens and earn rewards over time.

## 🏗️ Project Structure

```
DeFi/
├── contracts/           # Smart contracts
│   ├── RewardToken.sol  # ERC20 reward token (mintable)
│   ├── StakeToken.sol   # ERC20 staking token
│   └── Staking.sol      # Main staking contract
├── scripts/             # Deployment scripts
│   └── deploy.js        # Deploy all contracts
├── test/                # Test files
│   └── staking.js       # Staking contract tests
├── hardhat.config.js    # Hardhat configuration
└── package.json         # Dependencies
```

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn

### Installation
```bash
# Clone the repository
git clone https://github.com/makarandjadhav1/DeFi_Stacking_DApp.git
cd DeFi_Stacking_DApp

# Install dependencies
npm install

# Compile contracts
npm run compile
```

## 🧪 Testing

Run the test suite to verify everything works:
```bash
npm test
```

This will run tests that verify:
- Token minting and transfers
- Staking functionality
- Reward accrual over time
- Reward claiming

## 🚀 Local Development

### 1. Start Local Blockchain
```bash
npx hardhat node
```

This starts a local Ethereum node with pre-funded accounts.

### 2. Deploy Contracts
In a new terminal:
```bash
npx hardhat run scripts/deploy.js --network localhost
```

You'll see output like:
```
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
StakeToken: 0x5FbDB2315678afecb367f032d93F642f64180aa3
RewardToken: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Staking: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
Transferred RewardToken ownership to Staking
Minted STK to deployer
```

**Save these addresses!** You'll need them to interact with the contracts.

### 3. Interact with Contracts

#### Using Hardhat Console
```bash
npx hardhat console --network localhost
```

#### Example Interactions
```javascript
// Get contract instances
const stakingAddr = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
const stakeAddr = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const rewardAddr = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

const staking = await ethers.getContractAt("Staking", stakingAddr);
const stake = await ethers.getContractAt("StakeToken", stakeAddr);
const reward = await ethers.getContractAt("RewardToken", rewardAddr);

// Get signers
const [deployer, user] = await ethers.getSigners();

// Check balances
const deployerBalance = await stake.balanceOf(deployer.address);
console.log("Deployer STK balance:", ethers.formatUnits(deployerBalance, 18));

// Approve staking contract to spend tokens
await stake.approve(stakingAddr, ethers.MaxUint256);

// Stake 100 STK tokens
const stakeAmount = ethers.parseUnits("100", 18);
await staking.stake(stakeAmount);
console.log("Staked 100 STK tokens");

// Check staked balance
const stakedBalance = await staking.userStakeBalance(deployer.address);
console.log("Staked balance:", ethers.formatUnits(stakedBalance, 18));

// Fast-forward time (local development only)
await ethers.provider.send("evm_increaseTime", [60]); // 1 minute
await ethers.provider.send("evm_mine", []);

// Check earned rewards
const earned = await staking.earned(deployer.address);
console.log("Earned rewards:", ethers.formatUnits(earned, 18));

// Claim rewards
await staking.claimRewards();
console.log("Rewards claimed!");

// Check reward token balance
const rewardBalance = await reward.balanceOf(deployer.address);
console.log("Reward balance:", ethers.formatUnits(rewardBalance, 18));
```

## 🌐 Testnet Deployment

### 1. Environment Setup
Create a `.env` file in the project root:
```env
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
PRIVATE_KEY=your_private_key_here
```

### 2. Update Hardhat Config
Uncomment and configure the sepolia network in `hardhat.config.js`:
```javascript
networks: {
  hardhat: {},
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL || "",
    accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
  }
}
```

### 3. Deploy to Testnet
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

## 📋 Available Scripts

```bash
npm run compile    # Compile smart contracts
npm test          # Run test suite
npm run deploy    # Deploy to hardhat network
```

## 🔧 Contract Details

### RewardToken
- **Purpose**: ERC20 token distributed as rewards
- **Features**: Mintable by owner, transferable
- **Owner**: Initially deployer, then transferred to Staking contract

### StakeToken
- **Purpose**: ERC20 token used for staking
- **Features**: Mintable by owner, transferable
- **Owner**: Deployer

### Staking
- **Purpose**: Core staking contract
- **Features**: 
  - Single-sided staking
  - Time-based reward distribution
  - Configurable reward rate
  - Automatic reward accrual
  - Withdrawal and exit functions

## 💡 Key Features

1. **Time-based Rewards**: Rewards accrue continuously based on staking duration
2. **Flexible Staking**: Stake and withdraw any amount at any time
3. **Automatic Calculations**: Rewards are calculated automatically on each interaction
4. **Gas Efficient**: Uses efficient reward distribution algorithms
5. **Secure**: Built with OpenZeppelin contracts and best practices

## 🧪 Testing Scenarios

The test suite covers:
- Contract deployment
- Token minting and transfers
- Staking and withdrawal
- Reward accrual over time
- Reward claiming
- Edge cases and error conditions

## 🔒 Security Considerations

- Contracts use OpenZeppelin's battle-tested implementations
- Access control via Ownable pattern
- SafeERC20 for token transfers
- Reentrancy protection
- Input validation

## 🚨 Troubleshooting

### Common Issues

1. **"No anonymous write access" error**
   - Set up GitHub authentication (SSH keys or Personal Access Token)

2. **"Permission denied (publickey)" error**
   - Add SSH key to GitHub account or use HTTPS with token

3. **Compilation errors**
   - Ensure Node.js version is 16+
   - Run `npm install` to install dependencies
   - Check Solidity version compatibility

4. **Test failures**
   - Ensure all dependencies are installed
   - Check Hardhat configuration
   - Verify contract addresses in tests

## 📚 Additional Resources

- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Ethereum Development](https://ethereum.org/developers/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Happy Staking! 🚀**

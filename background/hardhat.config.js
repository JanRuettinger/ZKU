require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-waffle')
// require('hardhat-gas-reporter')
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337,
      mining: {
        auto: true,
        interval: 5000
      },
      accounts: process.env.MNEMONIC
        ? {
            mnemonic: process.env.MNEMONIC
          }
        : undefined,
      allowUnlimitedContractSize: true
    }
  },
  gasReporter: {
    currency: 'EUR',
    gasPrice: 42
  }
}

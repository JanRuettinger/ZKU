const {expect} = require('chai')
const {ethers} = require('hardhat')

describe('Ballot Add Voters Gas Test', function () {
  it('Add 10 new voters', async function () {
    const Ballot = await ethers.getContractFactory(
      'contracts/Ballot.sol:Ballot'
    )
    const ballot = await Ballot.deploy([
      ethers.utils.formatBytes32String('Proposal #1')
    ])
    await ballot.deployed()

    let totalGasUsed = ethers.BigNumber.from(0)

    for (let i = 0; i < 10; i++) {
      const wallet = ethers.Wallet.createRandom()
      adr = wallet.address
      const giveVoteTx = await ballot.giveRightToVote(wallet.address)
      const receipt = await giveVoteTx.wait()
      // console.log(receipt.gasUsed)
      totalGasUsed = totalGasUsed.add(receipt.gasUsed)
    }
    console.log(
      'Gas used to add 10 voters with the original contract: ',
      totalGasUsed.toString()
    )
  })

  it('Add 10 new voters', async function () {
    const Ballot = await ethers.getContractFactory(
      'contracts/ImprovedBallot.sol:Ballot'
    )
    const ballot = await Ballot.deploy([
      ethers.utils.formatBytes32String('Proposal #1')
    ])
    await ballot.deployed()

    const voters = []
    for (let i = 0; i < 10; i++) {
      const wallet = ethers.Wallet.createRandom()
      voters.push(wallet.address)
    }
    const giveVoteTx = await ballot.giveRightToVote(voters)
    const receipt = await giveVoteTx.wait()
    console.log(
      'Gas used to add 10 voters with the improved contract: ',
      receipt.gasUsed.toString()
    )
  })

  it('Add 500 new voters', async function () {
    const Ballot = await ethers.getContractFactory(
      'contracts/Ballot.sol:Ballot'
    )
    const ballot = await Ballot.deploy([
      ethers.utils.formatBytes32String('Proposal #1')
    ])
    await ballot.deployed()

    let totalGasUsed = ethers.BigNumber.from(0)

    for (let i = 0; i < 500; i++) {
      const wallet = ethers.Wallet.createRandom()
      adr = wallet.address
      const giveVoteTx = await ballot.giveRightToVote(wallet.address)
      const receipt = await giveVoteTx.wait()
      // console.log(receipt.gasUsed)
      totalGasUsed = totalGasUsed.add(receipt.gasUsed)
    }
    console.log(
      'Gas used to add 500 voters with the original contract: ',
      totalGasUsed.toString()
    )
  })

  it('Add 500 new voters', async function () {
    const Ballot = await ethers.getContractFactory(
      'contracts/ImprovedBallot.sol:Ballot'
    )
    const ballot = await Ballot.deploy([
      ethers.utils.formatBytes32String('Proposal #1')
    ])
    await ballot.deployed()

    const voters = []
    for (let i = 0; i < 500; i++) {
      const wallet = ethers.Wallet.createRandom()
      voters.push(wallet.address)
    }
    const giveVoteTx = await ballot.giveRightToVote(voters)
    const receipt = await giveVoteTx.wait()
    console.log(
      'Gas used to add 500 voters with the improved contract: ',
      receipt.gasUsed.toString()
    )
  })
})

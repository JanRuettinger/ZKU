const {expect} = require('chai')
const {ethers} = require('hardhat')

describe('Hello World Test', function () {
  it('Check if setter and getter work', async function () {
    const HelloWorld = await ethers.getContractFactory('HelloWorld')
    const helloworld = await HelloWorld.deploy()
    await helloworld.deployed()
    const tx1 = await helloworld.x()
    console.log('tx1: ', tx1)
    const tx2 = await helloworld.setX(2)
    const tx3 = await helloworld.x()
    console.log('tx3: ', tx3)
  })
})

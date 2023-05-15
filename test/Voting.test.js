const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("Voting", function () {
    let owner
    let voter1
    let voter2
    let candidates = ["Vasya", "Misha", "Ivan", "John"]
    let voting

    beforeEach(async function () {
        [owner, voter1, voter2] = await ethers.getSigners()
        
        const Voting = await ethers.getContractFactory("Voting", owner)
        voting = await Voting.deploy(candidates)
        await voting.deployed()
    })

    it("already voted, 1 wei - 1 vote", async function () {
        const votesNum = await voting.seeVotesForCandidate("Vasya")
        expect(votesNum).to.eq(0)
        console.log(votesNum)

        await voting.connect(voter1).vote("Vasya", {value: 1})

        await expect(voting.connect(voter1).vote("Vasya", {value: 1})).to.be.revertedWith("You've already voted!")

        await expect(voting.connect(voter2).vote("Vasya", {value: 2})).to.be.revertedWith("1 wei - 1 vote!")

        const votesNum2 = await voting.seeVotesForCandidate("Vasya")
        expect(votesNum2).to.eq(1)
        console.log(votesNum2)
    })

    it("not candidate", async function () {
        await expect(voting.connect(voter1).vote("Vasily", {value: 1})).to.be.revertedWith("Invalid candidate!")
    })

    it("emit Voted", async function () {
        await expect(voting.connect(voter2).vote("John", {value: 1})).to.emit(voting, "Voted").withArgs(
            voter2.address,
            "John" 
        )
    })
})
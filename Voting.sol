// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract Voting {
    mapping(string => address) candidates;
    mapping(address => uint) votes;
    mapping(address => bool) voted;
    uint constant ELECTION_TIME = 3 days;
    uint startsAt;
    uint endsAt;

    event Voted(address _voter, string _candidate);

    constructor(string[] memory _candidatesList) {
        for(uint i = 0; i < _candidatesList.length; i++) {
            bytes32 candidateHash = keccak256(
                abi.encodePacked(
                    _candidatesList[i]
                )
            );
            candidates[_candidatesList[i]] = address((bytes20(candidateHash)));
            votes[candidates[_candidatesList[i]]] = 0;
        }
        startsAt = block.timestamp;
        endsAt = block.timestamp + ELECTION_TIME;
    }

    modifier isVoted {
        require(!voted[msg.sender], "You've already voted!");
        _;
    }

    modifier validCandidate(string memory _candidate) {
        require(candidates[_candidate] != address(0), "Invalid candidate!");
        _;
    }

    modifier notEnded {
        require(endsAt - startsAt > 0, "Elections are already over!");
        _;
    }

    function vote(string memory _candidate) external payable isVoted validCandidate(_candidate) notEnded {
        require(msg.value == 1 wei, "1 wei - 1 vote!");

        votes[candidates[_candidate]] += msg.value;

        voted[msg.sender] = true;

        emit Voted(msg.sender, _candidate);
    }

    function seeVotesForCandidate(string memory _candidate) external view validCandidate(_candidate) returns(uint) {
        return votes[candidates[_candidate]];
    }
}
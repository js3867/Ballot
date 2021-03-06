// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Ballot is Ownable {
    // proposal: needs a name, record of how many votes, options?
    struct Proposal {
        string name;
        uint256 voteCount;
    }
    // voters: already voted? (bool), access to vote? (uint), vote index (uint)
    struct Voter {
        uint256 voteNo;
        bool voted;
        uint256 weight;
    }

    bool public ballotIsOpen;
    bool public ballotIsEnded = false;
    Proposal[] public proposals; // list of proposals

    mapping(address => Voter) public voters; // key[value] pair, address[voter]

    address public chairperson;

    // proposalNames will add the proposal names to the smart contract on deployment
    constructor(string[] memory proposalNames) {
        ballotIsOpen = true;
        chairperson = msg.sender;
        voters[chairperson].weight = 1; // allocate 1 weight to chair/admin
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    // add new proposals to proposals list
    function addProposals(string[] memory newProposalNames) public onlyOwner {
        require(ballotIsEnded == false, "This ballot has already concluded");
        for (uint256 i = 0; i < newProposalNames.length; i++) {
            proposals.push(Proposal({name: newProposalNames[i], voteCount: 0}));
        }
    }

    // cast vote by proposal name
    // function castVote(string _vote) public {
    //     Voter storage sender = voters[msg.sender];

    //     require(ballotIsOpen, "ballot is currently closed");
    //     require(!ballotIsEnded, "ballot has already concluded");
    //     require(!sender.voted, "address has already voted!");
    //     require(sender.weight > 0, "address not approved to vote!");

    //     uint256 check = 0;
    //     for (uint256 i = 0; i < proposals.length; i++) {
    //         if (proposals[i].name == _vote) {
    //             proposals[i].voteCount += sender.weight;
    //             check += 1;
    //         }
    //     }
    //     if (check > 0) {
    //         sender.voted = true;
    //         sender.voteNo += 1;
    //     }
    // }

    // cast vote by index
    function vote(uint256 _vote) public {
        Voter storage sender = voters[msg.sender]; // define data location that will run between function calls

        require(_vote <= proposals.length, "invalid entry");
        require(ballotIsOpen, "ballot is currently closed");
        require(!ballotIsEnded, "ballot has already concluded");
        require(!sender.voted, "address has already voted!");
        require(sender.weight > 0, "address not approved to vote!");

        proposals[_vote].voteCount += sender.weight;

        sender.voted = true;
        sender.voteNo += 1;
    }

    // authentication
    function giveRightToVote(address _voter) public onlyOwner {
        require(!ballotIsEnded, "ballot has already concluded");
        require(voters[_voter].weight == 0, "voter already has right to vote!");
        require(!voters[_voter].voted, "voter has already voted!");

        voters[_voter].weight = 1;
    }

    // display results only
    function getVotes(uint256 _proposal)
        public
        view
        returns (uint256 proposalVotes_)
    {
        return proposals[_proposal].voteCount;
    }

    // retrieve proposal name only
    function getName(uint256 _proposal)
        public
        view
        returns (string memory proposalName_)
    {
        return proposals[_proposal].name;
    }

    // retrieve proposal name only
    function getLength() public view returns (uint256 numOfProposals_) {
        return proposals.length;
    }

    // end ballot and count votes
    function concludeBallot() public onlyOwner {
        ballotIsOpen = false;
        ballotIsEnded = true;
    }

    function getResults()
        public
        view
        returns (string memory winner_, uint256 winningVoteCount_)
    {
        require(ballotIsEnded == true, "ballot is still open.");

        string memory winner;
        uint256 votes = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > votes) {
                votes = proposals[i].voteCount;
                winner = proposals[i].name;
            }
        }
        return (winner, votes);
    }

    // is there a way to add approved addresses to authentication of Owner?
    function openBallot() public onlyOwner {
        require(ballotIsEnded == false, "This ballot has already concluded");
        ballotIsOpen = true;
    }

    // closeBallot
    function closeBallot() public onlyOwner {
        require(ballotIsEnded == false, "ballot has already concluded");
        ballotIsOpen = false;
    }
}

// --- MAIN TAKEAWAYS ---

// memory vs storage

// memory defines a temporary data location for Solidity during runtime only of methods
// ...memory keyword guarantees space for the variable/transaction
// without using memory, the objects will only be recalled inbetween function calls
// ...this is inherently more temporary
// when using storage keyword, "the object/variable would not be wiped off" << check this for clarity
// -- memory is more efficient, requires less gas

// bytes32 as string

// uses node.js package 'ethers' to convert strings to byte32 on chain,
// reducing the gas required for interacting with smart contracts

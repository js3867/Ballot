// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Ballot is Ownable {
    // proposal: needs a name, record of how many votes, options?
    struct Proposal {
        bytes32 name;
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
    constructor(bytes32[] memory proposalNames) {
        ballotIsOpen = true;
        chairperson = msg.sender;
        voters[chairperson].weight = 1; // allocate 1 weight to chair/admin
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    // add new proposals to proposals list
    function addProposals(bytes32[] memory newProposalNames) public onlyOwner {
        require(ballotIsEnded == false, "This ballot has already concluded");
        for (uint256 i = 0; i < newProposalNames.length; i++) {
            proposals.push(Proposal({name: newProposalNames[i], voteCount: 0}));
        }
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

    // cast vote
    function castVote(bytes32 voteChoice) public {
        Voter storage sender = voters[msg.sender];

        require(ballotIsOpen, "ballot is currently closed");
        require(!ballotIsEnded, "ballot has already concluded");
        require(!sender.voted, "address has already voted!");
        require(sender.weight > 0, "address not approved to vote!");

        uint256 check = 0;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            if (proposals[i] == voteChoice) {
                proposals[i].voteCount += sender.weight;
                check += 1;
            }
        }
        if (check > 0) {
            sender.voted = true;
            // sender.voteNo = +1;
        }
    }

    // cast vote by index
    function voteByIndex(uint256 vote) public {
        Voter storage sender = voters[msg.sender]; // define data location that will run between function calls

        require(vote <= proposals.length, "invalid entry");
        require(ballotIsOpen, "ballot is currently closed");
        require(!ballotIsEnded, "ballot has already concluded");
        require(!sender.voted, "address has already voted!");
        require(sender.weight > 0, "address not approved to vote!");

        proposals[vote].voteCount += sender.weight;

        sender.voted = true;
        sender.voteNo += 1;
    }

    // authentication
    function giveRightToVote(address voter) public onlyOwner {
        require(!ballotIsEnded, "ballot has already concluded");
        require(voters[voter].weight == 0, "voter already has right to vote!");
        require(!voters[voter].voted, "voter has already voted!");

        voters[voter].weight == 1;
    }

    // display results only
    function getProposalsStatus() public {
        return proposals;
    }

    // end ballot and count votes
    function endAndDisplayResults() public onlyOwner {
        require(
            ballotIsEnded == false,
            "This ballot has already concluded. Please try getProposalsStatus() function"
        );
        require(ballotIsOpen == false, "ballot must be closed before ending");

        bytes32 winner;
        uint256 highest_votes = 0;

        for (uint256 i = 0; i < proposalNames.length; i++) {
            if (proposals[i].voteCount > highest_votes) {
                highest_votes = proposals[i].voteCount;
                winner = proposals[i].name;
            }
        }
        ballotIsEnded = true;
        return (winner, highest_votes);
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

//

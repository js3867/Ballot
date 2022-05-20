from brownie import accounts, Ballot
from scripts.helpful_scripts import *

proposals1 = ["coffee machine", "snooker table", "topless waiter", "office pet"]
proposals2 = ["just give us flexitime!!!"]


def deploy_ballot(proposals):
    account = get_account(0)
    print("deploying Ballot contract...")
    Ballot.deploy(proposals, {"from": account})
    print("Success! The following proposals are ready for voting:")
    for proposal in proposals:
        print(f"..{proposal}")


def cast_vote(Idx, address=None):
    print()
    account = get_account(address)
    print(f"{account} is casting a vote...")
    ballot = Ballot[-1]
    tx = ballot.vote(Idx, {"from": account})
    tx.wait(1)
    getName = ballot.getName(Idx)
    print(f"successfully cast vote for {getName}!")


def get_current_status(toPrint=True):
    print()
    b = Ballot[-1]
    num_props = b.getLength()
    status = []
    for proposal in range(num_props):
        name = b.getName(proposal)
        votes = b.getVotes(proposal)
        if toPrint:
            print(f"{name} has {votes} votes so far!")
        status.append((name, votes))
    return status


def add_proposals(new_proposals):
    print()
    b = Ballot[-1]
    tx = b.addProposals(new_proposals)
    tx.wait(1)
    print(
        "Success! You have added the following proposals, which are ready for voting:"
    )
    for proposal in new_proposals:
        print(f"..{proposal}")
    print()


def approveAddress(addresses):
    account = get_account(0)
    b = Ballot[-1]
    for i in addresses:
        verified_address = get_account(i)
        tx = b.giveRightToVote(verified_address, {"from": account})
        tx.wait(1)
        print(f"approved [{i}] {verified_address} for voting\n")


def conclude_ballot():
    account = get_account(0)
    b = Ballot[-1]
    tx = b.concludeBallot({"from": account})
    tx.wait(1)
    print("Thank you! The ballot has been concluded...")


def show_results():
    b = Ballot[-1]
    winner, votes = b.getResults()
    print("----------------------------------------")
    print(f"{winner} wins with {votes} votes!")
    print("----------------------------------------")
    status = get_current_status(False)
    status_ordered = sorted(status, key=lambda tup: tup[1], reverse=True)
    print(f"The final votes were as follows:")
    for proposal in status_ordered:
        print(f"..{proposal[0]} got {proposal[1]} votes")


def update_front_end():




def main():
    deploy_ballot(proposals1)
    cast_vote(0, 0)
    addresses_to_approve = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    approveAddress(addresses_to_approve)
    cast_vote(2, 1)
    cast_vote(3, 2)
    cast_vote(2, 3)
    get_current_status()
    add_proposals(proposals2)
    cast_vote(4, 4)
    get_current_status()
    winner = conclude_ballot()
    show_results()
    print()
    # cast_vote(4, 5)

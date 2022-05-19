# SPDX-License Identifier: MIT

from brownie import (
    accounts,
    network,
    config,
    Contract,
)

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
DEPOSIT_AMOUNT_ETHER = 1

# None is default value but can be overridden if params passed
def get_account(index=None, id=None):
    if index:
        return accounts[index]  # n/a here
    if id:
        return accounts.load(id)  # n/a here
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    return accounts.add(
        config["wallets"]["from_key"]
    )  # default option if all else fail


# # return (via mapping) the contract Type from the config file, based on its name
# contract_to_mock = {
#     # contract_to_mock[contract_name] : Contract Type
#     "eth_usd_price_feed": MockV3Aggregator,
# }


# def get_contract(contract_name):
#     contract_type = contract_to_mock[contract_name]  # using mapping
#     if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:  # for development envs
#         if len(contract_type) <= 0:  # eq. to doing: MockV3Aggregator.length
#             deploy_mocks()
#         # else:
#         contract = contract_type[-1]
#     else:  # for testnets etc
#         contract_address = config["networks"][network.show_active()][contract_name]
#         contract = Contract.from_abi(  # from brownie import Contract
#             contract_type._name,
#             contract_address,
#             contract_type.abi,  # i.e. MockV3Aggregator.abi
#         )  # basically serves up a contract with key data to pass
#     return contract


DECIMALS = 8
INITIAL_VALUE = 200000000000


# def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
#     account = get_account()
#     MockV3Aggregator.deploy(decimals, initial_value, {"from": account})
#     print("Deployed!")

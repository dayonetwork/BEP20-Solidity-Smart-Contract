# BEP20 Solidity Smart Contract

## Project structure

openzeppelin/ - contains openzeppelin libraries that are safe to use
dayo/ - contains various solidity contracts which provide Dayo important functionalities: staking, vesting, decentralized DNS, and others
	Alias.sol - assign simple aliases to addresses
	Daimyo.sol - privileged addresses which must not pay for network functions
	DDNS.sol - register and transfer domains and manage the A record
	Name.sol - library which provides various checks for DDNS and aliases
	Network.sol - network traffic management library for addresses which use dayo as a decentralized private network
	Staking.sol - staking module
	Time.sol - library which provides reliable functions to get the current time
	Vesting.sol - vesting module
DayoBase.sol - base contract which assigns tokens to addresses based on the tokenomics and implements `selfdestruct` and `withdraw` functions
DayoICO.sol - initial coin offering contract
Dayo.sol - the main contract which should be deployed - extends all other contracts

## Deployment

When deployed, 5 addresses must be provided which should be controlled by the owner:
1. The ICO address - from which tokens will be provided to ICO participants
2. The development address - funds used for development purposes
3. The team address - team reserved tokens
4. The reserve address - Dayo reserve
5. The advisor's address - advisors' funds

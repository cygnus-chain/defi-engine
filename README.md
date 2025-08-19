# Cygnus DeFi Engine

This project showcases the Cygnus DeFi Engine built for the Cygnus Mainnet. It uses Hardhat 3 Beta with `mocha` and `ethers.js` for testing and Ethereum interactions.

## Project Overview

This example project includes:

* Advanced CNS20 token implementation.
* CNSFactory, CNSPair, CNSRouter, and CNSLibrary contracts.
* Interfaces for ICNS20, ICNSCallee, ICNSFactory, ICNSPair, and IERC20.
* TypeScript integration tests using `mocha` and `ethers.js`.
* Ignition modules for deployments.

## Usage

### Running Tests

To run all the tests in the project, execute the following command:

```shell
npx hardhat test
```

You can also selectively run Solidity or `mocha` tests:

```shell
npx hardhat test solidity
npx hardhat test mocha
```

### Deployment

This project includes example Ignition modules to deploy contracts to the Cygnus Mainnet.

To deploy a module:

```shell
npx hardhat ignition deploy ignition/modules/<ModuleName>.ts --network cygnusMainnet
```

Ensure that your mainnet private key is set in the Hardhat config using the `MAINNET_PRIVATE_KEY` configuration variable.

### Project Structure

```
cygnus-defi/
├─ contracts/
│  ├─ CNS20.sol
│  ├─ CNSFactory.sol
│  ├─ CNSLibrary.sol
│  ├─ CNSPair.sol
│  ├─ CNSRouter.sol
│  └─ interfaces/
│     ├─ ICNS20.sol
│     ├─ ICNSCallee.sol
│     ├─ ICNSFactory.sol
│     ├─ ICNSPair.sol
│     └─ IERC20.sol
├─ ignition/
│  └─ modules/
├─ test/
├─ scripts/
├─ hardhat.config.ts
├─ package.json
├─ package-lock.json
├─ tsconfig.json
└─ README.md
```

### Notes

* Users are responsible for compiling the contracts.
* All mainnet interactions should be performed using the `cygnusMainnet` network configuration in `hardhat.config.ts`.
* CNS20 and related contracts are fully advanced, supporting factory, pair, router, and library interactions for DeFi applications.

## Transient Reentrancy Guard

Solidity Reentrancy Guard implementation using Transient Storage Opcodes ([EIP-1153](https://eips.ethereum.org/EIPS/eip-1153)). Almost 2000 gas units cheaper than OpenZeppelin's pre-cancun implementation.

### Installation

Install the package by running:

#### Foundry (git)

```
forge install andrejrakic/transient-reentrancy-guard
```

and the set remappings to: `transient-reentrancy-guard/=lib/transient-reentrancy-guard/` in either `remmapings.txt` or `foundry.toml` file

#### Hardhat (npm)

```
npm install git+https://github.com/andrejrakic/transient-reentrancy-guard.git --save-dev
```

### Usage

Once installed, import the [TransientReentrancyGuard](./src/TransientReentrancyGuard.sol) smart contract into your project:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TransientReentrancyGuard} from "transient-reentrancy-guard/src/TransientReentrancyGuard.sol";

contract MyContract is TransientReentrancyGuard {
    function foo() external nonReentrant {
        bar();
    }
}
```

> [!IMPORTANT]
>
> EIP-1153 is supported since the Dencun upgrade so you will need to use at least the 0.8.24 version of the Solidity compiler and the `cancun` EVM version. To see how to configure those in different development environments check [this StackOverflow answer](https://stackoverflow.com/questions/76328677/remix-returned-error-jsonrpc2-0-errorinvalid-opcode-push0-id24/76332341#76332341)

### Build & Test

1. Compile

```
forge build
```

2. Test

```
forge test
```

### Contributions

Contributions are more than welcome, feel free to open PRs :)

## Transient Reentrancy Guard

Solidity Reentrancy Guard implementation using Transient Storage Opcodes ([EIP-1153](https://eips.ethereum.org/EIPS/eip-1153))

### Usage

1. Install the package by running either:

```
forge install andrejrakic/transient-reentrancy-guard
```

Or:

```
npm install git+https://github.com/andrej/transient-reentrancy-guard.git --save-dev
```

2. Then import the [TransientReentrancyGuard](./src/TransientReentrancyGuard.sol) smart contract in your project:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TransientReentrancyGuard} from "andrejrakic/transient-reentrancy-guard/src/TransientReentrancyGuard.sol";

contract MyContract is TransientReentrancyGuard {
    function foo() external nonReentrant {
        bar();
    }
}
```

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Inspired by https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol

abstract contract TransientReentrancyGuard {
    uint256 internal constant REENTRANCY_GUARD_SLOT = uint256(keccak256("REENTRANCY_GUARD_SLOT")) - 1;

    uint256 private constant NOT_ENTERED = 0;
    uint256 private constant ENTERED = 1;

    error ReentrantCall();

    modifier nonReentrant() {
        bytes4 errorSelector = ReentrantCall.selector;
        uint256 reentrancyGuardSlot = REENTRANCY_GUARD_SLOT;

        assembly {
            if eq(tload(reentrancyGuardSlot), ENTERED) {
                mstore(0, errorSelector)
                revert(0, 4) // there is room in the scratch-space
            }

            tstore(reentrancyGuardSlot, ENTERED)
        }
        _;
        assembly {
            tstore(reentrancyGuardSlot, NOT_ENTERED)
        }
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        uint256 _status;
        uint256 reentrancyGuardSlot = REENTRANCY_GUARD_SLOT;

        assembly {
            _status := tload(reentrancyGuardSlot)
        }

        return _status == ENTERED;
    }
}

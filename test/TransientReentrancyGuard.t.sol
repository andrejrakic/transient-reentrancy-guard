// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {Client} from "../src/test/Client.sol";
import {VulnerableClient} from "../src/test/VulnerableClient.sol";
import {Attacker} from "../src/test/Attacker.sol";

contract TransientReentrancyGuardTest is Test {
    Client public client;
    VulnerableClient public vulnerableClient;
    Attacker public attacker;
    address alice;

    function setUp() public {
        alice = makeAddr("alice");

        client = new Client();
        vulnerableClient = new VulnerableClient();
        attacker = new Attacker(alice, address(client));
    }

    function test_transientReentrancyGuard() external {
        uint256 initialAmount = 100 ether;
        uint256 depositAmount = 10 ether;
        vm.deal(alice, initialAmount);
        assertEq(alice.balance, initialAmount);

        vm.startPrank(alice);

        client.deposit{value: depositAmount}();
        attacker.deposit{value: depositAmount}();
        assertEq(address(client).balance, 2 * depositAmount);

        vm.expectRevert(Client.EthTransferFailed.selector);
        attacker.attack();

        assertEq(address(client).balance, 2 * depositAmount);

        attacker.setVictim(address(vulnerableClient));
        assertEq(attacker.victim(), address(vulnerableClient));

        vulnerableClient.deposit{value: depositAmount}();
        attacker.deposit{value: depositAmount}();
        assertEq(address(vulnerableClient).balance, 2 * depositAmount);

        attacker.attack();

        assertEq(address(vulnerableClient).balance, 0);
        assertEq(alice.balance, initialAmount - 2 * depositAmount);
        assertEq(address(attacker).balance, 0);

        vm.stopPrank();
    }
}

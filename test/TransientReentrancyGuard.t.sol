// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {Client} from "../src/test/Client.sol";
import {VulnerableClient} from "../src/test/VulnerableClient.sol";
import {ClientOpenZeppelin} from "../src/test/ClientOpenZeppelin.sol";
import {Attacker} from "../src/test/Attacker.sol";

contract TransientReentrancyGuardTest is Test {
    Client public client;
    VulnerableClient public vulnerableClient;
    ClientOpenZeppelin public clientOpenZeppelin;
    Attacker public attacker;
    address alice;

    function setUp() public {
        alice = makeAddr("alice");

        client = new Client();
        vulnerableClient = new VulnerableClient();
        clientOpenZeppelin = new ClientOpenZeppelin();
        attacker = new Attacker(alice, address(client));
    }

    function prepareScenario() public returns (uint256, uint256) {
        uint256 initialAmount = 100 ether;
        uint256 depositAmount = 10 ether;
        vm.deal(alice, initialAmount);
        assertEq(alice.balance, initialAmount);

        return (initialAmount, depositAmount);
    }

    function test_transientReentrancyGuardAttackScenario() external {
        (uint256 initialAmount, uint256 depositAmount) = prepareScenario();
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

    function test_withdrawTransientReentrancyGuard() external {
        (uint256 initialAmount, uint256 depositAmount) = prepareScenario();
        vm.startPrank(alice);

        clientOpenZeppelin.deposit{value: depositAmount}();
        assertEq(alice.balance, initialAmount - depositAmount);
        assertEq(address(clientOpenZeppelin).balance, depositAmount);

        attacker.setVictim(address(clientOpenZeppelin));
        attacker.deposit{value: depositAmount}();
        assertEq(alice.balance, initialAmount - 2 * depositAmount);
        assertEq(address(clientOpenZeppelin).balance, 2 * depositAmount);

        clientOpenZeppelin.withdraw();
        assertEq(alice.balance, initialAmount - depositAmount);
        assertEq(address(clientOpenZeppelin).balance, depositAmount);

        vm.stopPrank();
    }

    function test_withdrawOpenZeppelinReentrancyGuard() external {
        (uint256 initialAmount, uint256 depositAmount) = prepareScenario();
        vm.startPrank(alice);

        client.deposit{value: depositAmount}();
        assertEq(alice.balance, initialAmount - depositAmount);
        assertEq(address(client).balance, depositAmount);

        attacker.setVictim(address(client));
        attacker.deposit{value: depositAmount}();
        assertEq(alice.balance, initialAmount - 2 * depositAmount);
        assertEq(address(client).balance, 2 * depositAmount);

        client.withdraw();
        assertEq(alice.balance, initialAmount - depositAmount);
        assertEq(address(client).balance, depositAmount);

        vm.stopPrank();
    }

    function test_fuzzAttackerMustNotReenter(uint256 depositAmount) external {
        vm.assume(depositAmount <= address(msg.sender).balance);

        attacker.deposit{value: depositAmount}();
        uint256 clientAmountBeforeAttack = address(client).balance;
        attacker.attack();

        // Attacker must only withdraw its own deposit and nothing more
        assertEq(address(client).balance, clientAmountBeforeAttack - depositAmount);
    }
}

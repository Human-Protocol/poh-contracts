// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

import "../HumanOnly.sol";

contract HumanOnlyMock is HumanOnly {
    event Success();

    constructor() {
        setHumanityValidator(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    }

    function testBasicPoH(bytes calldata proof) public basicPoH(proof) {
        emit Success();
    }

    function testSovereignPoH(bytes calldata proof) public sovereignPoH(proof) {
        emit Success();
    }
}

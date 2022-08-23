// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

import "hardhat/console.sol";

contract Playground {

    bytes1 public state;

    function fromEmptyToBlack() public {
        state = 0x00;
        console.log("      before:", uint8(state));
        state = 0xaa; // [10101010]
        console.log("      after:", uint8(state));
    }

    function fromEmptyToWhite() public {
        state = 0x00;
        console.log("      before:", uint8(state));
        state = 0x55; // [01010101]
        console.log("      after:", uint8(state));
    }

    function fromBlackToEmpy() public {
        state = 0xaa;
        console.log("      before:", uint8(state));
        state = 0x00;
        console.log("      after:", uint8(state));
    }

    function fromWhiteToEmpy() public {
        state = 0x55;
        console.log("      before:", uint8(state));
        state = 0x00;
        console.log("      after:", uint8(state));
    }
}
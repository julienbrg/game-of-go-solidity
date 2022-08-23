// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

import "hardhat/console.sol";

contract BitsAndBytes {

    constructor() {}

    bytes1 public state;

    function checkMe() public view returns (bytes1) {
        bytes1 empty;

        bytes1 a = 0xb5; //  [10110101] // 181
        bytes1 b = 0x56; //  [01010110] // 86
        bytes1 c = 0xFF; //  [11111111] // 255


        console.log("     state =", uint8(c));
        return c;
    }

}
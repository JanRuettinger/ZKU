//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract HelloWorld {
    uint256 public x; // public -> automically creates a getter method

    constructor() {
        x = 0; // initialize value of x to 0;
    }

    // allow eveybody to change the value of the variable x
    function setX(uint256 _x) external {
        x = _x;
    }
}

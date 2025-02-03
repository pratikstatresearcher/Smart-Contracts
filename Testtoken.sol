// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract PratikTestToken is ERC20, ERC20Permit {
    address public owner;
    constructor() ERC20("PratikTestToken", "PTT") ERC20Permit("PratikTestToken") {
        owner = msg.sender;
        _mint(msg.sender, 100000 * 10 ** 18);
    }
}

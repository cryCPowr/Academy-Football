//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DrillToken is ERC20, ERC20Permit, Ownable2Step, ERC20Burnable {
    string private constant NAME = "Drill Token";
    string private constant SYMBOL = "DTKN";
    uint256 private constant MAX_TOTAL_SUPPLY = 21_000_000_000_000 * (10 ** 18);

    constructor(address recipient) ERC20(NAME, SYMBOL) ERC20Permit(NAME) Ownable(msg.sender) {
        _mint(recipient, MAX_TOTAL_SUPPLY);
    }
}

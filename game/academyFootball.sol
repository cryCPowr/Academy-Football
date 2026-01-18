// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract academyFootball is Ownable {
    IERC20 public drillToken;

    // Event sekedar buat tanda kontrak lahir
    event GameDeployed(address indexed owner, address indexed token);

    constructor(address _drillToken) Ownable(msg.sender) {
        require(_drillToken != address(0), "Game: Invalid Token");
        drillToken = IERC20(_drillToken);
        emit GameDeployed(msg.sender, _drillToken);
    }

    // --- VIEW FUNCTION ---
    // Buat ngecek saldo di hardhat console biar gampang
    function getGameBalance() external view returns (uint256) {
        return drillToken.balanceOf(address(this));
    }

    // --- EMERGENCY ---
    // Biar token test lu gak nyangkut selamanya pas lagi testing
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = drillToken.balanceOf(address(this));
        require(balance > 0, "Game: Zonk, saldo kosong");
        drillToken.transfer(msg.sender, balance);
    }
}

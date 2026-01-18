// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IDrillRegistry {
    // --- EVENTS ---
    event ManagerHired(address indexed manager);
    event ManagerFired(address indexed manager);
    event GameProposed(address indexed gameContract, address indexed proposer, bool isAdding);
    event GameVoted(address indexed gameContract, address indexed voter, uint256 currentVotes, uint256 neededVotes);
    event GameRegistered(address indexed gameContract);
    event GameUnregistered(address indexed gameContract);

    // --- FUNGSI ---
    function isAuthorized(address _who, bytes32 _role) external view returns (bool);
    function getActiveGames() external view returns (address[] memory);

    // Konstanta (Getter)
    function MANAGER_ROLE() external view returns (bytes32);
    function GAME_ROLE() external view returns (bytes32);

    // 👇 NAH INI YANG KURANG KEMAREN 👇
    function getGameAt(uint256 index) external view returns (address);
    function getGameCount() external view returns (uint256);
}

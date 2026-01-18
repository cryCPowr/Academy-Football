// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../interfaces/IDrillRegistry.sol";

contract DrillRegistry is IDrillRegistry, AccessControl, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant override MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant override GAME_ROLE = keccak256("GAME_ROLE");
    uint256 public constant QUORUM_PERCENTAGE = 60; // Butuh 60% suara manager

    EnumerableSet.AddressSet private _managers;
    EnumerableSet.AddressSet private _activeGames;

    mapping(address => mapping(address => bool)) public approvals;
    mapping(address => uint256) public approvalCount;

    constructor() Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupManager(msg.sender);
    }

    function hireManager(address _employee) external onlyOwner {
        require(!_managers.contains(_employee), "Registry: Already hired");
        _setupManager(_employee);
        emit ManagerHired(_employee);
    }

    function fireManager(address _employee) external onlyOwner {
        require(_managers.contains(_employee), "Registry: Not a manager");
        _revokeRole(MANAGER_ROLE, _employee);
        _managers.remove(_employee);

        emit ManagerFired(_employee);
    }

    function _setupManager(address _user) internal {
        _grantRole(MANAGER_ROLE, _user);
        _managers.add(_user);
    }
    /**
     * @notice Manager voting untuk mendaftarkan Game Baru
     */

    function voteAddGame(address _gameContract) external onlyRole(MANAGER_ROLE) {
        require(_gameContract != address(0), "Registry: Zero address");
        require(!_activeGames.contains(_gameContract), "Registry: Already active");
        require(!approvals[_gameContract][msg.sender], "Registry: You already voted");

        // 1. Rekam Suara
        approvals[_gameContract][msg.sender] = true;
        approvalCount[_gameContract] += 1;
        uint256 totalManagers = _managers.length();
        uint256 neededVotes = (totalManagers * QUORUM_PERCENTAGE + 99) / 100;

        emit GameVoted(_gameContract, msg.sender, approvalCount[_gameContract], neededVotes);

        // 3. Cek Lulus
        if (approvalCount[_gameContract] >= neededVotes) {
            _activeGames.add(_gameContract);
            _grantRole(GAME_ROLE, _gameContract);
            delete approvalCount[_gameContract];
            emit GameRegistered(_gameContract);
        }
    }

    /**
     * @notice Manager voting untuk menghapus Game (Unregister)
     * @dev Logikanya dipisah atau pake toggle 'isAdding' di parameter biar hemat baris code.
     * Untuk keamanan, fitur remove biasanya HAK VETO Owner saja biar cepet.
     * Tapi kalau mau Manager bisa remove, buat fungsi voteRemoveGame mirip voteAddGame.
     */
    /**
     * @notice Owner punya hak VETO mutlak untuk menghapus game scam/bahaya
     * tanpa perlu nunggu voting manager.
     */
    function vetoRemoveGame(address _gameContract) external onlyOwner {
        if (_activeGames.contains(_gameContract)) {
            _activeGames.remove(_gameContract);
            _revokeRole(GAME_ROLE, _gameContract);

            // Reset count biar bersih
            delete approvalCount[_gameContract];

            emit GameUnregistered(_gameContract);
        }
    }

    function getGameAt(uint256 index) external view returns (address) {
        return _activeGames.at(index); // EnumerableSet punya fungsi .at()
    }

    function getGameCount() external view returns (uint256) {
        return _activeGames.length();
    }

    function isAuthorized(address _who, bytes32 _role) external view override returns (bool) {
        return hasRole(_role, _who);
    }

    function getActiveGames() external view override returns (address[] memory) {
        return _activeGames.values();
    }
}

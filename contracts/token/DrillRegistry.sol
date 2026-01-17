//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDrillRegistry.sol";

contract DrillRegistry is IDrillRegistry, AccessControl, Ownable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
    }

    function hireManager(address _employee) external onlyOwner {
        _grantRole(MANAGER_ROLE, _employee);
        emit RoleGranted(_employee, MANAGER_ROLE, msg.sender);
    }

    function fireManager(address _employee) external onlyOwner {
        _revokeRole(MANAGER_ROLE, _employee);
        emit RoleRevoked(_employee, MANAGER_ROLE, msg.sender);
    }

    function hireAdmin(address _employee) external onlyRole(MANAGER_ROLE) {
        _grantRole(ADMIN_ROLE, _employee);
        emit RoleGranted(_employee, ADMIN_ROLE, msg.sender);
    }

    function fireAdmin(address _employee) external onlyRole(MANAGER_ROLE) {
        _revokeRole(ADMIN_ROLE, _employee);
        emit RoleRevoked(_employee, ADMIN_ROLE, msg.sender);
    }

    function isAuthorized(address _who, bytes32 _role) external view returns (bool) {
        return hasRole(_role, _who);
    }
}

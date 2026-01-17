// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IDrillRegistry {
    event RoleGranted(address indexed _user, bytes32 _role, address indexed _Who);
    event RoleRevoked(address indexed _user, bytes32 _role, address indexed _Who);

    function isAuthorized(address _who, bytes32 _role) external view returns (bool);
}

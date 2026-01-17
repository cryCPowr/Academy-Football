// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IDrillRegistry.sol";

contract DrillStorage is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    IDrillRegistry public registry;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event FundsDistributed(address indexed token, address indexed to, uint256 amount, string reason);
    event RegistryUpdated(address indexed newRegistry);

    constructor() {
        _disableInitializers();
    }

    function initialize(address _admin, address _registryAddress) public initializer {
        __Ownable_init(_admin);
        __UUPSUpgradeable_init();

        registry = IDrillRegistry(_registryAddress);
    }

    modifier onlyRole(bytes32 _role) {
        require(address(registry) != address(0), "Storage: Registry not set");
        require(registry.isAuthorized(msg.sender, _role), "Storage: Access Denied");
        _;
    }

    function distributeReward(address _token, address _to, uint256 _amount) external onlyRole(MANAGER_ROLE) {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "Insufficient funds");

        IERC20(_token).safeTransfer(_to, _amount);
        emit FundsDistributed(_token, _to, _amount, "Reward Distribution");
    }

    function fundOperations(address _token, address _to, uint256 _amount) external onlyRole(ADMIN_ROLE) {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "Insufficient funds");

        IERC20(_token).safeTransfer(_to, _amount);
        emit FundsDistributed(_token, _to, _amount, "Operational Funding");
    }

    function setRegistry(address _newRegistry) external onlyOwner {
        require(_newRegistry != address(0), "Invalid Address");
        registry = IDrillRegistry(_newRegistry);
        emit RegistryUpdated(_newRegistry);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IDrillRegistry.sol";

contract DrillStorage is Ownable {
    using SafeERC20 for IERC20;

    // --- STATE VARIABLES ---
    IDrillRegistry public registry;

    // --- EVENTS ---
    event FundsDispatched(address indexed token, address indexed to, uint256 amount);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    event EmergencyRecovery(address indexed token, uint256 amount);

    // --- CONSTRUCTOR ---
    constructor(address _registry) Ownable(msg.sender) {
        require(_registry != address(0), "Storage: Invalid Registry");
        registry = IDrillRegistry(_registry);
    }

    // ==========================================
    // 1. FUNGSI UTAMA (Eksekusi Transfer)
    // ==========================================

    /**
     * @notice Kirim duit berdasarkan urutan di list Registry
     * @param _index Urutan game di list (0, 1, 2, dst)
     */
    function fundGameByIndex(address _token, uint256 _index, uint256 _amount) external onlyOwner {
        // 1. Cek dulu panjang array (biar gak error out of bound)
        uint256 count = registry.getGameCount();
        require(_index < count, "Storage: Index out of bound");

        // 2. Ambil SATU alamat aja (Hemat Gas!)
        address targetGame = registry.getGameAt(_index);

        // 3. Transfer
        IERC20(_token).safeTransfer(targetGame, _amount);
        emit FundsDispatched(_token, targetGame, _amount);
    }

    // ==========================================
    // 2. MAINTENANCE
    // ==========================================

    /**
     * @notice Ganti alamat Registry kalau nanti lu upgrade sistem voting.
     */
    function updateRegistry(address _newRegistry) external onlyOwner {
        require(_newRegistry != address(0), "Storage: Invalid address");
        emit RegistryUpdated(address(registry), _newRegistry);
        registry = IDrillRegistry(_newRegistry);
    }

    /**
     * @notice Penyelamatan Token Nyasar (Panic Button).
     * @dev HANYA bisa narik token yang BUKAN $DRILL utama kalau lu mau strict,
     * tapi di sini gua buka untuk semua token demi keamanan aset lu.
     * TAPI, ingat prinsip: Jangan pake ini buat bypass voting manager!
     */
    function recoverStrandedToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit EmergencyRecovery(_token, _amount);
    }
}

import { ethers } from "hardhat";

async function main() {
  const [deployer, manager1] = await ethers.getSigners();

  console.log("====================================================");
  console.log("🚀 Memulai Deployment dengan Akun:", deployer.address);
  console.log("====================================================");

  // 1. Deploy Registry
  const DrillRegistry = await ethers.getContractFactory("DrillRegistry");
  const registry = await DrillRegistry.connect(deployer).deploy();
  await registry.waitForDeployment();
  const registryAddress = await registry.getAddress();
  console.log("✅ DrillRegistry Deployed ke:", registryAddress);

  // 2. Deploy Storage
  const DrillStorage = await ethers.getContractFactory("DrillStorage");
  const storage = await DrillStorage.connect(deployer).deploy(registryAddress);
  await storage.waitForDeployment();
  // Simpan address storage biar gampang dipanggil di bawah
  const storageAddress = await storage.getAddress(); 
  console.log("✅ DrillStorage Deployed ke:", storageAddress);

  // 3. Deploy Token (FIXED: storageAddress sudah string, jadi aman)
  const Token = await ethers.getContractFactory("DrillToken");
  const drillToken = await Token.connect(deployer).deploy(storageAddress);
  await drillToken.waitForDeployment();
  const tokenAddress = await drillToken.getAddress();
  console.log("✅ Mock Token Deployed ke:", tokenAddress);

  // 4. Deploy Game (FIXED: Tambah .connect(deployer) biar konsisten)
  const academyFootball = await ethers.getContractFactory("academyFootball");
  const academyFootballgame = await academyFootball.connect(deployer).deploy(tokenAddress);
  await academyFootballgame.waitForDeployment();
  console.log("✅ academyFootball Deployed ke:", await academyFootballgame.getAddress());

  console.log("\n----------------------------------------------------");
  console.log("⚙️  Melakukan Konfigurasi Awal...");

  console.log(`👷 Merekrut Manager Baru: ${manager1.address}`);
  // Pastikan hireTx ini nunggu konfirmasi blok juga
  const hireTx = await registry.connect(deployer).hireManager(manager1.address);
  await hireTx.wait(); 

  console.log("✨ Manager Berhasil Direkrut!");

  // 6. Cek Status (Validasi - Ini part paling gue suka)
  // Pastikan MANAGER_ROLE public constant di solidity
  const MANAGER_ROLE = await registry.MANAGER_ROLE(); 
  
  // NOTE: Pastikan fungsi di contract namanya 'hasRole' (standar AccessControl) 
  // atau 'isAuthorized' (kalau custom). Cek solidity lo lagi.
  const isManager = await registry.isAuthorized(manager1.address, MANAGER_ROLE);
  
  console.log(`❓ Apakah dia beneran Manager? ${isManager ? "YA" : "TIDAK"}`);
  
  if (!isManager) {
      console.log("⚠️  Waduh, gagal nih. Cek lagi logic access control lo.");
  }

  console.log("----------------------------------------------------");
  console.log("🏁 Deployment Selesai!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
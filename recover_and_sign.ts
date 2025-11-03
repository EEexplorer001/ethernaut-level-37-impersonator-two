// scripts/recover_and_sign.ts

import { ethers } from "ethers";

function modInverse(a: bigint, m: bigint): bigint {
  let [m0, x0, x1] = [m, 0n, 1n];
  let A = a % m;
  if (m === 1n) return 0n;
  while (A > 1n) {
    const q = A / m0;
    [A, m0] = [m0, A % m0];
    [x0, x1] = [x1 - q * x0, x0];
  }
  if (x1 < 0n) x1 += m;
  return x1;
}

async function main() {
  const [rHex, s0Hex, z0Hex, s1Hex, z1Hex, z2Raw, z3Raw] = process.argv.slice(2);
  console.log("------------------check input------------------");
  console.log(rHex, s0Hex, z0Hex, s1Hex, z1Hex, z2Raw, z3Raw);
  console.log("-----------------------------------------------");

  if (!rHex || !s0Hex || !z0Hex || !s1Hex || !z1Hex || !z2Raw || !z3Raw) {
    console.error("Usage: node recover_and_sign.ts <r> <s0> <z0> <s1> <z1> <z2> <z3>");
    process.exit(1);
  }

  const r = BigInt(rHex);
  const s0 = BigInt(s0Hex);
  const z0 = BigInt(z0Hex);
  const s1 = BigInt(s1Hex);
  const z1 = BigInt(z1Hex);

  const n = BigInt("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141");

  // compute nonce k and private key x
  const k = ((z0 - z1) * modInverse(s0 - s1, n)) % n;
  const x = ((s0 * k - z0) * modInverse(r, n)) % n;

  // convert private key bigint → 32-byte hex string
  const xNorm = x < 0n ? x + n : x;
  const privKeyHex = ethers.toBeHex(xNorm, 32);

  const wallet = new ethers.Wallet(privKeyHex);

  // normalize input digests to 32-byte hex
  const z2 = ethers.toBeHex(BigInt(z2Raw), 32);
  const z3 = ethers.toBeHex(BigInt(z3Raw), 32);

  const signingKey = wallet.signingKey;
  const sig2 = signingKey.sign(z2);
  const sig3 = signingKey.sign(z3);

  // serialize to r || s || v hex
  const sig2Hex = ethers.concat([sig2.r, sig2.s, ethers.toBeHex(sig2.v, 1)]);
  const sig3Hex = ethers.concat([sig3.r, sig3.s, ethers.toBeHex(sig3.v, 1)]);

  console.log(sig2Hex);
  console.log(sig3Hex);
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
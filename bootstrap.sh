#!/bin/bash
set -e

# printer pipeline bootstrap script for macOS
# Run this once on a fresh machine. It installs dependencies,
# configures the environment, and prepares the loop.
#
# Usage: chmod +x bootstrap.sh && ./bootstrap.sh

echo "=== printer pipeline bootstrap ==="
echo ""

# --- Step 1: Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "[1/7] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  fi
else
  echo "[1/7] Homebrew already installed."
fi

# --- Step 2: Core tools ---
echo "[2/7] Installing git, gh, node, tmux..."
brew install git gh node tmux 2>/dev/null || true

# --- Step 3: Rust toolchain ---
if ! command -v rustup &>/dev/null; then
  echo "[3/7] Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "[3/7] Rust already installed. Updating..."
  rustup update stable
fi

# --- Step 4: Foundry (for Immunefi audit PoCs) ---
if ! command -v forge &>/dev/null; then
  echo "[4/7] Installing Foundry..."
  curl -L https://foundry.paradigm.xyz | bash
  source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.zshenv" 2>/dev/null || true
  foundryup
else
  echo "[4/7] Foundry already installed. Updating..."
  foundryup
fi

# --- Step 5: GitHub auth ---
echo "[5/7] GitHub authentication..."
if gh auth status &>/dev/null 2>&1; then
  echo "  Already authenticated with GitHub."
  gh auth status
else
  echo "  Opening browser for GitHub login..."
  echo "  Select: HTTPS, authenticate via browser."
  gh auth login -h github.com -p https -w
fi

# --- Step 6: Git identity ---
echo "[6/7] Git identity setup..."
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")

if [[ -z "$CURRENT_NAME" || "$CURRENT_NAME" == *"noreply"* ]]; then
  echo "  Enter the name you want on git commits (your real name):"
  read -r GIT_NAME
  git config --global user.name "$GIT_NAME"
else
  echo "  Git name already set: $CURRENT_NAME"
fi

if [[ -z "$CURRENT_EMAIL" || "$CURRENT_EMAIL" == *"noreply@anthropic"* ]]; then
  echo "  Enter the email on your GitHub account:"
  read -r GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
else
  echo "  Git email already set: $CURRENT_EMAIL"
fi

echo "  GitHub username detected: $GH_USER"

# --- Step 7: Update state.json with github_handle ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/ops/state.json"

if [[ -f "$STATE_FILE" && "$GH_USER" != "unknown" ]]; then
  # Use python3 (ships with macOS) to update JSON safely
  python3 -c "
import json, sys
with open('$STATE_FILE', 'r') as f:
    state = json.load(f)
state['defaults']['github_handle'] = '$GH_USER'
state['blockers'] = [b for b in state.get('blockers', []) if b != 'user_has_not_completed_one_time_setup']
with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
print('  Updated state.json with github_handle: $GH_USER')
print('  Removed setup blocker from state.json')
"
fi

# --- Step 8: Prevent sleep when plugged in ---
echo ""
echo "[post-setup] Preventing sleep while plugged in..."
sudo pmset -a sleep 0 displaysleep 0 2>/dev/null && echo "  Sleep disabled." || echo "  (Skipped — run 'sudo pmset -a sleep 0 displaysleep 0' manually if needed)"

echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Installed: git, gh, node, tmux, rust, foundry"
echo "GitHub user: $GH_USER"
echo "Git identity: $(git config --global user.name) <$(git config --global user.email)>"
echo ""
echo "=== NEXT STEPS (you do these manually) ==="
echo ""
echo "1. Sign up for Algora (start the Stripe Connect clock NOW):"
echo "   https://algora.io  →  Sign in with GitHub  →  Profile  →  Set up payouts"
echo ""
echo "2. Decide on XTM tokens. Edit ops/state.json:"
echo "   \"accept_xtm_tokens\": true   (recommended — enables fast Tari bounties)"
echo "   \"accept_xtm_tokens\": false  (skip Tari, wait for Stripe)"
echo ""
echo "3. (Optional, do later) Sign up for Immunefi + KYC:"
echo "   https://immunefi.com"
echo ""
echo "4. Start the pipeline:"
echo "   cd $(pwd)"
echo "   Open Claude Code, then run:"
echo "   /loop 3h Execute ops/runbooks/00-master-pipeline.md"
echo ""
echo "That's it. The loop handles everything else."

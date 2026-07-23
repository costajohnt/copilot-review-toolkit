#!/usr/bin/env bash
# Fallback installer for pr-review-lenses (copies the agents directly).
# The recommended install is the native Copilot CLI plugin - see README.
#
# Usage:
#   ./install.sh              # install to ~/.copilot/agents (user-level, all repos)
#   ./install.sh --repo       # install to ./.github/agents (current repo only)
#
# Or straight from GitHub (clones to a temp dir, installs, cleans up):
#   curl -fsSL https://raw.githubusercontent.com/costajohnt/pr-review-lenses/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/costajohnt/pr-review-lenses.git"
PLUGIN_SUBDIR="plugins/pr-review-toolkit/agents"

# Pick the target directory.
if [ "${1:-}" = "--repo" ]; then
  DEST="$(pwd)/.github/agents"
else
  DEST="${HOME}/.copilot/agents"
fi

# Find the agents source. If this script sits in a clone, use it. Otherwise
# (curl | bash) clone the repo to a temp dir first.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
CLEANUP=""
if [ -n "${SCRIPT_DIR}" ] && [ -d "${SCRIPT_DIR}/${PLUGIN_SUBDIR}" ]; then
  SRC="${SCRIPT_DIR}/${PLUGIN_SUBDIR}"
else
  TMP="$(mktemp -d)"
  CLEANUP="${TMP}"
  echo "Fetching pr-review-lenses..."
  git clone --depth 1 "${REPO_URL}" "${TMP}/repo" >/dev/null 2>&1
  SRC="${TMP}/repo/${PLUGIN_SUBDIR}"
fi

mkdir -p "${DEST}"
cp "${SRC}"/*.agent.md "${DEST}/"

echo "Installed $(ls -1 "${SRC}"/*.agent.md | wc -l | tr -d ' ') agents to ${DEST}:"
for f in "${DEST}"/*.agent.md; do echo "  - $(basename "$f" .agent.md)"; done

[ -n "${CLEANUP}" ] && rm -rf "${CLEANUP}"

echo
echo "Done. In Copilot CLI, run  /agent  to pick one, or:"
echo "  copilot --agent review-pr -p \"Review this branch against main\""

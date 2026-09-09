#!/usr/bin/env bash
# Installs gififier.
#
#   From a checkout:   ./install.sh [--bin DIR] [--skill HARNESS]
#   From the network:  curl -fsSL https://raw.githubusercontent.com/diegolanda/gififier/main/install.sh | bash
#
# The network form clones the repository into ~/.gififier first. The symlink goes
# to /usr/local/bin when writable, otherwise ~/.local/bin. --skill installs the
# agent skill for a harness (claude, codex, cursor, copilot, agents, all).
set -euo pipefail

REPO_URL="${GIFIFIER_REPO:-https://github.com/diegolanda/gififier.git}"
bin_dir="" skill=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --bin) bin_dir="$2"; shift 2 ;;
    --skill) skill="$2"; shift 2 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) bin_dir="$1"; shift ;;   # legacy positional target
  esac
done

# Locate or fetch the checkout.
if [[ -n "${BASH_SOURCE[0]:-}" && -f "$(dirname "${BASH_SOURCE[0]}")/bin/gififier" ]]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  here="${GIFIFIER_HOME:-$HOME/.gififier}"
  if [[ -d "$here/.git" ]]; then
    echo "updating $here"; git -C "$here" pull -q --ff-only
  else
    echo "cloning into $here"; git clone -q "$REPO_URL" "$here"
  fi
fi

if [[ -z "$bin_dir" ]]; then
  if [[ -w /usr/local/bin ]]; then bin_dir=/usr/local/bin; else bin_dir="$HOME/.local/bin"; fi
fi
mkdir -p "$bin_dir"
ln -sf "$here/bin/gififier" "$bin_dir/gififier"
echo "linked $bin_dir/gififier"
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "note: $bin_dir is not on PATH. Add it, for example: export PATH=\"$bin_dir:\$PATH\"" ;;
esac

[[ -z "$skill" ]] || "$here/install-skill.sh" "$skill"

"$here/bin/gififier" doctor --fix || true

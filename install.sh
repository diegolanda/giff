#!/usr/bin/env bash
# Installs giff.
#
#   From a checkout:   ./install.sh [--bin DIR] [--skill HARNESS]
#   From the network:  curl -fsSL https://raw.githubusercontent.com/diegolanda/giff/main/install.sh | bash
#
# The network form clones the repository into ~/.giff first. The symlink goes
# to /usr/local/bin when writable, otherwise ~/.local/bin. --skill installs the
# agent skill for a harness (claude, codex, cursor, copilot, agents, all).
# --no-fix runs `doctor` without installing anything or requesting permissions.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [--bin DIR] [--skill HARNESS] [--no-fix]
  curl -fsSL https://raw.githubusercontent.com/diegolanda/giff/main/install.sh | bash -s -- [options]

  --bin DIR        Directory for the giff symlink (default /usr/local/bin or ~/.local/bin)
  --skill HARNESS  Also install the agent skill: claude, codex, cursor, copilot, agents, all
  --no-fix         Run `giff doctor` without --fix
EOF
}

main() {

REPO_URL="${GIFF_REPO:-https://github.com/diegolanda/giff.git}"
bin_dir="" skill="" fix=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --bin) bin_dir="$2"; shift 2 ;;
    --skill) skill="$2"; shift 2 ;;
    --no-fix) fix=0; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown option: $1"; usage; exit 1 ;;
    *) bin_dir="$1"; shift ;;   # positional target directory
  esac
done

# Locate or fetch the checkout.
if [[ -n "${BASH_SOURCE[0]:-}" && -f "$(dirname "${BASH_SOURCE[0]}")/bin/giff" ]]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  here="${GIFF_HOME:-$HOME/.giff}"
  if [[ -d "$here/.git" ]]; then
    origin="$(git -C "$here" remote get-url origin 2>/dev/null || true)"
    [[ "$origin" == "$REPO_URL" ]] || { echo "$here is a git checkout of $origin, not giff. Remove it or set GIFF_HOME."; exit 1; }
    echo "updating $here"
    git -C "$here" pull -q --ff-only || { echo "cannot fast-forward $here. Resolve it or remove the directory, then rerun."; exit 1; }
  elif [[ -e "$here" ]]; then
    echo "$here exists and is not a giff checkout. Remove it or set GIFF_HOME."; exit 1
  else
    echo "cloning into $here"; git clone -q "$REPO_URL" "$here" </dev/null
  fi
fi
[[ -x "$here/bin/giff" ]] || { echo "$here does not contain bin/giff"; exit 1; }

if [[ -z "$bin_dir" ]]; then
  if [[ -w /usr/local/bin ]]; then bin_dir=/usr/local/bin; else bin_dir="$HOME/.local/bin"; fi
fi
mkdir -p "$bin_dir"
ln -sf "$here/bin/giff" "$bin_dir/giff"
echo "linked $bin_dir/giff"
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "note: $bin_dir is not on PATH. Add it, for example: export PATH=\"$bin_dir:\$PATH\"" ;;
esac

[[ -z "$skill" ]] || "$here/install-skill.sh" "$skill"

if (( fix )); then
  "$here/bin/giff" doctor --fix || true
else
  "$here/bin/giff" doctor || echo "run: giff doctor --fix"
fi
}

main "$@"

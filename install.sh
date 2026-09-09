#!/usr/bin/env bash
# Links bin/gififier into a directory on PATH and runs the doctor.
# Usage: ./install.sh [target-dir]   (default: /usr/local/bin, or ~/.local/bin if not writable)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-}"
if [[ -z "$target" ]]; then
  if [[ -w /usr/local/bin ]]; then target=/usr/local/bin; else target="$HOME/.local/bin"; fi
fi
mkdir -p "$target"
ln -sf "$here/bin/gififier" "$target/gififier"
echo "linked $target/gififier"
case ":$PATH:" in
  *":$target:"*) ;;
  *) echo "note: $target is not on PATH. Add it, for example: export PATH=\"$target:\$PATH\"" ;;
esac
"$target/gififier" doctor || true

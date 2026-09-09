#!/usr/bin/env bash
# Links bin/gififier into a directory on PATH and compiles the window helper.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-/usr/local/bin}"
mkdir -p "$target"
ln -sf "$here/bin/gififier" "$target/gififier"
echo "linked $target/gififier"
"$target/gififier" doctor || true

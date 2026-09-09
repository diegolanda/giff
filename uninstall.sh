#!/usr/bin/env bash
# Removes the gififier symlink and, with --purge, the cache directory.
# Usage: ./uninstall.sh [--purge] [target-dir]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
purge=0; target=""
for arg in "$@"; do
  case "$arg" in
    --purge) purge=1 ;;
    *) target="$arg" ;;
  esac
done
cache="${GIFIFIER_CACHE:-$HOME/.cache/gififier}"

# Stop a running recording before removing anything.
if [[ -d "$cache/state/capture" ]]; then
  "$here/bin/gififier" stop >/dev/null 2>&1 || true
fi

removed=0
for dir in ${target:+"$target"} /usr/local/bin "$HOME/.local/bin"; do
  link="$dir/gififier"
  if [[ -L "$link" && "$(readlink "$link")" == "$here/bin/gififier" ]]; then
    rm -f "$link"; echo "removed $link"; removed=1
  fi
done
(( removed )) || echo "no gififier symlink found (pass the install directory as an argument)"

if (( purge )); then
  rm -rf "$cache"; echo "removed $cache"
else
  echo "kept $cache (recordings, compiled helper, route cache). Remove it with: $0 --purge"
fi
echo "the repository at $here was not deleted"

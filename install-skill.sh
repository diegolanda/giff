#!/usr/bin/env bash
# Installs the gififier agent skill for one or more harnesses.
#
#   ./install-skill.sh <harness> [--project DIR] [--copy] [--force]
#
# harness:  claude   -> ~/.claude/skills/gififier/            (or DIR/.claude/skills/gififier/)
#           codex    -> ~/.codex/skills/gififier/             (or DIR/.codex/skills/gififier/)
#           cursor   -> DIR/.cursor/rules/gififier.mdc        (project only)
#           copilot  -> DIR/.github/instructions/gififier.instructions.md (project only)
#           agents   -> appends a section to DIR/AGENTS.md    (project only)
#           all      -> every harness above
#
# The source of truth is skills/gififier/SKILL.md (Agent Skills format). Harnesses
# that read SKILL.md directly get a symlink, or a copy with --copy. Harnesses with
# their own format get a generated file with the same body.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$here/skills/gififier"
src="$src_dir/SKILL.md"
project="" copy=0 force=0 harness=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) project="$(cd "$2" && pwd)"; shift 2 ;;
    --copy) copy=1; shift ;;
    --force) force=1; shift ;;
    -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
    *) harness="$1"; shift ;;
  esac
done
[[ -n "$harness" ]] || { sed -n '2,16p' "$0"; exit 1; }

body() { awk 'BEGIN{fm=0} /^---$/ && fm<2 {fm++; next} fm>=2 {print}' "$src"; }
description() { awk -F': ' '/^description:/ {sub(/^description: /, ""); print; exit}' "$src"; }

# place_dir <target dir>: replaces a previous gififier install. Refuses to remove a
# directory that this tool did not create unless --force is given.
place_dir() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" ]]; then
    rm -f "$target"
  elif [[ -e "$target" ]]; then
    if (( force )) || grep -qs '^name: gififier$' "$target/SKILL.md"; then
      rm -rf "$target"
    else
      echo "refusing to replace $target: it was not installed by gififier (use --force)"; return 1
    fi
  fi
  if (( copy )); then cp -R "$src_dir" "$target"; else ln -s "$src_dir" "$target"; fi
  echo "installed $target"
}

install_one() {
  case "$1" in
    claude)
      place_dir "${project:-$HOME}/.claude/skills/gififier" ;;
    codex)
      place_dir "${project:-$HOME}/.codex/skills/gififier" ;;
    cursor)
      [[ -n "$project" ]] || { echo "cursor needs --project DIR"; return 1; }
      local f="$project/.cursor/rules/gififier.mdc"; mkdir -p "$(dirname "$f")"
      { printf -- '---\ndescription: %s\nalwaysApply: false\n---\n' "$(description)"; body; } > "$f"
      echo "installed $f" ;;
    copilot)
      [[ -n "$project" ]] || { echo "copilot needs --project DIR"; return 1; }
      local f="$project/.github/instructions/gififier.instructions.md"; mkdir -p "$(dirname "$f")"
      { printf -- '---\napplyTo: "**"\n---\n'; body; } > "$f"
      echo "installed $f" ;;
    agents)
      [[ -n "$project" ]] || { echo "agents needs --project DIR"; return 1; }
      local f="$project/AGENTS.md" section
      section="$(printf '<!-- gififier:start -->\n'; body; printf '<!-- gififier:end -->')"
      if [[ -f "$f" ]] && grep -q '<!-- gififier:start -->' "$f"; then
        grep -q '<!-- gififier:end -->' "$f" || { echo "$f has a gififier start marker but no end marker. Fix the file first."; return 1; }
        # Replace the block in place. BSD awk cannot take newlines in -v, so read a file.
        local sec; sec="$(mktemp -t gififier-section)"
        printf '%s\n' "$section" > "$sec"
        awk -v sec="$sec" '
          /<!-- gififier:start -->/ { while ((getline line < sec) > 0) print line; skip=1; next }
          /<!-- gififier:end -->/ { skip=0; next }
          !skip { print }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        rm -f "$sec"
      else
        { if [[ -s "$f" ]]; then printf '\n'; fi; printf '%s\n' "$section"; } >> "$f"
      fi
      echo "installed section in $f" ;;
    all)
      install_one claude; install_one codex
      if [[ -n "$project" ]]; then install_one cursor; install_one copilot; install_one agents; fi ;;
    *) echo "unknown harness: $1"; return 1 ;;
  esac
}
install_one "$harness"

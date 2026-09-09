#!/usr/bin/env bash
# Example, not part of giff: upload a file to an orphan "giff-assets"
# branch with the GitHub API and post it as an image on a pull request.
# The orphan branch keeps binary files out of the source history.
#
# Usage: attach-to-pr.sh <file> [--pr N] [--repo owner/name] [--message text] [--no-comment]
# Requires: gh (authenticated), git.
set -euo pipefail

die() { printf 'attach-to-pr: %s\n' "$*" >&2; exit 1; }
is_uint() { [[ "$1" =~ ^[0-9]+$ ]]; }
safe_name() { printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '-' | sed 's/--*/-/g;s/^-*//;s/-*$//'; }

[[ $# -ge 1 ]] || die "usage: attach-to-pr.sh <file> [--pr N] [--repo owner/name] [--message text] [--no-comment]"
file="$1"; shift
[[ -f "$file" && -s "$file" ]] || die "file not found: $file"
pr="" repo="" branch="${ASSET_BRANCH:-giff-assets}" message="" comment=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr) pr="$2"; shift 2 ;;
    --repo) repo="$2"; shift 2 ;;
    --message) message="$2"; shift 2 ;;
    --no-comment) comment=0; shift ;;
    *) die "unknown option: $1" ;;
  esac
done

src_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
[[ "$src_branch" != HEAD ]] || src_branch=""
[[ -n "$repo" ]] || repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" || die "not in a GitHub repo (use --repo)"
gh api "repos/$repo" >/dev/null 2>&1 || die "repository not found or not accessible: $repo"
if (( comment )) && [[ -z "$pr" ]]; then
  [[ -n "$src_branch" ]] || die "not on a git branch (use --pr N)"
  pr="$(gh pr view "$src_branch" --repo "$repo" --json number --jq .number 2>/dev/null || true)"
  [[ -n "$pr" ]] || die "no open PR for branch $src_branch in $repo"
fi

# Create the orphan asset branch once: blob -> tree -> parentless commit -> ref.
if ! gh api "repos/$repo/git/ref/heads/$branch" >/dev/null 2>&1; then
  blob="$(gh api -X POST "repos/$repo/git/blobs" -f content="# assets branch, safe to leave alone" -f encoding=utf-8 --jq .sha)"
  tree="$(gh api -X POST "repos/$repo/git/trees" --input <(printf '{"tree":[{"path":"README.md","mode":"100644","type":"blob","sha":"%s"}]}' "$blob") --jq .sha)"
  commit="$(gh api -X POST "repos/$repo/git/commits" --input <(printf '{"message":"Initialize assets branch","tree":"%s","parents":[]}' "$tree") --jq .sha)"
  gh api -X POST "repos/$repo/git/refs" -f ref="refs/heads/$branch" -f sha="$commit" >/dev/null
fi

base="$(basename "$file")"
ext="${base##*.}"; [[ -n "$ext" && "$ext" != "$base" ]] || ext="bin"
stem="$(safe_name "${base%.*}")"; stem="${stem:-file}"
slug="$(safe_name "${src_branch:-misc}")"; slug="${slug:-misc}"
path="$slug/$(date +%Y%m%d-%H%M%S)-$$-$stem.$(safe_name "$ext")"

payload="$(mktemp -t attach-to-pr)"
trap 'rm -f "$payload"' EXIT
{ printf '{"message":"Add %s","branch":"%s","content":"' "$path" "$branch"; base64 -i "$file" | tr -d '\n'; printf '"}'; } > "$payload"
gh api -X PUT "repos/$repo/contents/$path" --input "$payload" >/dev/null || die "upload failed"

url="https://github.com/$repo/blob/$branch/$path?raw=true"
md="![$stem.$ext]($url)"
[[ -z "$message" ]] || md="$(printf '%s\n\n%s' "$message" "$md")"
if (( comment )); then
  gh pr comment "$pr" --repo "$repo" --body "$md" >/dev/null
  printf 'commented on PR #%s\n' "$pr" >&2
fi
printf '%s\n' "$url"

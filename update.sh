#!/bin/bash

set -eu

WORKDIR=$(git rev-parse --show-toplevel)
imwrt_root="${WORKDIR}/workdir/immortalwrt"

# Resolve version via the 'latest' symlink (same pattern as setup.sh)
imwrt_ver=$(basename "$(readlink -f "${imwrt_root}/latest")")
imwrt_dir="${imwrt_root}/${imwrt_ver}"
feeds_dir="${imwrt_dir}/package/feeds"

if [ ! -d "$feeds_dir" ]; then
  echo "ERROR: $feeds_dir does not exist. Run setup.sh first." >&2
  exit 1
fi

echo "Updating feeds under: $feeds_dir"
echo

for repo in "$feeds_dir"/*/; do
  [ -d "$repo/.git" ] || continue

  name=$(basename "$repo")
  echo "=== $name ==="

  git -C "$repo" fetch origin --prune

  branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD)

  if [ "$branch" != "HEAD" ] && git -C "$repo" rev-parse "origin/$branch" >/dev/null 2>&1; then
    # On a local branch with matching remote
    target="origin/$branch"
  elif git -C "$repo" rev-parse origin/HEAD >/dev/null 2>&1; then
    # origin/HEAD is available
    target="origin/HEAD"
  else
    # Fallback: use the first remote branch
    target=$(git -C "$repo" branch -r | head -1 | sed 's/^[[:space:]]*//')
  fi

  echo "  fetch -> reset --hard $target"
  git -C "$repo" reset --hard "$target"
  echo
done

echo "Done. All feeds updated."
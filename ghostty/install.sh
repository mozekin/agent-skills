#!/usr/bin/env bash
# Install the hacker Ghostty config, themes and shaders.
#
#   ./install.sh          copy files into ~/.config/ghostty
#   ./install.sh --link   symlink instead, so edits in this repo apply live
#
# An existing config is backed up to config.bak.<timestamp> first. Only the
# files shipped here are touched; other themes/shaders you have are left alone.
# Works on Linux and macOS (Ghostty reads ~/.config/ghostty on both).
set -euo pipefail

mode=copy
case "${1:-}" in
  "") ;;
  --link) mode=link ;;
  -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
esac

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
mkdir -p "$dest/themes" "$dest/shaders"

place() { # place <repo-relative path>
  local from="$src/$1" to="$dest/$1"
  if [ "$mode" = link ]; then
    ln -sfn "$from" "$to"
  else
    rm -f "$to"   # drop a stale symlink from an earlier --link install
    cp "$from" "$to"
  fi
  echo "  $mode  $1"
}

# Back up only a config that differs from ours (re-running is a no-op), and
# never overwrite an earlier backup.
if [ -e "$dest/config" ] && ! cmp -s "$dest/config" "$src/config"; then
  backup="$dest/config.bak.$(date +%Y%m%d-%H%M%S)"
  n=1; while [ -e "$backup" ]; do backup="${backup%.~*}.~$n"; n=$((n + 1)); done
  cp -L "$dest/config" "$backup"
  echo "Backed up existing config to $backup"
fi

echo "Installing into $dest"
place config
for f in themes/* shaders/*.glsl; do place "$f"; done

if command -v ghostty >/dev/null 2>&1; then
  echo "Validating..."
  ghostty +validate-config && echo "Config OK."
else
  echo "ghostty not on PATH; skipped validation (run: ghostty +validate-config)."
fi
echo "Reload Ghostty (ctrl+shift+, / cmd+shift+,) to apply."

#!/usr/bin/env bash
# Install the hacker Ghostty config, themes, shaders and Starship prompt.
#
#   ./install.sh          copy files into ~/.config
#   ./install.sh --link   symlink instead, so edits in this repo apply live
#
# Existing configs are backed up to <file>.bak.<timestamp> first. Only the
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
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
dest="$config_home/ghostty"
starship_dest="${STARSHIP_CONFIG:-$config_home/starship.toml}"
mkdir -p "$dest/themes" "$dest/shaders" "$(dirname "$starship_dest")"

# Back up a file only if it differs from ours (re-running is a no-op), and
# never overwrite an earlier backup.
backup() { # backup <installed file> <our file>
  local to="$1" from="$2" bak n=1
  [ -e "$to" ] && ! cmp -s "$to" "$from" || return 0
  bak="$to.bak.$(date +%Y%m%d-%H%M%S)"
  while [ -e "$bak" ]; do bak="${bak%.~*}.~$n"; n=$((n + 1)); done
  cp -L "$to" "$bak"
  echo "  backed up $to -> $bak"
}

install_file() { # install_file <repo file> <destination>
  local from="$src/$1" to="$2"
  if [ "$mode" = link ]; then
    ln -sfn "$from" "$to"
  else
    rm -f "$to"   # drop a stale symlink from an earlier --link install
    cp "$from" "$to"
  fi
  echo "  $mode  $1 -> $to"
}

echo "Installing ($mode)"
backup "$dest/config" "$src/config"
backup "$starship_dest" "$src/starship.toml"
install_file config "$dest/config"
for f in themes/* shaders/*.glsl; do install_file "$f" "$dest/$f"; done
install_file starship.toml "$starship_dest"

if command -v ghostty >/dev/null 2>&1; then
  ghostty +validate-config && echo "Ghostty config OK."
else
  echo "ghostty not on PATH; skipped validation (run: ghostty +validate-config)."
fi

# The prompt needs the starship binary plus one line in your shell's rc file.
shell_name="$(basename "${SHELL:-bash}")"
case "$shell_name" in
  zsh)  rc="$HOME/.zshrc";  hook='eval "$(starship init zsh)"' ;;
  bash) rc="$HOME/.bashrc"; hook='eval "$(starship init bash)"' ;;
  fish) rc="$config_home/fish/config.fish"; hook='starship init fish | source' ;;
  *)    rc=""; hook="" ;;
esac

echo
if ! command -v starship >/dev/null 2>&1; then
  echo "Prompt: install Starship first:"
  if command -v nix >/dev/null 2>&1; then
    # `nix profile install` was renamed to `add` in newer Nix; use whichever
    # this Nix has. The flag makes it work even when flakes are disabled.
    xf="--extra-experimental-features 'nix-command flakes'"
    if nix --extra-experimental-features 'nix-command flakes' profile add --help >/dev/null 2>&1; then
      sub=add
    else
      sub=install
    fi
    # nixpkgs-unstable (26.11+) dropped Intel Macs; 26.05 still supports them
    # (security fixes until end of 2026). Ask Nix for its platform, which is
    # right even when the shell runs under Rosetta.
    nix_system="$(nix --extra-experimental-features nix-command config show system 2>/dev/null \
      || echo "$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')")"
    pkgs=nixpkgs
    case "$nix_system" in
      x86_64-darwin) pkgs=github:NixOS/nixpkgs/nixpkgs-26.05-darwin ;;
    esac
    echo "    nix $xf profile $sub $pkgs#starship"
    echo "  (or programs.starship.enable = true; in Home Manager, see README)"
  elif command -v brew >/dev/null 2>&1; then
    echo "    brew install starship"
  else
    echo "    Install Nix (https://nixos.org/download), then:"
    echo "      nix profile install nixpkgs#starship"
    echo "    or without Nix: curl -sS https://starship.rs/install.sh | sh"
  fi
fi
if [ -n "$rc" ] && ! grep -qs 'starship init' "$rc"; then
  echo "Prompt: add this line to the end of $rc:"
  echo "    $hook"
elif [ -z "$rc" ]; then
  echo "Prompt: see https://starship.rs/#step-2-set-up-your-shell-to-use-starship for $shell_name."
fi
echo "Reload Ghostty (ctrl+shift+, / cmd+shift+,) and open a new tab."

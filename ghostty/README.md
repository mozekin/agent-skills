# 👾 Ghostty hacker config

A Ghostty setup with a cyberpunk look that you can still read all day: neon
magenta and cyan on indigo-black, a blinking block cursor, translucent glass,
a drop-down terminal, a matching Starship prompt with git branch and status,
and two optional shaders (a CRT glow and a neon cursor trail). A matrix-green theme is included as an alternative.

Targets **Ghostty 1.3+**.

```
ghostty/
├── config                  behaviour: font, cursor, window, keybinds
├── themes/
│   ├── cyberpunk-neon      default: neon magenta + cyan
│   └── matrix-phosphor     phosphor green
├── shaders/
│   ├── crt-glow.glsl       scanlines + glow in the text colour + vignette
│   └── cursor-trail.glsl   neon streak when the cursor jumps
├── starship.toml           prompt: path, git branch + status, toolchains
└── install.sh
```

## Install

```sh
cd ghostty
./install.sh           # copy into ~/.config/ghostty and ~/.config/starship.toml
./install.sh --link    # or symlink, so edits here apply live
```

The installer backs up any existing Ghostty `config` and `starship.toml` to
`<file>.bak.<timestamp>`. It leaves your other themes and shaders alone. It
also tells you if Starship isn't installed or your shell isn't hooked up yet
(see [Prompt](#prompt)). If `ghostty` is on your PATH,
it also runs `ghostty +validate-config`. Reload with **ctrl+shift+,**
(**cmd+shift+,** on macOS).

To install by hand, copy `config` to `~/.config/ghostty/config`, and copy
`themes/` and `shaders/` next to it.

## What you get

| | |
|---|---|
| **Readable palette** | Every ANSI color clears 3:1 contrast against the background, and most clear 4.5:1. "Bright black" (used for comments, zsh autosuggestions and dim git text) was raised from a near-invisible 1.8:1 to 4.65:1. |
| **Block cursor that stays a block** | Ghostty's shell integration normally turns the cursor into a bar at the prompt. `no-cursor` keeps the blinking neon block. |
| **SSH just works** | `ssh-env` and `ssh-terminfo` stop "unknown terminal type xterm-ghostty" errors on remote hosts. |
| **Glass window** | 92% opacity with blur on macOS and KDE. Elsewhere you get plain transparency. |
| **Edge-to-edge TUIs** | `window-padding-color = extend` paints the padding to match htop, lazygit or vim backgrounds. |
| **Drop-down terminal** | **ctrl+`** from anywhere slides a terminal down from the top of the screen. |
| **Focused pane stands out** | Inactive splits are dimmed, and split dividers use the theme accent. |
| **Never-invisible text** | `minimum-contrast = 1.1` rescues programs that print text in the background color. |

## Prompt

Ghostty only draws the terminal. The prompt line comes from your shell, so it
uses [Starship](https://starship.rs) with a matching palette:

```
╭─ ~/code/agent-skills/ghostty  on  main +2 !3 ?1 ⇡2  via  22.11.0  took 14s
╰─❯
```

- **Path**: inside a repo the repo name is highlighted in neon pink, and long
  paths are shortened to the last 4 folders.
- **Git**: the branch name, then status counts. You'll also see
  `(REBASING 2/5)` style state during rebases and merges, and the commit hash
  when HEAD is detached.

  | | | | |
  |---|---|---|---|
  | `✓` clean | `+N` staged | `!N` modified | `?N` untracked |
  | `✘N` deleted | `»N` renamed | `*N` stashed | `=N` conflicts |
  | `⇡N` ahead | `⇣N` behind | | |

- **Toolchains**: the Node, Python (with venv), Rust, Go or Docker version,
  shown only inside matching projects.
- **Extras**: `took 14s` for commands slower than 2s, `✘ 1` with the exit
  code of a failed command, `✦N` for background jobs, and `user@host` only
  over SSH. The `❯` caret turns red after a failure.

**Setup** (one time):

1. Install Starship with Nix:

   ```sh
   nix profile install nixpkgs#starship   # flakes on (default with Determinate Nix)
   nix-env -iA nixpkgs.starship           # classic channels, flakes off
   ```

   No Nix yet? Install it from [nixos.org/download](https://nixos.org/download)
   or with the [Determinate installer](https://determinate.systems/nix-installer/),
   then open a new terminal. If you'd rather skip Nix, Homebrew
   (`brew install starship`) and `curl -sS https://starship.rs/install.sh | sh`
   also work.
2. Add the hook to the end of your shell's startup file:

   | Shell | File | Line |
   |---|---|---|
   | zsh (macOS default) | `~/.zshrc` | `eval "$(starship init zsh)"` |
   | bash | `~/.bashrc` | `eval "$(starship init bash)"` |
   | fish | `~/.config/fish/config.fish` | `starship init fish \| source` |

3. Open a new tab.

### Using Home Manager instead of install.sh

If you manage your dotfiles with [Home Manager](https://github.com/nix-community/home-manager)
(standalone or through nix-darwin), let it install Starship and place every
file. Copy this `ghostty/` folder next to your `home.nix`, then add:

```nix
{
  # Installs starship and adds the hook to shells Home Manager manages
  # (programs.zsh / bash / fish). Leave `settings` unset so Home Manager
  # doesn't write its own starship.toml over ours.
  programs.starship.enable = true;

  xdg.configFile = {
    "starship.toml".source  = ./ghostty/starship.toml;
    "ghostty/config".source = ./ghostty/config;
    "ghostty/themes".source  = ./ghostty/themes;
    "ghostty/shaders".source = ./ghostty/shaders;
  };
}
```

Then run `home-manager switch` (or `darwin-rebuild switch`). Don't also run
`install.sh`: it would replace Home Manager's links, and the next switch
would fail with "existing file is in the way". If Home Manager doesn't manage
your shell, add the `eval "$(starship init zsh)"` line to `~/.zshrc` yourself.
Files placed this way are read-only links into the Nix store, so edit the
copies next to `home.nix` and switch again.

Icons are Nerd Font glyphs. Ghostty bundles them, so they work without
installing a Nerd Font. Git status is skipped after 1s in very large repos
(`command_timeout` in `starship.toml`).

## Switch themes

Change one line in `config`:

```
theme = matrix-phosphor
```

and the matching line in `starship.toml`:

```
palette = "matrix_phosphor"
```

To follow your OS light/dark setting, use
`theme = light:<a light theme>,dark:cyberpunk-neon`. Run `ghostty +list-themes`
to see the built-in themes.

## Shaders (optional)

Uncomment one or both lines in `config`. They stack in the order listed:

```
custom-shader = shaders/crt-glow.glsl
custom-shader = shaders/cursor-trail.glsl
```

- **crt-glow**: the glow uses each glyph's own color, so it looks neon under
  cyberpunk and green under matrix. Empty cells never glow, and the window's
  transparency is kept. Tune `BLOOM`, `SCANLINE` and `VIGNETTE` at the top of
  the file.
- **cursor-trail**: a short tapered streak in the cursor color whenever the
  cursor jumps (new line, vim motion, click). Normal typing leaves no trail.
  Tune `DURATION` and `INTENSITY`.

Shaders use a little GPU and only animate while the window is focused. If a
shader fails to compile, Ghostty skips it and logs the error. Config
validation won't report it.

## Fonts

JetBrains Mono comes bundled with Ghostty, so the config works without
installing anything. For prompt icons (Starship, Powerlevel10k), install a
Nerd Font and set:

```
font-family = JetBrainsMono Nerd Font
```

Add `font-feature = -calt` to turn ligatures off. `adjust-cell-height = 8%`
adds line spacing; set it to `0` for a tighter grid.

## Platform notes

- **Drop-down terminal on Linux** needs a desktop whose XDG portal supports
  GlobalShortcuts (GNOME and KDE do). On macOS, grant Ghostty Accessibility
  permission the first time you use it.
- **Blur** works on macOS and KDE Plasma. Other compositors ignore it.
- `font-thicken` and the commented `macos-*` options only apply on macOS.
- **256-color apps**: uncomment `palette-generate = true` to build colors
  16–255 from the theme so btop and some vim/tmux themes match. It's off by
  default because a few old programs expect the standard xterm colors.

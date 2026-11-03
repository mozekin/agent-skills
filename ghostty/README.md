# 👾 Ghostty hacker config

A Ghostty setup with a cyberpunk look that you can still read all day: neon
magenta and cyan on indigo-black, a blinking block cursor, translucent glass,
a drop-down terminal, and two optional shaders (a CRT glow and a neon cursor
trail). A matrix-green theme is included as an alternative.

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
└── install.sh
```

## Install

```sh
cd ghostty
./install.sh           # copy into ~/.config/ghostty
./install.sh --link    # or symlink, so edits here apply live
```

The installer backs up any existing `config` to `config.bak.<timestamp>`.
It leaves your other themes and shaders alone. If `ghostty` is on your PATH,
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

## Switch themes

Change one line in `config`:

```
theme = matrix-phosphor
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

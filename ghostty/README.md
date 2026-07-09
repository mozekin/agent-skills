# 👾 Ghostty "phosphor" — a hacker terminal theme

A matrix-green Ghostty theme: deep green-black background, comfortable phosphor
foreground, a blinking green block cursor, subtle transparency + blur, and an
optional CRT-glow shader. Tuned to actually be *readable* all day, not just
look cool in a screenshot.

```
┌────────────────────────────────────────────┐
│  $ whoami                                    │
│  root                                        │
│  $ ./exploit --target localhost --pwn        │
│  [+] shell acquired ▓                         │
└────────────────────────────────────────────┘
```

## Install

Ghostty reads a single plain-text config file. Copy `config` there:

**Linux**
```sh
mkdir -p ~/.config/ghostty
cp config ~/.config/ghostty/config
# optional CRT shader:
mkdir -p ~/.config/ghostty/shaders
cp shaders/crt-glow.glsl ~/.config/ghostty/shaders/
```

**macOS** (Ghostty also reads the XDG path above, or use its own dir)
```sh
mkdir -p "~/Library/Application Support/com.mitchellh.ghostty"
cp config "~/Library/Application Support/com.mitchellh.ghostty/config"
```

Reload with **Cmd/Ctrl+Shift+,** or just restart Ghostty. Check for typos with:

```sh
ghostty +show-config          # what Ghostty actually parsed
ghostty +validate-config      # report errors/unknown keys
```

## Turn on the CRT glow (optional)

Uncomment these two lines in `config` after copying the shader:

```
custom-shader = shaders/crt-glow.glsl
custom-shader-animation = true
```

It adds faint scanlines, a green bloom, and a vignette. Tune the three constants
at the top of `crt-glow.glsl`, or set `BLOOM = 0.0` to drop the glow. Comment the
lines back out if you ever notice GPU cost.

## Fonts

The config uses **JetBrains Mono**, which ships bundled with Ghostty, so it
always works. For the full hacker look, install a Nerd Font (adds glyphs/icons
for prompts like Starship, Powerlevel10k) and swap the line:

```
font-family = JetBrainsMono Nerd Font   # or "FiraCode Nerd Font", "Hack Nerd Font"
```

Ligatures are on by default — add `font-feature = -calt` to disable them.

## Alternate palettes

Same layout, different vibe. Replace the **Core colors**, **ANSI palette**, and
**Cursor** blocks in `config` with one of these.

### 🔮 Cyberpunk (neon magenta + cyan)

```
background = #0b0b16
foreground = #e6e6fa
cursor-color = #ff2e97

palette = 0=#0b0b16
palette = 1=#ff2e63
palette = 2=#00f5a0
palette = 3=#ffd23f
palette = 4=#3d84ff
palette = 5=#c724b1
palette = 6=#2ce8f5
palette = 7=#c7c7e6
palette = 8=#3a3a5a
palette = 9=#ff5c8a
palette = 10=#5cffc0
palette = 11=#ffe066
palette = 12=#6aa9ff
palette = 13=#e56bff
palette = 14=#72f9ff
palette = 15=#ffffff
```

### 🟠 Amber phosphor (old-school CRT)

```
background = #100a02
foreground = #ffb000
cursor-color = #ffb000

palette = 0=#100a02
palette = 1=#ff5f00
palette = 2=#d7a500
palette = 3=#ffb000
palette = 4=#c08a2e
palette = 5=#e58f65
palette = 6=#e0a458
palette = 7=#ffcc66
palette = 8=#5a3d1a
palette = 9=#ff7f2a
palette = 10=#ffc94d
palette = 11=#ffd27f
palette = 12=#e0a86b
palette = 13=#ffb27f
palette = 14=#ffcf99
palette = 15=#fff0c0
```

## Notes

- If your Ghostty build rejects `background-blur = 20`, use `background-blur = true`
  or `background-blur-radius = 20`.
- Ghostty warns about unknown keys but still loads — `+validate-config` shows them.
- Prefer a built-in theme instead? `ghostty +list-themes` and set `theme = <name>`.

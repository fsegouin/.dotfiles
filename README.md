# dotfiles

## Claude Code Config

The `claude/` directory tracks portable Claude Code configuration. A sync script keeps it in sync with `~/.claude`.

### What's synced

| Item | Description |
|------|-------------|
| `CLAUDE.md` | Global instructions |
| `settings.json` | Global settings |
| `settings.local.json` | Local settings |
| `commands/` | Custom slash commands |
| `skills/` | Custom skills |
| `mcp-servers.json` | MCP server config (tokens redacted) |

Ephemeral and sensitive data (credentials, history, cache, debug logs, telemetry, session data) is excluded.

### MCP server handling

MCP server configuration is extracted from `~/.claude.json` and saved separately as `mcp-servers.json`. Env vars with names matching `token`, `secret`, `key`, `password`, or `credential` are automatically replaced with `REDACTED`. Non-sensitive values (like URLs) are kept as-is.

On pull, the server structure is merged back into `~/.claude.json` without overwriting existing env values, so real tokens are never replaced with `REDACTED`.

### Usage

```sh
# Copy ~/.claude config into dotfiles (for committing)
./sync-claude.sh push

# Copy dotfiles config into ~/.claude (on a new machine)
./sync-claude.sh pull

# Show differences between the two
./sync-claude.sh diff
```

## Hyprland & Waybar Config

The `hypr/` and `waybar/` directories track personal Hyprland and Waybar customizations on top of [ml4w dotfiles](https://github.com/mylinuxforwork/dotfiles).

### What's synced

| Item | Description |
|------|-------------|
| `hypr/conf/custom.conf` | Custom keybinds, blur rules, window opacity |
| `hypr/conf/cursor.conf` | Cursor theme |
| `hypr/conf/keyboard.conf` | Keyboard and input settings |
| `hypr/monitors.conf` | Monitor layout (nwg-displays) |
| `hypr/workspaces.conf` | Workspace assignments |
| `hypr/hypridle.conf` | Idle and lock timeouts |
| `hypr/hyprlock.conf` | Lock screen appearance |
| `waybar/themes/flot-minimalist/` | Custom macOS-style Waybar theme |

ml4w-managed defaults (animations, decorations, window styles, colors) are excluded.

### Usage

```sh
# Copy live config into dotfiles (for committing)
./sync-hypr.sh push

# Copy dotfiles config into live config (on a new machine)
./sync-hypr.sh pull

# Show differences between the two
./sync-hypr.sh diff
```

## Setup on a new machine

1. Clone this repo to `~/.dotfiles`
2. Run `./sync-claude.sh pull` to populate `~/.claude`
3. Fill in redacted tokens in `~/.claude.json` manually
4. Install [ml4w dotfiles](https://github.com/mylinuxforwork/dotfiles), then run `./sync-hypr.sh pull` to apply Hyprland/Waybar customizations

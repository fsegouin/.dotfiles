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

### Setup on a new machine

1. Clone this repo to `~/.dotfiles`
2. Run `./sync-claude.sh pull` to populate `~/.claude`
3. Fill in redacted tokens in `~/.claude.json` manually

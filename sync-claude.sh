#!/usr/bin/env bash
set -euo pipefail

DOTFILES_CLAUDE="$HOME/.dotfiles/claude"
LIVE_CLAUDE="$HOME/.claude"
LIVE_CLAUDE_JSON="$HOME/.claude.json"
MCP_TEMPLATE="$DOTFILES_CLAUDE/mcp-servers.json"

# Files and directories to sync (config only, no ephemeral/sensitive data)
SYNC_ITEMS=(
  CLAUDE.md
  settings.json
  settings.local.json
  commands
  skills
)

usage() {
  echo "Usage: $(basename "$0") <push|pull|diff>"
  echo
  echo "  push   Copy from ~/.claude into dotfiles repo"
  echo "  pull   Copy from dotfiles repo into ~/.claude"
  echo "  diff   Show differences between the two"
  exit 1
}

sync_item() {
  local src="$1" dst="$2" item="$3"
  local src_path="$src/$item"
  local dst_path="$dst/$item"

  if [[ ! -e "$src_path" ]]; then
    return
  fi

  if [[ -d "$src_path" ]]; then
    mkdir -p "$dst_path"
    rsync -a --delete "$src_path/" "$dst_path/"
  else
    mkdir -p "$(dirname "$dst_path")"
    rsync -a "$src_path" "$dst_path"
  fi
}

push_mcp() {
  if [[ ! -f "$LIVE_CLAUDE_JSON" ]]; then
    return
  fi
  mkdir -p "$DOTFILES_CLAUDE"
  # Extract mcpServers and redact sensitive env values
  jq '.mcpServers | walk(
    if type == "object" and has("env") then
      .env |= with_entries(
        if (.key | test("token|secret|key|password|credential"; "i"))
        then .value = "REDACTED"
        else .
        end
      )
    else .
    end
  )' "$LIVE_CLAUDE_JSON" > "$MCP_TEMPLATE"
  echo "  MCP server config saved (tokens redacted)"
}

pull_mcp() {
  if [[ ! -f "$MCP_TEMPLATE" ]]; then
    return
  fi
  if [[ ! -f "$LIVE_CLAUDE_JSON" ]]; then
    echo "  Warning: $LIVE_CLAUDE_JSON not found, skipping MCP merge"
    return
  fi
  # Merge server structure from template, preserving existing env values
  local merged
  merged=$(jq --slurpfile tpl "$MCP_TEMPLATE" '
    .mcpServers as $live |
    ($tpl[0] | to_entries | map(
      .key as $name |
      if $live[$name] then
        .value.env = ($live[$name].env // .value.env)
      else .
      end
    ) | from_entries) as $merged |
    .mcpServers = $merged
  ' "$LIVE_CLAUDE_JSON")
  echo "$merged" > "$LIVE_CLAUDE_JSON"
  echo "  MCP server config merged (existing tokens preserved)"
}

diff_mcp() {
  if [[ ! -f "$MCP_TEMPLATE" ]]; then
    return
  fi
  local current
  current=$(jq '.mcpServers | walk(
    if type == "object" and has("env") then
      .env |= with_entries(
        if (.key | test("token|secret|key|password|credential"; "i"))
        then .value = "REDACTED"
        else .
        end
      )
    else .
    end
  )' "$LIVE_CLAUDE_JSON" 2>/dev/null) || return
  diff -u --label "dotfiles/mcp-servers.json" --label "live (redacted)" \
    "$MCP_TEMPLATE" <(echo "$current") || true
}

diff_item() {
  local item="$1"
  local live="$LIVE_CLAUDE/$item"
  local repo="$DOTFILES_CLAUDE/$item"

  if [[ -d "$live" || -d "$repo" ]]; then
    diff -rq "$live" "$repo" 2>/dev/null || true
  elif [[ -f "$live" && -f "$repo" ]]; then
    diff -u "$repo" "$live" 2>/dev/null || true
  elif [[ -f "$live" ]]; then
    echo "Only in ~/.claude: $item"
  elif [[ -f "$repo" ]]; then
    echo "Only in dotfiles: $item"
  fi
}

[[ $# -eq 1 ]] || usage

case "$1" in
  push)
    echo "Pushing ~/.claude config into dotfiles..."
    for item in "${SYNC_ITEMS[@]}"; do
      sync_item "$LIVE_CLAUDE" "$DOTFILES_CLAUDE" "$item"
    done
    push_mcp
    echo "Done. Review changes with: cd ~/.dotfiles && git diff"
    ;;
  pull)
    echo "Pulling dotfiles config into ~/.claude..."
    for item in "${SYNC_ITEMS[@]}"; do
      sync_item "$DOTFILES_CLAUDE" "$LIVE_CLAUDE" "$item"
    done
    pull_mcp
    echo "Done."
    ;;
  diff)
    for item in "${SYNC_ITEMS[@]}"; do
      diff_item "$item"
    done
    diff_mcp
    ;;
  *)
    usage
    ;;
esac

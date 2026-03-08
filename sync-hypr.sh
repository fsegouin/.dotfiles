#!/usr/bin/env bash
set -euo pipefail

DOTFILES_HYPR="$HOME/.dotfiles/hypr"
DOTFILES_WAYBAR="$HOME/.dotfiles/waybar"
LIVE_HYPR="$HOME/.config/hypr"
LIVE_WAYBAR="$HOME/.config/waybar"

# Personal customization files only (not ml4w-managed defaults)
SYNC_FILES=(
  conf/custom.conf
  conf/cursor.conf
  conf/keyboard.conf
  monitors.conf
  workspaces.conf
  hypridle.conf
  hyprlock.conf
)

# Custom waybar theme directory
WAYBAR_THEME="themes/flot-minimalist"

usage() {
  echo "Usage: $(basename "$0") <push|pull|diff>"
  echo
  echo "  push   Copy from ~/.config/hypr into dotfiles repo"
  echo "  pull   Copy from dotfiles repo into ~/.config/hypr"
  echo "  diff   Show differences between the two"
  exit 1
}

sync_file() {
  local src="$1" dst="$2" file="$3"
  local src_path="$src/$file"
  local dst_path="$dst/$file"

  if [[ ! -f "$src_path" ]]; then
    return
  fi

  mkdir -p "$(dirname "$dst_path")"
  rsync -a "$src_path" "$dst_path"
}

diff_file() {
  local file="$1"
  local live="$LIVE_HYPR/$file"
  local repo="$DOTFILES_HYPR/$file"

  if [[ -f "$live" && -f "$repo" ]]; then
    diff -u --label "dotfiles/$file" --label "live/$file" "$repo" "$live" || true
  elif [[ -f "$live" ]]; then
    echo "Only in ~/.config/hypr: $file"
  elif [[ -f "$repo" ]]; then
    echo "Only in dotfiles: $file"
  fi
}

[[ $# -eq 1 ]] || usage

sync_dir() {
  local src="$1" dst="$2"
  if [[ ! -d "$src" ]]; then
    return
  fi
  mkdir -p "$dst"
  rsync -a --delete "$src/" "$dst/"
}

diff_dir() {
  local label="$1" live="$2" repo="$3"
  if [[ -d "$live" && -d "$repo" ]]; then
    diff -ru --label "dotfiles/$label" --label "live/$label" "$repo" "$live" || true
  elif [[ -d "$live" ]]; then
    echo "Only in live: $label/"
  elif [[ -d "$repo" ]]; then
    echo "Only in dotfiles: $label/"
  fi
}

case "$1" in
  push)
    echo "Pushing customizations into dotfiles..."
    for file in "${SYNC_FILES[@]}"; do
      sync_file "$LIVE_HYPR" "$DOTFILES_HYPR" "$file"
    done
    sync_dir "$LIVE_WAYBAR/$WAYBAR_THEME" "$DOTFILES_WAYBAR/$WAYBAR_THEME"
    echo "Done. Review changes with: cd ~/.dotfiles && git diff"
    ;;
  pull)
    echo "Pulling dotfiles config into live config..."
    for file in "${SYNC_FILES[@]}"; do
      sync_file "$DOTFILES_HYPR" "$LIVE_HYPR" "$file"
    done
    sync_dir "$DOTFILES_WAYBAR/$WAYBAR_THEME" "$LIVE_WAYBAR/$WAYBAR_THEME"
    echo "Done."
    ;;
  diff)
    for file in "${SYNC_FILES[@]}"; do
      diff_file "$file"
    done
    diff_dir "waybar/$WAYBAR_THEME" "$LIVE_WAYBAR/$WAYBAR_THEME" "$DOTFILES_WAYBAR/$WAYBAR_THEME"
    ;;
  *)
    usage
    ;;
esac

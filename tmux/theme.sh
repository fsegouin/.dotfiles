#!/bin/bash

#tm_icon="♟"
tm_color_background=black
tm_color_active=colour8
tm_color_inactive=colour244
tm_color_feature=colour4
tm_color_music=colour1

# separators
tm_left_separator=''
tm_left_separator_black=''
tm_right_separator=''
tm_right_separator_black=''
tm_session_symbol=''

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 5

# default statusbar colors
# set-option -g status-bg colour0
set-option -g status-fg default
set-option -g status-bg black
set-option -g status-attr default

# default window title colors
set-window-option -g window-status-fg colour8
set-window-option -g window-status-bg $tm_color_background
set -g window-status-format " #I #W"

# active window title colors
set-window-option -g  window-status-current-format "#[fg=$tm_color_background,bg=$tm_color_active]$tm_left_separator_black #[fg=colour10,bg=$tm_color_active,bold]#I #W #[bg=$tm_color_background,fg=$tm_color_active]$tm_left_separator_black "

# pane border
set-option -g pane-border-fg $tm_color_inactive
set-option -g pane-active-border-fg $tm_color_active

# message text
set-option -g message-bg default
set-option -g message-fg $tm_color_active

# pane number display
set-option -g display-panes-active-colour $tm_color_active
set-option -g display-panes-colour $tm_color_inactive

tm_spotify="#[fg=$tm_color_background,bg=$tm_color_music]#(osascript ~/.dotfiles/applescripts/spotify.scpt)"
tm_itunes="#[fg=$tm_color_music,bg=$tm_color_background]$tm_right_separator_black#[fg=$tm_color_background,bg=$tm_color_music]#(osascript ~/.dotfiles/applescripts/itunes.scpt)"
tm_battery="#[fg=colour255,bg=$tm_color_music]$tm_right_separator_black#[bg=colour255]#(~/.dotfiles/bin/battery_indicator.sh)"

tm_date="#[bg=colour255,fg=$tm_color_inactive]$tm_right_separator_black#[bg=$tm_color_inactive,fg=colour10] %R %d %b  "
tm_host="#[bg=$tm_color_inactive,fg=$tm_color_feature]$tm_right_separator_black#[bg=$tm_color_feature,fg=$tm_color_background,bold] #h "
tm_session_name="#[bg=$tm_color_feature,fg=colour10,bold] #S #[fg=$tm_color_feature,bg=default,nobold]$tm_left_separator_black"

set -g status-left $tm_session_name
# set -g status-right $tm_itunes' '$tm_spotify' '$tm_battery' '$tm_date' '$tm_host
set -g status-right $tm_itunes' '$tm_spotify' '$tm_battery' '$tm_date

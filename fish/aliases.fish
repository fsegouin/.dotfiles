# GREP AND FIND
alias y 'grep -Ri'
alias n 'grep -Rvi'
alias f 'find . -regex'

# DU
alias ducks 'du -ckhs * | gsort -hr' # Needs coreutils installed

# CD
alias ... 'cd ../../'
alias .... 'cd ../../../'
alias ..... 'cd ../../../../'

# MISC
alias c 'clear'
alias w 'cd ~/Work'
alias h 'history'
alias t 'tree -L 2'
alias g 'git'
alias search 'grep -r . -e'

# APPS
alias ios 'open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'

# SYSTEM
# Resets
alias kd 'killall Dock'
alias kf 'killall Finder'

# Show/hide hidden files in Finder
alias showfinder 'defaults write com.apple.Finder AppleShowAllFiles -bool TRUE ; kf'
alias hidefinder 'defaults write com.apple.Finder AppleShowAllFiles FALSE ; kf'

# Hide/show all desktop icons (useful when presenting)
alias showdesktop 'defaults write com.apple.finder CreateDesktop -bool true ; kf'
alias hidedesktop 'defaults write com.apple.finder CreateDesktop -bool false ; kf'

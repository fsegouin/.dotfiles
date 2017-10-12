# Load aliases
. ~/.config/fish/aliases.fish

# Ruby stuff
rvm default

# Go stuff
set -x GOPATH $HOME/.go
set -x GOROOT /usr/local/opt/go/libexec
set PATH $GOROOT/bin $PATH

# nvm stuff
set PATH $HOME/.nvm/versions/node/(node -v)/bin $PATH

#!/bin/bash
# Install dotfiles and stuff - for OS X only
#
# Inspired by uZer
# https://github.com/uZer/.schematics
#
# Warning: still not ready for use
#
# Florent Segouin 2015
# <florent@segouin.me>

###############################################################################
# ENVIRONMENT

# Install selection
# Default: all
INST_NVM              = "true"  # Enable NVM
INST_RVM              = "true"  # Enable RVM
INST_ITERM            = "true"  # Enable iTerm
INST_POF              = "true"  # Enable Powerline-Font
INST_SPF13VIM         = "true"  # Enable spf13-vim
INST_OHMYZSH          = "true"  # Enable oh-my-zsh
INST_DOCKERTOOLBOX    = "true"  # Enable Docker Toolbox
INST_VAGRANT          = "true"  # Enable Vagrant
INST_THEUNARCHIVER    = "true"  # Enable The Unarchiver
INST_SLACK            = "true"  # Enable Slack
INST_WEECHAT          = "true"  # Enable WeeChat

# Dotfiles path
DOT_PATH="$HOME/.dotfiles"

###############################################################################
# Helpers
is_nvm_installed() {
  which nvm >/dev/null
}

is_rvm_installed() {
  which rvm >/dev/null
}

is_brew_installed() {
  which brew >/dev/null
}

is_brew_cask_installed() {
  brew cask >/dev/null
}

is_app_installed() {
  find /Applications -iname "$1*" -maxdepth 1 | egrep -q '.*'
}

is_app_installed_with_brew() {
  brew list -1 | egrep -q "$1"
}

is_app_installed_with_brew_cask() {
  brew cask list -1 | egrep -q "$1"
}

makelink ()
{
    _SOURCE="$1"
    _DEST="$2"

    # Source doesn't exist
    if [ ! -e "$_SOURCE" ]; then
        echo "ERROR: Source file doesn't exist" 1>&2
        return 1
    fi

    # Destination exists as a symbolic link
    if [ -L "$_DEST" ]; then
        echo "  Unlinking $_DEST..."

        # Unlink and test
        rm ${_DEST}
        [ "$?" -ne "0" ] && "ERROR: Can't unlink file." 1>&2 && return 2
    fi

    # Destination exists as a file or folder
    if [ -e "$_DEST" ]; then
        echo "  Making backup dir $_DEST..."

        # Created backup folder
        mkdir -p ${_BACKUPDIR} 2>/dev/null

        # Move the file/folder and check results
        mv ${_DEST} ${_BACKUPDIR}
        [ "$?" -ne "0" ] \
            && "ERROR: Can't make backup. Please check permissions." 1>&2 \
            && return 3
    fi

    # Make the new link
    ln -s $_SOURCE $_DEST
    return 0
}

###############################################################################
# Make sure Git is installed
checkGit ()
{
    if [ ! "which git" ] ; then
      echo "  Installing Git..."
      xcode-select --install
    fi
    else
      echo "  Git... OK"
    fi
}

# Make sure Homebrew and Homebrew Cask are installed
checkHomebrew ()
{
    if is_brew_installed; then
      echo "  Homebrew... OK"
    else
      echo "  Installing Homebrew..."
      ruby \
        -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
        </dev/null
      echo ""
    else

    fi

    if ! is_app_installed_with_brew "wget"; then
      echo "  Installing wget..."
      brew install wget
      echo ""
    fi

    if is_brew_cask_installed; then
      echo "  Homebrew Cask... OK"
    else
      echo "  Installing Homebrew Cask..."
      brew install caskroom/cask/brew-cask
      echo ""
    fi
}

# [RVM]
# Installing Ruby Version Manager
installRvm ()
{
    if is_rvm_installed ; then
      echo "  RVM... OK"
    else
      echo "  Installing RVM..."
      \curl -sSL https://get.rvm.io | bash -s stable --ruby </dev/null
      echo ""
    fi
}

# [NVM]
# Installing Node Version Manager
installNvm ()
{
    if is_nvm_installed; then
      echo "  NVM... OK"
    else
      echo "  Installing NVM..."
      curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash \
        </dev/null
      nvm install stable
      nvm use stable
      nvm alias default stable
      echo ""
    fi
}

# [iTerm2]
# Installing iTerm2 config
installIterm2 ()
{
    echo "[ITERM2]"
    if is_app_installed "iTerm" || is_app_installed_with_brew_cask "iTerm"; then
      echo "  iTerm2 is already installed. Skipping..."
      echo ""
      return 4
    else
      echo "  Installing iTerm2..."
      brew cask install iterm2
      echo "  Installing iTerm2 config..."
      plutil -convert binary1 -o $HOME/Library/Preferences/com.googlecode.iterm2.plist \
          $DOT_PATH/iterm2/com.googlecode.iterm2.plist
      return
    fi
}

# [POWERLINE FONTS]
# Copying Meslo font in ~/Library/Fonts
# Recommended: Meslo LG S Regular
installPowerlineFonts ()
{
    echo "[POWERLINE FONTS]"
    echo "  Downloading font files..."
    wget -q -O $HOME/Library/Fonts/Meslo\ LG\ S\ Regular\ for\ Powerline.otf \
    https://github.com/powerline/fonts/blob/master/Meslo/Meslo%20LG%20S%20Regular%20for%20Powerline.otf \
        1>&2>/dev/null
    echo ""
    return
}

# [VIM]
# Installing spf13-vim distribution
installVim ()
{
    echo "[VIM]"
    echo "  Installing spf13-vim..."
    echo "  INFO: This script will install vundle and some good vim plugins."
    curl http://j.mp/spf13-vim3 -L -o - | sh

    echo ""
    return
}

# [ZSH]
# Linking zsh configuration files
# Installing oh-my-zsh
installZSH ()
{
    echo "[ZSH]"
    echo "  Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    echo ""

    echo "  Installing Custom Themes..."
    wget -q -O $HOME/.oh-my-zsh/themes/agnoster-nanof.zsh-theme \
    https://raw.githubusercontent.com/fsegouin/oh-my-zsh-agnoster-mod-theme/master/agnoster-nanof.zsh-theme \
        1>&2>/dev/null

    echo ""
    echo "  Linking zsh configuration files..."
    makelink "$DOT_PATH/zsh/zshrc" "$HOME/.zshrc"

    echo ""
    return
}

# [DOCKERTOOLBOX]
# Installing Docker Toolbox
installDockerToolbox ()
{
    echo "[DOCKERTOOLBOX]"
    echo "  Installing Docker Toolbox..."
    brew cask install dockertoolbox

    echo ""
    return
}

# [VAGRANT]
# Installing Vagrant
installVagrant ()
{
    echo "[VAGRANT]"
    echo "  Installing Vagrant..."
    brew cask install vagrant

    echo ""

    echo "  Installing Vagrant Manager..."
    brew cask install vagrant-manager

    echo ""
    return
}

# [WEECHAT]
# Installing WeeChat
installWeechat ()
{
    echo "[WEECHAT]"
    echo "  Installing WeeChat..."
    brew install python
    brew install weechat --with-perl --with-python

    echo ""

    echo "  Installing wee-slack plugin..."
    mkdir -p $HOME/.weechat/python/autoload
    wget -q -O $HOME/.weechat/python/autoload/wee_slack.py \
    https://raw.githubusercontent.com/rawdigits/wee-slack/master/wee_slack.py \
        1>&2>/dev/null

    echo ""

    echo "  Linking WeeChat configuration files..."
    makelink "$DOT_PATH/weechat/weechat.conf" "$HOME/.weechat/weechat.conf"

    echo ""
    return
}

# [THEUNARCHIVER]
# Installing The Unarchiver
installTheUnarchiver ()
{
    echo "[THEUNARCHIVER]"
    echo "  Installing The Unarchiver..."
    brew cask install the-unarchiver

    echo ""
    return
}

# [SLACK]
# Installing Slack
installSlack ()
{
    echo "[SLACK]"
    echo "  Installing Slack..."
    brew cask install slack

    echo ""
    return
}

###############################################################################

# Proceed installation
echo "Checking dependencies..."
checkHomebrew
checkGit

echo "Proceed installation..."
[ "$INST_RVM" == "true" ] && installRvm
[ "$INST_NVM" == "true" ] && installNvm
[ "$INST_ITERM" == "true" ] && installiTerm
[ "$INST_POF" == "true" ] && installPowerlineFonts
[ "$INST_SPF13VIM" == "true" ] && installSpf13Vim
[ "$INST_OHMYZSH" == "true" ] && installOhMyZsh
[ "$INST_WEECHAT" == "true" ] && installWeechat

exit 0

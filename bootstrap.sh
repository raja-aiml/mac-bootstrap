#!/usr/bin/env sh

# Script: bootstrap.sh
# Description: Modular Setup and Teardown script for Mac environment
# Author: Raja Soundaramourty
# Version: 2.0
# Usage: ./bootstrap.sh [setup|teardown|test]

set -e  # Exit on error

BACKUP_DIR="$HOME/.backup"
PLUGIN_FOLDER="$HOME/.oh-my-zsh/custom/plugins"
HOMEBREW_PREFIX="/opt/homebrew"
ZSHRC="$HOME/.zshrc"
ZPROFILE="$HOME/.zprofile"
ALIAS_SH="$HOME/.alias.sh"

# Packages to install/uninstall
PACKAGES="zsh zsh-autosuggestions zsh-syntax-highlighting wget gh gum"

# Ensure backup folder exists
function ensure_backup() {
    mkdir -p "$BACKUP_DIR"
}

# Backup existing configurations
function backup_configs() {
    ensure_backup
    echo "Backing up existing configurations..."
    for file in "$ZSHRC" "$ZPROFILE" "$ALIAS_SH"; do
        [ -f "$file" ] && cp -v "$file" "$BACKUP_DIR/$(basename "$file").bak"
    done
}

# Restore configurations from backup
function restore_configs() {
    if [ -d "$BACKUP_DIR" ]; then
        echo "Restoring previous configurations..."
        for file in "$ZSHRC" "$ZPROFILE" "$ALIAS_SH"; do
            [ -f "$BACKUP_DIR/$(basename "$file").bak" ] && cp -v "$BACKUP_DIR/$(basename "$file").bak" "$file"
        done
    else
        echo "No backup found. Skipping restore."
    fi
}

# Install dependencies using Homebrew
function install_packages() {
    echo "Installing dependencies..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
    brew update && brew upgrade
    brew install $PACKAGES || true
    softwareupdate -l
}

# Configure Zsh and plugins
function configure_zsh() {
    echo "Configuring Zsh and plugins..."
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_FOLDER/zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_FOLDER/zsh-autosuggestions"
  
}

# Create .zprofile file
function setup_zprofile() {
    echo "Creating .zprofile..."
    cat << 'EOF' > "$ZPROFILE"
# shell profiling - time
zmodload zsh/zprof

autoload -Uz compinit
if [ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump) ]; then
    compinit
else
    compinit -C
fi

## Your language environment
export LANG=en_US.UTF-8

# Auto Tab Complete
autoload -Uz compinit && compinit

# Path
homebrew_prefix_default=/opt/homebrew
export PATH="$homebrew_prefix_default/bin:$PATH"
EOF
}

# Create .zshrc file
function setup_zshrc() {
    echo "Creating .zshrc..."
    cat << 'EOF' > "$ZSHRC"
###################################################################

## Measure & Improve
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

## Time Plugins
timeplugins() {
  for plugin ($plugins); do
    timer=$(($(gdate +%s%N)/1000000))
    if [ -f $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh ]; then
      source $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh
    elif [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
      source $ZSH/plugins/$plugin/$plugin.plugin.zsh
    fi
    now=$(($(gdate +%s%N)/1000000))
    elapsed=$(($now-$timer))
    echo $elapsed":" $plugin
  done
}

## Check & source file
function source_file(){
  file=$1
  if [ -f "$file" ]; then
      source $file
  else
      echo -e "Error sourcing $file. Check $HOME/.zprofile"
  fi
}

## oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source_file "$HOME/.oh-my-zsh/oh-my-zsh.sh"
if [[ "$(uname -m)" == "arm64" ]]; then
  source_file "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source_file "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
  source_file "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source_file "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

source_file "$HOME/.alias.sh"
EOF
}

# Create .alias.sh file
function setup_aliases() {
    echo "Creating .alias.sh..."
    cat << 'EOF' > "$ALIAS_SH"
#!/usr/bin/env sh

# Edit ohmyzsh
alias ohmyzsh="code ~/.oh-my-zsh"

# Mac Alias
alias clean-mac='find . -name ".DS_Store" -type f -delete'

# zsh config
alias zshconfig='code ~/.zshrc ~/.zprofile ~/.alias.sh'

# Find port
lsof_port() {
    lsof -nP -iTCP -sTCP:LISTEN | grep "$1"
}
EOF
}

# Download Terminal Profile
function download_terminal_profile() {
    echo "Downloading Terminal Profile..."
    mkdir -p "$HOME/workspace/terminal-profiles"
    cd "$HOME/workspace/terminal-profiles"
    wget https://raw.githubusercontent.com/rajasoun/mac-onboard/9e22d9e5f9dbdf002f98fba7777621b5625ac0e4/profiles/SolarizedDark.terminal
}

# Teardown function
function teardown() {
    echo "Starting teardown process..."
    restore_configs
    echo "Removing installed packages..."
     brew uninstall $PACKAGES || true
    rm -rf "$PLUGIN_FOLDER/zsh-syntax-highlighting" "$PLUGIN_FOLDER/zsh-autosuggestions" || true
    rm -rf "$HOME/.oh-my-zsh" "$HOME/workspace/terminal-profiles" || true
    echo "Teardown complete."
}

# Function to test if all required packages are installed
function test_setup() {
    echo "Testing installation..."

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is not installed. Setup failed."
        exit 1
    fi

    # Check if all required packages are installed
    missing_packages=()
    for package in $PACKAGES; do
        # Ignore if package name is zsh-autosuggestions or zsh-syntax-highlighting
        if [ "$package" = "zsh-autosuggestions" ] || [ "$package" = "zsh-syntax-highlighting" ]; then
            continue
        fi
        
        if ! command -v "$package" &> /dev/null; then
            missing_packages+=("$package")
        fi
    done

    # Display result
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo "✅ All packages are installed successfully."
    else
        echo "❌ Missing packages: ${missing_packages[*]}. Please check logs."
        exit 1
    fi
}

# Main function
function main() {
    case "$1" in
        setup)
            backup_configs
            install_packages
            configure_zsh
            setup_zprofile
            setup_zshrc
            setup_aliases
            download_terminal_profile
            echo "Setup completed successfully!"
            ;;
        teardown)
            teardown
            ;;
        test)
            test_setup
            ;;
        *)
            echo "Usage: $0 [setup|teardown|test]"
            exit 1
            ;;
    esac
}

# Execute only if the script is run directly (not sourced)
if [ "$(basename -- "$0")" = "$(basename -- "$BASH_SOURCE")" ]; then
    main "$@"
fi
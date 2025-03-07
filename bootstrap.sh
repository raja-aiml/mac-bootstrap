#!/usr/bin/env sh

# Script: bootstrap.sh
# Description: Modular Setup and Teardown script for Mac environment
# Author: Raja Soundaramourty
# Version: 3.0
# Usage: ./bootstrap.sh [setup|teardown|test]

set -e  # Exit on error

# Constants
BACKUP_DIR="$HOME/.backup"
PLUGIN_FOLDER="$HOME/.oh-my-zsh/custom/plugins"
HOMEBREW_PREFIX="/opt/homebrew"
ZSHRC="$HOME/.zshrc"
ZPROFILE="$HOME/.zprofile"
ALIAS_SH="$HOME/.alias.sh"
PROFILE_PATH="$HOME/workspace/terminal-profiles/SolarizedDark.terminal"

# Packages to install/uninstall
PACKAGES="zsh wget gh gum"
ZSH_PLUGINS=("zsh-autosuggestions" "zsh-syntax-highlighting")

### ----------------- Helper Functions ----------------- ###

# Ensure a directory exists
ensure_dir() {
    [ -d "$1" ] || mkdir -p "$1"
}

# Backup a file if it exists
backup_file() {
    [ -f "$1" ] && cp -v "$1" "$BACKUP_DIR/$(basename "$1").bak"
}

# Restore a file if a backup exists
restore_file() {
    [ -f "$BACKUP_DIR/$(basename "$1").bak" ] && cp -v "$BACKUP_DIR/$(basename "$1").bak" "$1"
}

# Check if a command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Install a Homebrew package if it's not installed
install_package() {
    if ! brew list --formula | grep -q "^$1$"; then
        echo "📥 Installing: $1"
        brew install "$1"
    else
        echo "✅ $1 is already installed."
    fi
}

# Clone a Git repository if the folder doesn't exist
clone_if_missing() {
    local repo_url=$1
    local target_dir=$2

    if [ ! -d "$target_dir" ]; then
        echo "📥 Cloning $(basename "$target_dir")..."
        git clone "$repo_url" "$target_dir"
    else
        echo "✅ $(basename "$target_dir") already exists."
    fi
}

### ----------------- Core Functions ----------------- ###

# Backup existing configurations
backup_configs() {
    ensure_dir "$BACKUP_DIR"
    echo "Backing up existing configurations..."
    for file in "$ZSHRC" "$ZPROFILE" "$ALIAS_SH"; do
        backup_file "$file"
    done
}

# Restore configurations from backup
restore_configs() {
    if [ -d "$BACKUP_DIR" ]; then
        echo "Restoring previous configurations..."
        for file in "$ZSHRC" "$ZPROFILE" "$ALIAS_SH"; do
            restore_file "$file"
        done
    else
        echo "No backup found. Skipping restore."
    fi
}

# Install Homebrew and packages
install_packages() {
    echo "🔹 Checking Homebrew installation..."
    
    if ! command_exists brew; then
        echo "📥 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        export PATH="$HOMEBREW_PREFIX/bin:$PATH"
    else
        echo "✅ Homebrew is already installed."
    fi

    echo "🔄 Updating Homebrew..."
    brew update && brew upgrade

    echo "📦 Installing missing packages..."
    for package in $PACKAGES; do
        install_package "$package"
    done

    echo "🔍 Checking for software updates..."
    softwareupdate -l || echo "No updates available."
}

# Configure Zsh and install plugins if missing
configure_zsh() {
    echo "🔹 Checking Oh My Zsh installation..."

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "📥 Installing Oh My Zsh..."
        curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
    else
        echo "✅ Oh My Zsh is already installed."
    fi

    ensure_dir "$PLUGIN_FOLDER"
    
    echo "🔹 Checking Zsh plugins installation..."
    for plugin in "${ZSH_PLUGINS[@]}"; do
        clone_if_missing "https://github.com/zsh-users/$plugin.git" "$PLUGIN_FOLDER/$plugin"
    done
}

# Create configuration files only if they don't exist
create_file_if_missing() {
    local file_path=$1
    local content=$2

    if [ ! -f "$file_path" ]; then
        echo "📥 Creating $(basename "$file_path")..."
        echo "$content" > "$file_path"
    else
        echo "✅ $(basename "$file_path") already exists. Skipping."
    fi
}

setup_zprofile() {
    create_file_if_missing "$ZPROFILE" '
# Zsh Profile Configuration
zmodload zsh/zprof
autoload -Uz compinit && compinit
export LANG=en_US.UTF-8
export PATH="/opt/homebrew/bin:$PATH"
'
}

setup_zshrc() {
    create_file_if_missing "$ZSHRC" '
# Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
'
}

setup_aliases() {
    create_file_if_missing "$ALIAS_SH" '
# Aliases Configuration
alias ohmyzsh="code ~/.oh-my-zsh"
alias clean-mac="find . -name .DS_Store -type f -delete"
alias zshconfig="code ~/.zshrc ~/.zprofile ~/.alias.sh"
'
}

download_terminal_profile() {
    ensure_dir "$(dirname "$PROFILE_PATH")"
    if [ ! -f "$PROFILE_PATH" ]; then
        echo "📥 Downloading Terminal Profile..."
        wget -q -O "$PROFILE_PATH" https://raw.githubusercontent.com/rajasoun/mac-onboard/9e22d9e5f9dbdf002f98fba7777621b5625ac0e4/profiles/SolarizedDark.terminal
    else
        echo "✅ Terminal Profile already exists. Skipping."
    fi
}

# Teardown function
teardown() {
    echo "Starting teardown process..."
    restore_configs
    echo "Removing installed packages..."
    brew uninstall $PACKAGES || true
    for plugin in "${ZSH_PLUGINS[@]}"; do
        rm -rf "$PLUGIN_FOLDER/$plugin"
    done
    rm -rf "$HOME/.oh-my-zsh" "$HOME/workspace/terminal-profiles" || true
    echo "Teardown complete."
}

# Function to test if all required packages are installed
test_setup() {
    echo "Testing installation..."

    if ! command_exists brew; then
        echo "❌ Homebrew is not installed. Setup failed."
        exit 1
    fi

    missing_packages=()
    for package in $PACKAGES; do
        command_exists "$package" || missing_packages+=("$package")
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo "✅ All packages are installed successfully."
    else
        echo "❌ Missing packages: ${missing_packages[*]}. Please check logs."
        exit 1
    fi
}

main() {
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
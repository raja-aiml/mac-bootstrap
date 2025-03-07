#!/usr/bin/env sh

# Script: bootstrap.sh
# Description: Setup and Teardown script for Mac environment
# Author: Raja Soundaramourty
# Version: 1.0
# Usage: ./bootstrap.sh [setup|teardown|test]

set -e  # Exit on error

BACKUP_DIR="$HOME/.backup"
PLUGIN_FOLDER="$HOME/.oh-my-zsh/custom/plugins"
HOMEBREW_PREFIX="/opt/homebrew"
ZSHRC="$HOME/.zshrc"
ZPROFILE="$HOME/.zprofile"
ALIAS_SH="$HOME/.alias.sh"

# Function to ensure backup folder exists
ensure_backup() {
    mkdir -p "$BACKUP_DIR"
}

# Function to backup existing configurations
backup_configs() {
    ensure_backup
    echo "Backing up existing configurations..."
    cp -v "$ZSHRC" "$BACKUP_DIR/zshrc.bak" || true
    cp -v "$ZPROFILE" "$BACKUP_DIR/zprofile.bak" || true
    cp -v "$ALIAS_SH" "$BACKUP_DIR/alias.sh.bak" || true
}

# Function to restore from backup
restore_configs() {
    if [ -d "$BACKUP_DIR" ]; then
        echo "Restoring previous configurations..."
        cp -v "$BACKUP_DIR/zshrc.bak" "$ZSHRC" || true
        cp -v "$BACKUP_DIR/zprofile.bak" "$ZPROFILE" || true
        cp -v "$BACKUP_DIR/alias.sh.bak" "$ALIAS_SH" || true
    else
        echo "No backup found. Skipping restore."
    fi
}

# Function to install dependencies
install_packages() {
    echo "Installing dependencies..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
    brew update && brew upgrade
    brew install zsh zsh-autosuggestions zsh-syntax-highlighting wget
    softwareupdate -l
}

# Function to configure Zsh and plugins
configure_zsh() {
    echo "Configuring Zsh and plugins..."
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_FOLDER/zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_FOLDER/zsh-autosuggestions"
}

# Function to create profile files
setup_profiles() {
    echo "Creating profile files..."
    cat << 'EOF' > "$ZPROFILE"
export LANG=en_US.UTF-8
export PATH="/opt/homebrew/bin:$PATH"
EOF
    
    cat << 'EOF' > "$ZSHRC"
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
EOF
    
    cat << 'EOF' > "$ALIAS_SH"
#!/usr/bin/env sh
alias ohmyzsh="code ~/.oh-my-zsh"
alias clean-mac='find . -name ".DS_Store" -type f -delete'
alias zshconfig='code ~/.zshrc ~/.zprofile ~/.alias.sh'
EOF
}

# Function to download terminal profile
download_terminal_profile() {
    echo "Downloading Terminal Profile..."
    mkdir -p "$HOME/workspace/terminal-profiles"
    cd "$HOME/workspace/terminal-profiles"
    wget https://raw.githubusercontent.com/rajasoun/mac-onboard/9e22d9e5f9dbdf002f98fba7777621b5625ac0e4/profiles/SolarizedDark.terminal
}

# Teardown function
teardown() {
    echo "Starting teardown process..."
    restore_configs
    echo "Removing installed packages..."
    brew uninstall zsh zsh-autosuggestions zsh-syntax-highlighting wget || true
    rm -rf "$PLUGIN_FOLDER/zsh-syntax-highlighting" "$PLUGIN_FOLDER/zsh-autosuggestions" || true
    rm -rf "$HOME/.oh-my-zsh" "$HOME/workspace/terminal-profiles" || true
    echo "Teardown complete."
}

# Function to test if installation is successful
test_setup() {
    echo "Testing installation..."
    if command -v zsh &> /dev/null && command -v brew &> /dev/null; then
        echo "✅ Setup is successful."
    else
        echo "❌ Setup failed. Please check logs."
    fi
}

# Main script execution
case "$1" in
    setup)
        backup_configs
        install_packages
        configure_zsh
        setup_profiles
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

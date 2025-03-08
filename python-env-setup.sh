#!/usr/bin/env sh

# Script: python_env_setup.sh
# Description: Modular Setup and Teardown script for a Python environment using pyenv, pipx, and Poetry
# Author: Raja Soundaramourty
# Version: 1.1
# Usage: ./python_env_setup.sh [setup|teardown|test]

set -e  # Exit on error

# Constants
PYTHON_VERSIONS="3.12.2 3.13.2"

### ----------------- Helper Functions ----------------- ###

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install pyenv if not already installed
install_pyenv() {
    if command_exists pyenv; then
        echo "✅ pyenv is already installed."
    else
        echo "📥 Installing pyenv..."
        brew install pyenv
        echo "🔧 Configuring pyenv..."
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    fi
}

# Install Python versions using pyenv
install_python_versions() {
    for version in $PYTHON_VERSIONS; do
        if pyenv versions --bare | grep -q "^$version$"; then
            echo "✅ Python $version is already installed."
        else
            echo "📥 Installing Python $version..."
            pyenv install "$version"
        fi
    done
}

# Install pipx using brew if not installed
install_pipx() {
    if command_exists pipx; then
        echo "✅ pipx is already installed."
    else
        echo "📥 Installing pipx using brew..."
        brew install pipx
        pipx ensurepath
    fi
}

# Install Poetry using pipx for each Python version
install_poetry() {
    for version in $PYTHON_VERSIONS; do
        PYTHON_BIN="$(pyenv root)/versions/$version/bin/python"
        if [ -x "$PYTHON_BIN" ]; then
            echo "📥 Installing Poetry using pipx for Python $version..."
            pipx install poetry --python "$PYTHON_BIN"
        else
            echo "❌ Python $version not found, skipping Poetry installation."
        fi
    done
}

### ----------------- Main Functions ----------------- ###

setup() {
    echo "🚀 Starting Python environment setup..."
    install_pyenv
    install_python_versions
    install_pipx
    install_poetry
    echo "🎉 Setup complete! Use 'poetry shell' to enter the environment."
}

teardown() {
    echo "🧹 Starting cleanup process..."
    for version in $PYTHON_VERSIONS; do
        echo "🗑 Removing Poetry for Python $version..."
        pipx uninstall poetry || true
    done
    
    echo "🗑 Removing Python versions..."
    for version in $PYTHON_VERSIONS; do
        pyenv uninstall -f "$version" || true
    done
    
    echo "🗑 Removing pipx..."
    brew uninstall pipx || true
    rm -rf "$HOME/.local/pipx"
    # command removes any lines containing “pipx” from the shell configuration files
    sed -i.bak '/pipx/d' ~/.bashrc ~/.bash_profile ~/.zshrc 2>/dev/null || true

    echo "🗑 Removing pyenv..."
    brew uninstall pyenv || true
    rm -rf "$HOME/.pyenv"
    # command removes any lines containing “pyenv” from the shell configuration files
    sed -i.bak '/pyenv/d' ~/.bashrc ~/.bash_profile ~/.zshrc 2>/dev/null || true
    
    echo "✅ Cleanup complete."
}

test_setup() {
    echo "🔍 Testing setup..."
    missing_tools=""

    for version in $PYTHON_VERSIONS; do
        # set pyenv version
        pyenv global "$version"
        for tool in pyenv pipx poetry; do
            if ! command_exists "$tool"; then
                missing_tools="$missing_tools $tool"
            fi
        done

        if [ -z "$missing_tools" ]; then
            echo "✅ All required tools (pyenv pipx poetry) are installed in Python $version."
        else
            echo "❌ Missing tools:$missing_tools in Python $version. Please check installation."
            exit 1
        fi
    done
    # reset pyenv version
    pyenv global system

}

main() {
    case "$1" in
        setup)
            setup
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

# Execute only if script is run directly
if [ "$(basename -- "$0")" = "$(basename -- "$0")" ]; then
    main "$@"
fi

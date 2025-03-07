
# Mac Setup & Teardown Script

## Overview

This script automates the installation, configuration, and teardown of a Mac development environment using:
* Homebrew (package manager)
* Zsh & Oh My Zsh (shell customization)
* Plugins (syntax highlighting, auto-suggestions)
* Backup & Restore (preserves existing configurations)


## Prerequisites
* macOS
* Internet connection (for downloads)
* Admin permissions (for installations)


## Notes
* The script automatically backs up configurations before making changes.
* The .backup/ folder stores the original settings, allowing a safe restore.
* If you encounter permission issues, run with chmod +x before executing the script.


## Installation & Usage

1. Clone the Repository

```sh
git clone https://github.com/raja-aiml/mac-bootstrap.git
cd mac-bootstrap
```

2. Make the Script Executable

```sh
chmod +x bootstrap.sh
```

3. Run the Script

🔹 Setup the Mac Environment

```sh
./bootstrap.sh setup
```

This will:
* Install Homebrew, Zsh, Oh My Zsh
* Configure Zsh plugins (syntax highlighting, auto-suggestions)
* Backup and create profile files (.zshrc, .zprofile, .alias.sh)
* Download the Solarized Dark Terminal profile~

⸻

🔍 Test the Installation

```sh
./bootstrap.sh test
```

- ✅ Pass – All packages are installed correctly
- ❌ Fail – Displays missing dependencies


🗑️ Teardown & Cleanup

```sh
./bootstrap.sh teardown
```

This will:
* Restore previous configurations
* Uninstall installed packages
* Remove Oh My Zsh, plugins, and terminal profiles

## Features

1. ✅ Setup – Installs Homebrew, Zsh, Oh My Zsh, essential plugins, and terminal profiles
1. ✅ Teardown – Uninstalls components and restores previous configurations1. 
1. ✅ Backup & Restore – Automatically backs up existing settings before modifications
1. ✅ Test – Verifies if all required packages are installed

## License

This script is open-source and free to use. Contributions are welcome!

Author

👨‍💻 Raja Soundaramourty

📬 For feedback, improvements, or bug reports, feel free to open a pull request!


Your README.md looks solid, but I’ve made some refinements for better clarity, consistency, and readability. Here’s the updated README.md:

⸻

Mac Setup & Teardown Script

Overview

This script automates the installation, configuration, and teardown of a Mac development environment using:
	•	Homebrew (package manager)
	•	Zsh & Oh My Zsh (shell customization)
	•	Plugins (syntax highlighting, auto-suggestions)
	•	Backup & Restore (preserves existing configurations)

Features

✅ Setup – Installs Homebrew, Zsh, Oh My Zsh, essential plugins, and terminal profiles
✅ Teardown – Uninstalls components and restores previous configurations
✅ Backup & Restore – Automatically backs up existing settings before modifications
✅ Test – Verifies if all required packages are installed

⸻

Installation & Usage

1. Clone the Repository

git clone https://github.com/raja-aiml/mac-bootstrap.git
cd mac-bootstrap

2. Make the Script Executable

chmod +x bootstrap.sh

3. Run the Script

🔹 Setup the Mac Environment

./bootstrap.sh setup

This will:
	•	Install Homebrew, Zsh, Oh My Zsh
	•	Configure Zsh plugins (syntax highlighting, auto-suggestions)
	•	Backup and create profile files (.zshrc, .zprofile, .alias.sh)
	•	Download the Solarized Dark Terminal profile

⸻

🔍 Test the Installation

./bootstrap.sh test

✅ Pass – All packages are installed correctly
❌ Fail – Displays missing dependencies

⸻

🗑️ Teardown & Cleanup

./bootstrap.sh teardown

This will:
	•	Restore previous configurations
	•	Uninstall installed packages
	•	Remove Oh My Zsh, plugins, and terminal profiles

⸻

File Structure

.
├── bootstrap.sh   # Main script (setup, teardown, test)
├── README.md      # Documentation
└── LICENSE        # Apache License



⸻

Prerequisites
	•	macOS
	•	Internet connection (for downloads)
	•	Admin permissions (for installations)

⸻

Notes
	•	The script automatically backs up configurations before making changes.
	•	The .backup/ folder stores the original settings, allowing a safe restore.
	•	If you encounter permission issues, run with chmod +x before executing the script.

⸻

License

This script is open-source and free to use. Contributions are welcome!

Author

👨‍💻 Raja Soundaramourty

📬 For feedback, improvements, or bug reports, feel free to open a pull request!

⸻

🔗 GitHub Repository

⸻

This update makes the README clearer, more structured, and professional while maintaining simplicity. Let me know if you need further refinements! 🚀
# Mac Setup & Teardown Script

## Overview
This script automates the installation and configuration of a Mac environment using **Homebrew, Zsh, Oh My Zsh, and additional plugins**. It also includes a **teardown** function to clean up and restore previous configurations.

## Features
- **Setup**: Installs Homebrew, Zsh, Oh My Zsh, syntax highlighting, auto-suggestions, and terminal profiles.
- **Teardown**: Removes installed components and restores previous settings.
- **Backup & Restore**: Automatically backs up existing configurations before modifying them.
- **Test**: Checks if the setup was successful.

## Usage

### **1. Clone the Repository**
```bash
git clone <your-repo-url>
cd <your-repo-directory>
```

### **2. Make the Script Executable**
```bash
chmod +x bootstrap.sh
```

### **3. Run the Script**

#### **Setup the Mac Environment**
```bash
./bootstrap.sh setup
```
This will:
- Install dependencies
- Configure Zsh and plugins
- Create profile files
- Download terminal profiles

#### **Test Installation**
```bash
./bootstrap.sh test
```
Checks if Homebrew and Zsh are correctly installed.

#### **Teardown & Cleanup**
```bash
./bootstrap.sh teardown
```
This will:
- Restore previous configurations
- Uninstall installed packages
- Remove plugins and profile files

## File Structure
```
.
├── bootstrap.sh.sh  # Main setup and teardown script
├── README.md        # Documentation file
└── .backup/         # Backup folder for previous configurations
```

## Prerequisites
- macOS
- Internet connection (to download dependencies)

## Notes
- The script automatically handles backups before making changes.
- The `.backup` folder stores original configurations for restoration.
- If you face any issues, ensure you have the correct permissions (`chmod +x` before running).

## License
This script is open-source and free to use. Contributions are welcome!

## Author
**Raja Soundaramourty**

---
For any issues or improvements, feel free to open a pull request or report bugs.


# win-conf

Configuration repository for bootstrapping and customizing a Windows development environment.

## Overview

This repository provides:

- **Automated setup** via PowerShell: installs Chocolatey, gsudo, Git, Nerd Fonts, Oh My Posh, updates Windows Terminal, and provisions WSL with custom shells and tools.
- **Windows Terminal** configuration: custom color schemes, fonts, keybindings, and profiles.
- **PowerShell** profile: initializes Oh My Posh on launch.
- **WSL** setup: shell aliases, functions, and theme configurations for Bash and Zsh.
- **Command scripts**: stubs for future automation.

## Getting Started

1. **Clone the repository**
   ```powershell
   git clone https://github.com/mmcculley/win-conf.git
   cd win-conf
   ```

2. **Run the setup script** (Administrator required)
   ```powershell
   .\setup-WinDevEnv.ps1
   ```
   This script will:
   - Elevate to administrator if needed
   - Set `ExecutionPolicy` to `RemoteSigned`
   - Install Chocolatey, gsudo, and Git
   - Install Hack Nerd Font
   - Install and configure Oh My Posh
   - Update Windows Terminal settings to use the Nerd Font
   - Provision WSL:
     - Installs `zsh`, `wget`, `curl`, `git`
     - Installs Oh My Zsh + Powerlevel10k theme
     - Installs Node.js via `n`

3. **Restart Windows Terminal** to apply all settings.

## Directory Structure

```plaintext
win-conf/
├── cmd/                     # Command-line stubs
│   └── cmd_autorun.cmd      # Placeholder file
├── powershell/              # PowerShell configurations
│   └── Microsoft.PowerShell_profile.ps1  # Init Oh My Posh
├── windows-terminal/        # Windows Terminal settings
│   └── settings.json        # Profiles, themes, keybindings
├── wsl/                     # WSL shell configurations
│   ├── .aliases             # Bash alias definitions
│   ├── .bash_functions      # Custom Bash functions
│   ├── .bashrc              # Bash env setup
│   ├── .p10k.zsh            # Powerlevel10k theme config
│   ├── .profile             # Login-shell profile loader
│   └── .zsh_colors          # Zsh color definitions
├── README.md                # This file
└── setup-WinDevEnv.ps1      # PowerShell bootstrap script
```

## Customization

- **Windows Terminal**: Edit `windows-terminal/settings.json` to tweak profiles, schemes, and actions.
- **PowerShell**: Modify `powershell/Microsoft.PowerShell_profile.ps1`.
- **WSL**: Update files in `wsl/` to adjust aliases, functions, or prompt themes.

## Contributing

Contributions are welcome! Please open issues or submit pull requests to suggest changes or add new configuration snippets.

## License

Specify your preferred license (e.g., MIT) here.


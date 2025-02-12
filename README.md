# Arch Dev Setup Script

This repository contains a setup script to automate the installation and configuration of a development environment on Arch Linux.

## Features
- Installs essential packages like `git`, `zsh`, `neovim`, `docker`, `wezterm`, and more.
- Configures `git` with user details.
- Sets up `Oh My Zsh` with `Powerlevel10k` theme and plugins.
- Clones and applies dotfiles using `stow`.
- Installs JetBrains Mono Nerd Font for WezTerm.
- Enables Docker and adds the user to the Docker group.

## Usage
1. Clone this repository:
   ```sh
   git clone https://github.com/toantht/dev-setup.git
   cd dev-setup
   ```
2. Edit the script to set your Git user details:
   ```sh
   GIT_USER="Your Name"
   GIT_EMAIL="your-email@example.com"
   ```
3. Run the script:
   ```sh
   chmod +x setup.sh
   ./setup.sh
   ```

## Notes
- This script use my [dotfiles](https://github.com/toantht/dotfiles) as well.
- **Oh My Zsh triggers `chsh`**: When `Oh My Zsh` is installed, it changes the default shell to `zsh`. You need to **log in and log out** for the script to continue running properly.

## License
This project is licensed under the MIT License.


#!/bin/bash

set -e # Stop on first error

# --- Helper functions ---
msg_info() { echo -e "\e[34m[INFO]  \e[0m$1"; }
msg_success() { echo -e "\e[32m[SUCCESS] \e[0m$1"; }
msg_warning() { echo -e "\e[33m[WARNING] \e[0m$1"; }
msg_error() { echo -e "\e[31m[ERROR]   \e[0m$1"; exit 1; }

check_command() {
    if ! command -v "$1" &> /dev/null; then
        msg_error "Command '$1' not found. Install it first."
    fi
}

# --- Variables ---
GIT_USER="Your Name" # Change this
GIT_EMAIL="your-email@example.com" # Change this

# --- Keep sudo active ---
sudo -v && while true; do sudo -v; sleep 60; done &

# --- System Update & Package Installation ---
msg_info "Updating system and installing essential packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel wget curl unzip git zsh stow neovim fzf fd bat ripgrep wezterm docker nodejs npm python python-pip
msg_success "System update and package installation complete."

# --- Git Configuration ---
msg_info "Configuring Git..."
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
git config --global core.editor "nvim"
git config --global init.defaultBranch main
msg_success "Git configured."

# --- Enable Docker ---
msg_info "Enabling Docker..."
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
msg_success "Docker enabled. Restart your session for group changes to take effect."

# --- Install Fonts ---
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    msg_info "Installing JetBrains Mono Nerd Font..."
    wget -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip" -O /tmp/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    fc-cache -fv
    msg_success "JetBrains Mono Nerd Font installed."
else
    msg_success "JetBrains Mono Nerd Font already installed."
fi

# --- Install & Configure Zsh ---
check_command zsh
msg_info "Setting up Zsh..."
# chsh -s "$(which zsh)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    msg_info "Installing Oh My Zsh..."
    export KEEP_ZSHRC=yes
    export OHMYZSH_SKIP_ZSHRC=1
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install theme
msg_info "🎨 Installing Powerlevel10k theme for Oh My Zsh..."
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    msg_success "Powerlevel10k installed."
else
    msg_success "Powerlevel10k is already installed."
fi

# Install plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_CUSTOM"

declare -A ZSH_PLUGINS=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
)
for plugin in "${!ZSH_PLUGINS[@]}"; do
    if [ ! -d "$ZSH_CUSTOM/$plugin" ]; then
        git clone "${ZSH_PLUGINS[$plugin]}" "$ZSH_CUSTOM/$plugin"
    fi
done

# Update .zshrc plugins
grep -q 'plugins=(' "$HOME/.zshrc" || echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
msg_success "Zsh configured. Restart your terminal to apply changes."

# --- Clone & Apply Dotfiles ---
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    msg_info "Cloning dotfiles..."
    git clone https://github.com/toantht/dotfiles "$DOTFILES_DIR"
fi
msg_info "Applying dotfiles with Stow..."

# Stow Zsh config safely
if [ -f "$HOME/.zshrc" ]; then
    msg_warning "~/.zshrc exists. Moving it to ~/.zshrc.backup"
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

pushd $DOTFILES_DIR
stow -t "$HOME" zsh
stow -t "$HOME" nvim
stow -t "$HOME" wezterm
popd

msg_success "Dotfiles applied successfully."

# --- SSH Key Setup ---
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    msg_info "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_rsa" -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    msg_success "SSH key generated. Add the public key to GitHub/GitLab."
fi

msg_success "🎉 Setup complete! Restart your terminal for changes to take effect."

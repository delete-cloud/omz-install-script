#!/usr/bin/bash

# Detect Linux distribution
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO=${ID_LIKE:-$ID}
else
  echo "Cannot detect Linux distribution."
  exit 1
fi

# Choose the package manager and install software based on the distribution
case $DISTRO in
  *ubuntu*|*debian*)
    echo "Detected $DISTRO, using apt package manager."
    sudo apt update && sudo apt upgrade -y
    sudo apt install zsh git curl -y
    ;;
  *centos*|*fedora*|*rhel*)
    echo "Detected $DISTRO, using yum/dnf package manager."
    sudo yum update -y || sudo dnf upgrade -y
    sudo yum install zsh git curl -y || sudo dnf install zsh git curl -y
    ;;
  *arch*)
    echo "Detected Arch Linux or derivative, using pacman package manager."
    sudo pacman -Syu --noconfirm
    sudo pacman -S zsh git curl --noconfirm
    ;;
  *opensuse*|*suse*)
    echo "Detected OpenSUSE or SUSE, using zypper package manager."
    sudo zypper refresh
    sudo zypper install -y zsh git curl
    ;;
  *)
    echo "Unsupported Linux distribution: $DISTRO"
    exit 1
    ;;
esac

# Change the default shell to zsh
echo "Changing the default shell to zsh..."
chsh -s $(which zsh)

# Pause to allow user to manually start a zsh session
echo "Please start a zsh session and then press Enter to continue..."
read -p "Press Enter to continue after starting zsh..."

# Check if Oh My Zsh is already installed in the user's home directory
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is already installed in $HOME/.oh-my-zsh. Skipping installation."
else
  echo "Installing Oh My Zsh..."
  export CHSH=no
  OH_MY_ZSH_URL="https://install.ohmyz.sh"
  if curl -s --connect-timeout 5 $OH_MY_ZSH_URL > /dev/null; then
    sh -c "$(curl -fsSL $OH_MY_ZSH_URL)"
  else
    echo "Unable to reach the network, cannot install oh-my-zsh."
    exit 1
  fi
fi

# Install zsh-autosuggestions plugin if not already installed
ZSH_AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
  echo "zsh-autosuggestions plugin is already installed. Skipping."
else
  echo "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

# Install zsh-syntax-highlighting plugin if not already installed
ZSH_SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
  echo "zsh-syntax-highlighting plugin is already installed. Skipping."
else
  echo "Installing zsh-syntax-highlighting plugin..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi

# Modify ~/.zshrc to enable plugins
echo "Enabling plugins in ~/.zshrc..."
sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Pause to allow user to inspect changes or run any additional commands
echo "You may now inspect the changes or run any additional commands."
read -p "Press Enter to apply the changes and finish the installation..."

# Source ~/.zshrc to apply changes
echo "Applying changes by sourcing ~/.zshrc..."
source ~/.zshrc

echo "Installation and configuration complete. Please restart your terminal to start using zsh as the default shell."

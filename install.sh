#!/usr/bin/env bash
set -e

FLAKE_URI="${1:-github:Axenide/Ambxst}"

echo "🚀 Initiating Ambxst installation..."

if [ ! -f /etc/NIXOS ]; then
  if ! command -v ddcutil >/dev/null 2>&1; then
    echo "📦 Installing ddcutil..."
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm ddcutil
    elif command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y ddcutil
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y ddcutil
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper install -y ddcutil
    elif command -v xbps-install >/dev/null 2>&1; then
      sudo xbps-install -y ddcutil
    elif command -v apk >/dev/null 2>&1; then
      sudo apk add ddcutil
    else
      echo "❌ Your package manager is not supported. Please install ddcutil manually."
      exit 1
    fi
    echo "✅ ddcutil installed"
  else
    echo "✅ ddcutil already installed"
  fi

  if ! command -v powerprofilesctl >/dev/null 2>&1; then
    echo "📦 Installing power-profiles-daemon..."
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm power-profiles-daemon
    elif command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y power-profiles-daemon
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y power-profiles-daemon
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper install -y power-profiles-daemon
    elif command -v xbps-install >/dev/null 2>&1; then
      sudo xbps-install -y power-profiles-daemon
    elif command -v apk >/dev/null 2>&1; then
      sudo apk add power-profiles-daemon
      sudo rc-update add power-profiles-daemon default
    else
      echo "❌ Your package manager is not supported. Please install power-profiles-daemon manually."
      exit 1
    fi
    echo "✅ power-profiles-daemon installed"
    
    # Enable and start the daemon based on init system
    if command -v systemctl >/dev/null 2>&1; then
      echo "🔌 Enabling and starting power-profiles-daemon service (systemd)..."
      sudo systemctl enable --now power-profiles-daemon
      echo "✅ power-profiles-daemon service enabled and started"
    elif command -v rc-update >/dev/null 2>&1; then
      echo "🔌 Enabling and starting power-profiles-daemon service (OpenRC)..."
      sudo rc-update add power-profiles-daemon default
      sudo rc-service power-profiles-daemon start
      echo "✅ power-profiles-daemon service enabled and started"
    elif command -v sv >/dev/null 2>&1; then
      echo "🔌 Enabling power-profiles-daemon service (runit)..."
      if [ -d /etc/runit/sv/power-profiles-daemon ]; then
        sudo ln -sf /etc/runit/sv/power-profiles-daemon /var/service/
        echo "✅ power-profiles-daemon service enabled"
      else
        echo "⚠️ runit service directory not found. Please enable manually."
      fi
    elif command -v s6-rc >/dev/null 2>&1; then
      echo "🔌 Enabling power-profiles-daemon service (s6)..."
      if [ -d /etc/s6/sv/power-profiles-daemon ]; then
        sudo s6-rc-bundle-update add default power-profiles-daemon
        sudo s6-svscanctl -an /run/service
        echo "✅ power-profiles-daemon service enabled"
      else
        echo "⚠️ s6 service directory not found. Please enable manually."
      fi
    else
      echo "⚠️ No supported init system detected. Please start power-profiles-daemon manually."
    fi
  else
    echo "✅ power-profiles-daemon already installed"
  fi

  # Check for iwd and disable it if present
  if command -v iwd >/dev/null 2>&1 || command -v iwctl >/dev/null 2>&1; then
    echo "⚠️  iwd detected! Disabling iwd to prevent conflicts with NetworkManager..."
    
    if command -v systemctl >/dev/null 2>&1; then
      if systemctl is-active --quiet iwd 2>/dev/null; then
        sudo systemctl stop iwd
        sudo systemctl disable iwd
        echo "✅ iwd service stopped and disabled (systemd)"
      fi
    elif command -v rc-update >/dev/null 2>&1; then
      if rc-service iwd status >/dev/null 2>&1; then
        sudo rc-service iwd stop
        sudo rc-update del iwd default
        echo "✅ iwd service stopped and disabled (OpenRC)"
      fi
    elif command -v sv >/dev/null 2>&1; then
      if [ -L /var/service/iwd ]; then
        sudo rm /var/service/iwd
        echo "✅ iwd service disabled (runit)"
      fi
    elif command -v s6-rc >/dev/null 2>&1; then
      if s6-rc -a list | grep -q iwd; then
        sudo s6-rc-bundle-update del default iwd
        sudo s6-svscanctl -an /run/service
        echo "✅ iwd service disabled (s6)"
      fi
    fi
  fi

  if ! command -v nmcli >/dev/null 2>&1; then
    echo "📦 Installing NetworkManager..."
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm networkmanager
    elif command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y network-manager
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y NetworkManager
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper install -y NetworkManager
    elif command -v xbps-install >/dev/null 2>&1; then
      sudo xbps-install -y NetworkManager
    elif command -v apk >/dev/null 2>&1; then
      sudo apk add networkmanager
      sudo rc-update add networkmanager default
    else
      echo "❌ Your package manager is not supported. Please install NetworkManager manually."
      exit 1
    fi
    echo "✅ NetworkManager installed"
    
    # Enable and start the daemon based on init system
    if command -v systemctl >/dev/null 2>&1; then
      echo "🔌 Enabling and starting NetworkManager service (systemd)..."
      sudo systemctl enable --now NetworkManager
      echo "✅ NetworkManager service enabled and started"
    elif command -v rc-update >/dev/null 2>&1; then
      echo "🔌 Enabling and starting NetworkManager service (OpenRC)..."
      sudo rc-update add networkmanager default
      sudo rc-service networkmanager start
      echo "✅ NetworkManager service enabled and started"
    elif command -v sv >/dev/null 2>&1; then
      echo "🔌 Enabling NetworkManager service (runit)..."
      if [ -d /etc/runit/sv/NetworkManager ]; then
        sudo ln -sf /etc/runit/sv/NetworkManager /var/service/
        echo "✅ NetworkManager service enabled"
      else
        echo "⚠️ runit service directory not found. Please enable manually."
      fi
    elif command -v s6-rc >/dev/null 2>&1; then
      echo "🔌 Enabling NetworkManager service (s6)..."
      if [ -d /etc/s6/sv/NetworkManager ]; then
        sudo s6-rc-bundle-update add default NetworkManager
        sudo s6-svscanctl -an /run/service
        echo "✅ NetworkManager service enabled"
      else
        echo "⚠️ s6 service directory not found. Please enable manually."
      fi
    else
      echo "⚠️ No supported init system detected. Please start NetworkManager manually."
    fi
  else
    echo "✅ NetworkManager already installed"
  fi
else
  echo "🟦 NixOS detected: Skipping ddcutil, power-profiles-daemon and NetworkManager installation"
fi

# Install Nix
if ! command -v nix >/dev/null 2>&1; then
  echo "📥 Installing Nix..."
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "✅ Nix already installed"
fi

# Config allowUnfree
echo "🔑 Enable unfree packages in Nix..."
mkdir -p ~/.config/nixpkgs

if [ ! -f ~/.config/nixpkgs/config.nix ]; then
  cat >~/.config/nixpkgs/config.nix <<'EOF'
{
  allowUnfree = true;
}
EOF
  echo "✅ ~/.config/nixpkgs/config.nix created with allowUnfree = true"
else
  echo "ℹ️ ~/.config/nixpkgs/config.nix already exists. Please ensure allowUnfree = true is set."
fi

# === Install Ambxst ===
echo "📦 Now... The moment you've been waiting for: Installing Ambxst..."
nix profile add "$FLAKE_URI" --impure

echo "✅ Ambxst installed successfully!"
echo "🎉 You can now run 'ambxst' to begin your experience."

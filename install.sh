#!/usr/bin/env bash
# One-step installer for nvim-lite on Linux (Kali / Debian / Ubuntu, with Arch and Fedora fallbacks).
#   curl -fsSL https://raw.githubusercontent.com/ShreyasDr71/nvim-lite/main/install.sh | bash
set -euo pipefail

REPO="https://github.com/ShreyasDr71/nvim-lite.git"
APPNAME="${NVIM_LITE_APPNAME:-nvim-lite}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$APPNAME"
KALI_KEYRING_URL="https://archive.kali.org/archive-keyring.gpg"
KALI_KEYRING="/usr/share/keyrings/kali-archive-keyring.gpg"
KEY_ERRORS='NO_PUBKEY|EXPKEYSIG|KEYEXPIRED|is not signed|invalid signature|BADSIG'

info() { printf '\033[1;31m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -eq 0 ]; then SUDO=""; else
  command -v sudo >/dev/null || die "sudo is required (or run as root)"
  SUDO="sudo"
fi

fetch() { # fetch URL DEST
  if command -v curl >/dev/null; then curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null; then wget -qO "$2" "$1"
  else die "need curl or wget"; fi
}

# Kali rotates its archive signing key; an outdated kali-archive-keyring makes `apt update` fail with
# NO_PUBKEY / EXPKEYSIG / "not signed". Pull the current keyring straight from archive.kali.org and retry.
fix_kali_keyring() {
  warn "apt signature check failed - refreshing the Kali archive keyring"
  local tmp; tmp="$(mktemp)"
  fetch "$KALI_KEYRING_URL" "$tmp" || die "could not download $KALI_KEYRING_URL"
  $SUDO install -m 0644 "$tmp" "$KALI_KEYRING"
  if [ -d /etc/apt/trusted.gpg.d ]; then
    $SUDO install -m 0644 "$tmp" /etc/apt/trusted.gpg.d/kali-archive-keyring.gpg
  fi
  rm -f "$tmp"
}

apt_update() {
  local log; log="$(mktemp)"
  local ok=0
  $SUDO apt-get update 2>&1 | tee "$log" || ok=1
  if grep -qE "$KEY_ERRORS" "$log"; then ok=2; fi
  rm -f "$log"
  [ "$ok" -eq 0 ] && return 0
  if [ "$ok" -eq 2 ] && grep -qi '^ID=kali' /etc/os-release 2>/dev/null; then
    fix_kali_keyring
    $SUDO apt-get update || die "apt-get update still failing after keyring refresh"
    # Install the packaged keyring too so future key rotations arrive through apt itself.
    $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y kali-archive-keyring || true
    return 0
  fi
  die "apt-get update failed"
}

install_deps() {
  info "Installing git, ripgrep, fd, clipboard tools"
  if command -v apt-get >/dev/null; then
    apt_update
    $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git curl tar unzip ripgrep fd-find xclip wl-clipboard fontconfig
    # Debian ships fd as fdfind
    if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
      $SUDO ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    fi
  elif command -v pacman >/dev/null; then
    $SUDO pacman -Sy --needed --noconfirm git curl tar unzip ripgrep fd xclip wl-clipboard fontconfig
  elif command -v dnf >/dev/null; then
    $SUDO dnf install -y git curl tar unzip ripgrep fd-find xclip wl-clipboard fontconfig
  else
    die "unsupported package manager - install git, ripgrep and fd manually"
  fi
}

nvim_is_recent() { # vim.pack needs Neovim 0.12+
  command -v nvim >/dev/null || return 1
  nvim --headless -c 'lua io.write(vim.fn.has("nvim-0.12"))' -c 'qa!' 2>/dev/null | grep -q 1
}

install_neovim() {
  if nvim_is_recent; then info "Neovim $(nvim --version | head -1 | cut -d' ' -f2) already installed"; return 0; fi
  local arch
  case "$(uname -m)" in
    x86_64|amd64) arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) die "unsupported CPU architecture: $(uname -m)" ;;
  esac
  info "Installing latest stable Neovim ($arch) to /opt/nvim"
  local tmp; tmp="$(mktemp -d)"
  fetch "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" "$tmp/nvim.tar.gz"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  $SUDO rm -rf /opt/nvim
  $SUDO mv "$tmp/nvim-linux-${arch}" /opt/nvim
  $SUDO ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
  hash -r
}

install_font() {
  if fc-list 2>/dev/null | grep -qi 'JetBrainsMono Nerd'; then return 0; fi
  info "Installing JetBrainsMono Nerd Font"
  local dir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
  local tmp; tmp="$(mktemp)"
  mkdir -p "$dir"
  fetch "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$tmp"
  unzip -oq "$tmp" -d "$dir"
  rm -f "$tmp"
  fc-cache -f >/dev/null 2>&1 || true
}

install_config() {
  local ts; ts="$(date +%Y%m%d-%H%M%S)"
  for p in "$CONFIG_DIR" "$HOME/.local/share/$APPNAME" "$HOME/.local/state/$APPNAME" "$HOME/.cache/$APPNAME"; do
    if [ -e "$p" ]; then
      warn "Backing up $p -> $p.bak-$ts"
      mv "$p" "$p.bak-$ts"
    fi
  done
  info "Cloning config into $CONFIG_DIR"
  git clone --depth 1 "$REPO" "$CONFIG_DIR"
}

set_appname() {
  export NVIM_APPNAME="$APPNAME"
  local line="export NVIM_APPNAME=$APPNAME"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    if grep -q '^export NVIM_APPNAME=' "$rc"; then
      sed -i "s|^export NVIM_APPNAME=.*|$line|" "$rc"
    else
      printf '\n%s\n' "$line" >> "$rc"
    fi
  done
}

main() {
  install_deps
  install_neovim
  install_font
  install_config
  set_appname

  info "Installing plugins"
  nvim --headless +qa || warn "plugin install reported errors - just open nvim again"
  info "Fetching Discord presence server"
  nvim --headless -c 'Cord update' -c 'sleep 20' -c 'qa!' >/dev/null 2>&1 || warn "run :Cord update inside nvim"

  info "Done. Set your terminal font to 'JetBrainsMono Nerd Font', open a new shell and run: nvim"
}

main "$@"

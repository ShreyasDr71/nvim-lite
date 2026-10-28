# nvim-lite

A light Neovim config: one `init.lua`, Neovim's built-in plugin manager (`vim.pack`), no lazy.nvim or distro.

- Vermillion-on-black theme with a custom dashboard
- Neo-tree (`<Space>e`), Telescope (`<Space>ff` / `fg` / `fb` / `fr` / `fk`)
- Toggle terminal in the launch folder (`<Space>tt` bottom, `<Space>tv` side)
- which-key popups (`<Space>?` lists everything), lualine status bar
- Discord Rich Presence via cord.nvim

## Install (one step)

Installs Neovim 0.12+, git, ripgrep, fd and JetBrainsMono Nerd Font, backs up any existing `nvim-lite` config, clones this repo, sets `NVIM_APPNAME=nvim-lite` and installs the plugins.

### Linux (Kali / Debian / Ubuntu, Arch, Fedora)

```sh
curl -fsSL https://raw.githubusercontent.com/ShreyasDr71/nvim-lite/main/install.sh | bash
```

On Kali, if `apt update` fails because the archive signing key was rotated (`NO_PUBKEY`, `EXPKEYSIG`, etc.), the script downloads the current keyring from `archive.kali.org` and retries.

### Windows 10/11 (PowerShell)

```powershell
irm https://raw.githubusercontent.com/ShreyasDr71/nvim-lite/main/install.ps1 | iex
```

Requires `winget` (App Installer).

### After installing

Set your terminal font to **JetBrainsMono Nerd Font**, open a new terminal and run `nvim`.

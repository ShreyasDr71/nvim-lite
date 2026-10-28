# One-step installer for nvim-lite on Windows 10/11.
#   irm https://raw.githubusercontent.com/ShreyasDr71/nvim-lite/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$Repo      = 'https://github.com/ShreyasDr71/nvim-lite.git'
$AppName   = if ($env:NVIM_LITE_APPNAME) { $env:NVIM_LITE_APPNAME } else { 'nvim-lite' }
$ConfigDir = Join-Path $env:LOCALAPPDATA $AppName
$DataDir   = Join-Path $env:LOCALAPPDATA "$AppName-data"

function Info($m) { Write-Host "==> $m" -ForegroundColor Red }
function Warn($m) { Write-Host "!!  $m" -ForegroundColor Yellow }

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget not found. Install "App Installer" from the Microsoft Store and re-run.'
}

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Install-Pkg($id, $cmd) {
    if ($cmd -and (Get-Command $cmd -ErrorAction SilentlyContinue)) { Info "$id already present"; return }
    Info "Installing $id"
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) { Warn "winget returned $LASTEXITCODE for $id" }
}

Install-Pkg 'Git.Git'                      'git'
Install-Pkg 'BurntSushi.ripgrep.MSVC'      'rg'
Install-Pkg 'sharkdp.fd'                   'fd'
Install-Pkg 'DEVCOM.JetBrainsMonoNerdFont' $null
Refresh-Path

# vim.pack needs Neovim 0.12+
$hasNvim = $false
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $hasNvim = (nvim --headless -c 'lua io.write(vim.fn.has("nvim-0.12"))' -c 'qa!' 2>$null) -eq '1'
}
if (-not $hasNvim) {
    Info 'Installing latest Neovim'
    winget install --id Neovim.Neovim -e --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        winget upgrade --id Neovim.Neovim -e --silent --accept-package-agreements --accept-source-agreements
    }
    Refresh-Path
}

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
foreach ($p in @($ConfigDir, $DataDir)) {
    if (Test-Path $p) {
        Warn "Backing up $p -> $p.bak-$ts"
        Move-Item $p "$p.bak-$ts"
    }
}

Info "Cloning config into $ConfigDir"
git clone --depth 1 $Repo $ConfigDir
if ($LASTEXITCODE -ne 0) { throw 'git clone failed' }

[Environment]::SetEnvironmentVariable('NVIM_APPNAME', $AppName, 'User')
$env:NVIM_APPNAME = $AppName

Info 'Installing plugins'
nvim --headless +qa
if ($LASTEXITCODE -ne 0) { Warn 'Plugin install reported errors - just open nvim again' }
Info 'Fetching Discord presence server'
nvim --headless -c 'Cord update' -c 'sleep 20' -c 'qa!' *> $null

Info "Done. Set your terminal font to 'JetBrainsMono Nerd Font', open a new terminal, then run: nvim"

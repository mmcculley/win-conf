<#
.SYNOPSIS
  Bootstraps Windows Terminal, PowerShell, CMD & WSL with your preferred tools & themes.
.DESCRIPTION
  Must be run elevated. Installs Chocolatey, gsudo, git, Nerd Font (Hack), oh-my-posh,
  configures your PowerShell profile & Windows Terminal, then sets up ZSH + oh-myzsh +
  Powerlevel10k + N (Node version manager) in WSL.
#>

#––– 1) Relaunch self as admin if needed –––
If (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
  ).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Write-Warning 'Elevating to Administrator…'
  Start-Process -FilePath 'powershell.exe' `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
    -Verb RunAs
  Exit
}

#––– 2) Allow scripts to run –––
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

#––– 3) Install Chocolatey –––
Write-Output '→ Installing Chocolatey…'
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = `
  [Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object Net.WebClient).DownloadString(
  'https://community.chocolatey.org/install.ps1'))

#––– 4) Install gsudo & git –––
choco install gsudo git -y

#––– 5) Install & configure oh-my-posh –––
Write-Output '→ Installing oh-my-posh…'
Install-Module oh-my-posh -Scope CurrentUser -Force

# Ensure your profile exists
if (-not (Test-Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}
$lines = Get-Content $PROFILE
if ($lines -notcontains 'Import-Module oh-my-posh') {
  Add-Content $PROFILE 'Import-Module oh-my-posh'
}
if ($lines -notmatch 'Set-PoshPrompt') {
  Add-Content $PROFILE 'Set-PoshPrompt -Theme Powerlevel10k_rainbow'
}
Write-Output "Updated PowerShell profile at $PROFILE"

#––– 6) Install Hack Nerd Font –––
Write-Output '→ Installing Hack Nerd Font…'
choco install nerdfont-hack -y

#––– 7) Update Windows Terminal to use it –––
$wtSettings = Join-Path $env:LOCALAPPDATA `
  'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
if (Test-Path $wtSettings) {
  Write-Output "→ Configuring Windows Terminal font…"
  $json = Get-Content $wtSettings -Raw | ConvertFrom-Json

  # defaults block
  if (-not $json.profiles.defaults) { $json.profiles.defaults = @{} }
  $json.profiles.defaults.fontFace = 'Hack Nerd Font'

  # apply to every profile
  foreach ($p in $json.profiles.list) {
    $p.fontFace = 'Hack Nerd Font'
  }

  $json | ConvertTo-Json -Depth 10 |
    Set-Content -Path $wtSettings
  Write-Output 'Windows Terminal font set!'
} else {
  Write-Warning "Cannot find Windows Terminal settings at $wtSettings"
}

#––– 8) WSL: ZSH + oh-myzsh + Powerlevel10k + N –––
Write-Output '→ Bootstrapping WSL…'
wsl sudo apt-get update
wsl sudo apt-get install -y zsh wget curl git

# install oh-my-zsh
wsl sh -c 'wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - | sh'

# install Powerlevel10k
wsl sh -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'

# set theme in .zshrc
wsl sh -c 'sed -i "s/^ZSH_THEME=.*$/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" ~/.zshrc'

# install N (node version manager) & latest Node
wsl sh -c 'curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /tmp/n'
wsl sh -c 'sudo bash /tmp/n latest && sudo npm install -g n'

Write-Output '✅  All done! Restart Windows Terminal to see your new prompt & fonts.'

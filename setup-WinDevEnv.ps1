<
# Setup-WinDevEnv.ps1
# ------------------
# Bootstraps and applies your terminal configs, themes & tools.
# Must be run as Administrator.

<##>
<#
.SYNOPSIS
  Applies Windows Terminal, PowerShell, CMD & WSL configurations from your repo
.DESCRIPTION
  - Copies config files from D:\Projects\win-conf into their target locations
  - Installs Chocolatey, gsudo, git, Nerd Font (Hack), oh-my-posh
  - Configures PowerShell profile & Windows Terminal
  - Bootstraps WSL with Zsh, oh-my-zsh, Powerlevel10k & N (node manager)
#>

#––– Relaunch as admin if not already –––
If (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
  ).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Write-Warning 'Elevating to Administrator…'
  Start-Process -FilePath 'powershell.exe' `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
    -Verb RunAs
  Exit
}

#––– Define repo root & helper –––
$repoRoot = 'D:\Projects\win-conf'
Function Copy-Verbose {
  param($src, $dest)
  Write-Output "Copying $src → $dest"
  Copy-Item -Path $src -Destination $dest -Force
}

#––– 1) Copy your repo configs into place –––
Write-Output '→ Applying local config files...'
# Windows Terminal
Copy-Verbose "$repoRoot\\windows-terminal\\settings.json" \
             "$env:LOCALAPPDATA\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState\\settings.json"
# PowerShell profile
if (-not (Test-Path (Split-Path $PROFILE -Parent))) {
  New-Item -ItemType Directory -Path (Split-Path $PROFILE -Parent) -Force
}
Copy-Verbose "$repoRoot\\powershell\\Microsoft.PowerShell_profile.ps1" $PROFILE
# CMD autorun script
$cmdDest = "$env:USERPROFILE\\cmd_autorun.cmd"
Copy-Verbose "$repoRoot\\cmd\\cmd_autorun.cmd" $cmdDest
# enable CMD autorun via registry
reg add 'HKCU\\Software\\Microsoft\\Command Processor' /v AutoRun /t REG_SZ /d "$cmdDest" /f
# WSL dotfiles
$wslFiles = @('.bashrc','.bash_aliases','.profile','.aliases','.zsh_colors','.p10k.zsh')
foreach ($file in $wslFiles) {
  wsl sh -c "cat /mnt/d/Projects/win-conf/wsl/$file > ~/$file"
}
# ensure ~/.local/bin & ~/bin in PATH
wsl sh -c 'grep -qxF "export PATH=~/bin:~/.local/bin:$PATH" ~/.profile || echo "export PATH=~/bin:~/.local/bin:\$PATH" >> ~/.profile'

#––– 2) Allow PowerShell to run scripts –––
Write-Output '→ Setting execution policy...'
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

#––– 3) Install Chocolatey –––
Write-Output '→ Installing Chocolatey…'
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = `
  [Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object Net.WebClient).DownloadString(
  'https://community.chocolatey.org/install.ps1'))

#––– 4) Install gsudo & git –––
Write-Output '→ Installing gsudo & git…'
choco install gsudo git -y

#––– 5) Install + configure oh-my-posh –––
Write-Output '→ Installing oh-my-posh…'
Install-Module oh-my-posh -Scope CurrentUser -Force
# ensure profile entries
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
$profileLines = Get-Content $PROFILE
if ($profileLines -notcontains 'Import-Module oh-my-posh') {
  Add-Content $PROFILE 'Import-Module oh-my-posh'
}
if ($profileLines -notcontains 'Set-PoshPrompt -Theme Powerlevel10k_rainbow') {
  Add-Content $PROFILE 'Set-PoshPrompt -Theme Powerlevel10k_rainbow'
}
Write-Output "PowerShell profile updated: $PROFILE"

#––– 6) Install Hack Nerd Font –––
Write-Output '→ Installing Hack Nerd Font…'
choco install nerdfont-hack -y

#––– 7) Confirm Windows Terminal font via settings.json –––
# (already copied in step 1)

#––– 8) Bootstrap WSL packages & themes –––
Write-Output '→ Bootstrapping WSL (update, zsh, oh-my-zsh, Powerlevel10k, n)…'
wsl sudo apt-get update && wsl sudo apt-get install -y zsh wget curl git
# oh-my-zsh
wsl sh -c 'RUNZSH=no CHSH=no bash -lc "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"'
# powerlevel10k
wsl sh -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'
# set theme
wsl sh -c 'sed -i "s/^ZSH_THEME=.*$/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" ~/.zshrc'
# install n & latest node
wsl sh -c 'curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /tmp/n && sudo bash /tmp/n latest && sudo npm install -g n'

Write-Output '✅ All setup tasks complete! Restart terminals to apply changes.'

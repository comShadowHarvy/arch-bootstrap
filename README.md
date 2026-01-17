# arch-bootstrap

A small bootstrap repository to install common packages and apply simple dotfiles on an existing Arch Linux system.

Quick usage
1. Clone this repo on your Arch machine:
   ```bash
   git clone git@github.com:comShadowHarvy/arch-bootstrap.git ~/arch-bootstrap
   cd ~/arch-bootstrap
   ```
2. Inspect `packages-pacman.txt`, `packages-aur.txt`, `dotfiles/` and `scripts/run-once/`.
3. Make the bootstrap script executable and run it as your normal user:
   ```bash
   chmod +x bootstrap.sh
   ./bootstrap.sh
   ```
   The script uses `sudo` where needed and prompts before destructive actions. Read it before running.

What the bootstrap does
- Installs pacman packages listed in `packages-pacman.txt`.
- Optionally installs an AUR helper (paru) and AUR packages listed in `packages-aur.txt`.
- Applies dotfiles with safe backups (`dotfiles/install-dotfiles.sh`).
- Runs any executable scripts placed in `scripts/run-once/`.
- Provides a dry-run mode and prompts for confirmation.

Customize
- Edit `packages-pacman.txt` and `packages-aur.txt`.
- Add scripts you want run once to `scripts/run-once/`.
- Place your dotfiles under `dotfiles/` (they will be symlinked to `$HOME`).

Security notes
- This repository does not include your private SSH key. You mentioned you have a backup script to restore your SSH key — run that after bootstrap if needed.
- Always review scripts before execution, especially anything that runs as root or modifies files under `$HOME`.  

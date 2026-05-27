# dotfiles

My portable config for WSL and Git Bash.

## Contents

- `bash/` — `.bashrc` (OS-aware, works on WSL and Git Bash)
- `git/` — `.gitconfig` and `.gitignore_global`

## Neovim

Neovim config lives separately at the nvim repo[https://github.com/darthrevan030/nvim]

## Setup on a new machine

\```bash
git clone <https://github.com/darthrevan030/dotfiles.git> ~/.dotfiles
cd ~/.dotfiles
stow bash git

# Neovim

git clone <https://github.com/darthrevan030/nvim.git> ~/.config/nvim
\```

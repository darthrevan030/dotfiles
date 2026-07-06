# ~/.bash_profile
# macOS (and other OSes) launch login shells, which read .bash_profile
# instead of .bashrc. This just chains into the real config.
[ -f ~/.bashrc ] && source ~/.bashrc

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

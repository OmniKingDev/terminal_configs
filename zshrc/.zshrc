# ==============================================================================
# OMARCHY ZSH CONFIGURATION
# ==============================================================================

# Core Configuration Loop: Iterate through each item inside the zshrc directory
for f in ~/.config/zshrc/*; do
    
    # Verify the item is a valid file and not a subfolder
    if [ ! -d $f ]; then
        
        # Define the corresponding path for custom user overrides
        c="${f/.config\/zshrc/.config\/zshrc\/custom}"
        
        # Load the custom override file if it exists; otherwise, load the system file
        [[ -f $c ]] && source $c || source $f
    fi
done

# Individual Customizations: Load standalone overrides from the home directory if present
if [ -f ~/.zshrc_custom ]; then
    source ~/.zshrc_custom
fi

# Prompt Interface: Initialize the Starship cross-shell status line
export STARSHIP_CONFIG="$HOME/.config/starship/omni-os.toml"
eval "$(starship init zsh)"

# Path Manager: Load environment path settings compiled by the envman package manager
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
bindkey -v

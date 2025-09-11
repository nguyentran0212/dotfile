# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh-my-zsh installation path
ZSH=/usr/share/oh-my-zsh/

# Powerlevel10k theme path
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# List of plugins used
plugins=( git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting )
source $ZSH/oh-my-zsh.sh

# Helpful aliases
alias c='clear' # clear terminal
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vim='nvim'
alias devc='devc.sh'

## Alias related to taskwarrior
### Reviewing task list
alias tnw="task pro:Work limit:10 +READY"  # Next 10 work related tasks
alias tns="task pro:Self limit:10 +READY"  # Next 10 for myself
alias tnl="task pro:Self.learn limit:10 +READY"  # Next 10 learning items
alias tnh="task pro:IEM limit:10 +READY"  # Next 10 tasks related to IEM hobby
alias tlr="task +refine list" # List all tasks that need further refinement
alias today="task +TODAY or +OVERDUE" # Task dues today or already overdue
### Creating new tasks
alias taw='task add pro:Work +refine' # Add a task to the work list 
alias tas='task add pro:Self +refine' # Add a task to list of tasks for self
alias tal='task add pro:Self.learn +refine' # Add a task to the list of task for myself
alias tah='task add pro:IEM +refine' # Add a task to the list of task related to IEM hobby
alias tat='task add pro:Self.think +refine' # Add a task to the list of thinking topics

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Display Pokemon
# pokemon-colorscripts --no-title -r 1,3,6

# Initialize NVM (Node Version Manager)
# Check if NVM_DIR is set, otherwise try to find nvm installation
if [[ -z "$NVM_DIR" ]]; then
  if [[ -d "/usr/share/nvm" ]]; then
    export NVM_DIR="/usr/share/nvm"
  elif [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
  fi
fi

# Source nvm.sh if it exists
if [[ -n "$NVM_DIR" ]] && [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
elif [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "NVM not found. Please install NVM."
fi

# Use nvim as manual page reader
export MANPAGER='nvim +Man!'

# Created by `pipx` on 2024-11-29 06:18:39
export PATH="$PATH:$HOME/.local/bin:$HOME/.lmstudio/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

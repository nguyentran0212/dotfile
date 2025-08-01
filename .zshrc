# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
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

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect AUR wrapper
if pacman -Qi yay &>/dev/null; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

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
alias vc='code' # gui code editor

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

## Alias related to timewarrior
alias tplay='task +ACTIVE stop; timew start Playing'
alias tlunch='task +ACTIVE stop; timew start Lunch'
alias tdinner='task +ACTIVE stop; timew start Dinner'
alias tcook='task +ACTIVE stop; timew start Cooking'
alias treflect='task +ACTIVE stop; timew start Reflection'
alias trest='task +ACTIVE stop; timew start Resting'
alias tcommute='task +ACTIVE stop; timew start Commute'
alias tmeeting='task +ACTIVE stop; timew start Meeting'
alias tstop='task +ACTIVE stop; timew stop'

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
source /usr/share/nvm/init-nvm.sh

# Created by `pipx` on 2024-11-29 06:18:39
export PATH="$PATH:$HOME/.local/bin"

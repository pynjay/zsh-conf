autoload -U colors && colors

function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
      echo "git:(%F{#A51C30}$branch%F{#4169E1})"
  fi
}

setopt PROMPT_SUBST
function precmd {
    PS1="%B%F{#FA5F55}kubenode1:%F{#89CFF0}%~%F{#FA5F55}%F{#FA5F55} $(git_branch_name)%{$reset_color%}$%b "
}

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE='~/.cache/zsh/history'
setopt appendhistory

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

addToPathFront() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$1:$PATH
    fi
}

# vi mode
bindkey -v
export KEYTIMEOUT=1

addToPathFront $HOME/.local/bin

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char
bindkey "^R" history-incremental-search-backward
bindkey -s ^f "tmux-sessionizer\n"

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

if [ -z $LD_LIBRARY_PATH ]; then
LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib
else
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/nvidia/hpc_sdk/Linux_x86_64/22.11/cuda/lib64:/opt/nvidia/hpc_sdk/Linux_x86_64/22.11/cuda/lib64/stubs
fi
export LD_LIBRARY_PATH


bindkey -s '^o' 'lfcd\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
export VISUAL=nvim
bindkey '^e' edit-command-line

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin

alias nvim="nvim-nightly"
alias vim="nvim-nightly"
alias v="nvim-nightly"
alias t="tmux"
alias vv="nvim-nightly ."
alias py="/usr/bin/python3.10"

alias xcopy="xclip -selection clipboard"

alias zshsource="source ~/.config/zsh/.zshrc"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended --layout=reverse"
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border --layout=reverse'
fi

# export TERMINAL=alacritty

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh #2>/dev/null

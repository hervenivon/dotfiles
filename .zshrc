# >>> brew init >>>
eval "$(/opt/homebrew/bin/brew shellenv)"
# <<< brew init <<<

# Show OS info when opening a new terminal
neofetch

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# For more details see https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins
plugins=(
  aws
  common-aliases
  code
  copyfile
  copypath
  dash
  docker
  emoji
  encode64
  extract
  gh
  git
  gitfast
  macos
  npm
  nvm
  pip
  python
  xcode
  yarn
  zsh-autosuggestions
)

# Activate zsh-completions
# Can't be activated with plugins=(zsh-completions) becase of issue #603
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# zsh-autosuggestions configuration
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c80,)|cd *|ls *"

source $ZSH/oh-my-zsh.sh

# Setting zsh-completions
autoload -U compinit && compinit

###########################################################
#                POWERLEVEL10K configuration              #
###########################################################

# TO COMPLETE AFTER INSTALLING POWERLEVEL10K AND FOLLOWING THE WIZARD

# You may need to manually set your language environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='nano'
fi

# >>> conda init >>>
if [[ -f "/usr/local/anaconda3/bin" ]]; then
  export PATH="/usr/local/anaconda3/bin:$PATH"
elif [[ -f "/opt/homebrew/anaconda3/bin/activate" ]]; then
  . /opt/homebrew/anaconda3/bin/activate && conda activate /opt/homebrew/anaconda3;
fi
# <<< conda init <<<

# >>> nvm init >>>
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm installed through brew
# <<< nvm init <<<

source ~/.aliases
source ~/.functions

# >>> rvm init >>>
source $HOME/.rvm/scripts/rvm
# <<< nvm init <<<

# Setup zsh-syntax-highlighting last
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

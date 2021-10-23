# Show OS info when opening a new terminal
neofetch

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Font mode for powerlevel9k
POWERLEVEL9K_MODE='nerdfont-complete'

# Set name of the theme to load.
ZSH_THEME="powerlevel9k/powerlevel9k"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
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
# For more details see https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins
plugins=(
  aws
  common-aliases
  copyfile
  docker
  extract
  git
  gitfast
  jira
  npm
  osx
  pip
  python
  zsh-autosuggestions
  zsh-completions
)

source $ZSH/oh-my-zsh.sh

# Setting zsh-completions
autoload -U compinit && compinit

###########################################################
#                 POWERLEVEL9K configuration              #
###########################################################

# https://github.com/bhilburn/powerlevel9k
# https://github.com/bhilburn/powerlevel9k/wiki/Stylizing-Your-Prompt

# Prompt settings
POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
# POWERLEVEL9K_PROMPT_ON_NEWLINE=true
# POWERLEVEL9K_RPROMPT_ON_NEWLINE=true

# Anaconda settings
POWERLEVEL9K_ANACONDA_FOREGROUND='002'
POWERLEVEL9K_ANACONDA_BACKGROUND='023'

# Dir settings
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2

# Battery settings
POWERLEVEL9K_BATTERY_LOW_FOREGROUND='red'
POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND='blue'
POWERLEVEL9K_BATTERY_CHARGED_FOREGROUND='green'
POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND='blue'
POWERLEVEL9K_BATTERY_VERBOSE=true

# Execution time
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2

# History
POWERLEVEL9K_HISTORY_FOREGROUND='236'
POWERLEVEL9K_HISTORY_BACKGROUND='249'

# Prompt elements
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  anaconda
  context
  ssh
  dir
  vcs
  status
  command_execution_time
)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  root_indicator
  background_jobs
  time
  battery
)

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
# <<< nvm init >>>

# # >>> USD.command init
# # https://apple.co/36TN9WJ

# export PATH=$PATH:/Application/usdpython/USD:/Application/usdpython/usdzconvert
# export PYTHONPATH=$PYTHONPATH:/Application/usdpython/USD/lib/python

# # <<< USD.command init

source ~/.aliases
source ~/.functions
source ~/.iterm2_shell_integration.zsh

# Init `rvm`
source $HOME/.rvm/scripts/rvm

#!/usr/bin/env bash

# Strict Mode
set -o nounset

# Print a helpful message if a pipeline exit with non-zero code
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

###############################################################################
# Environment
###############################################################################

# $_ME
#
# Set to the program's basename.
_ME=$(basename "${0}")

###############################################################################
# Debug
###############################################################################

# _debug()
#
# Usage:
#   _debug printf "Debug info. Variable: %s\n" "$0"
#
# A simple function for executing a specified command if the `$_USE_DEBUG`
# variable has been set. The command is expected to print a message and
# should typically be either `echo`, `printf`, or `cat`.
__DEBUG_COUNTER=0
_debug() {
  if [[ "${_USE_DEBUG:-"0"}" -eq 1 ]]
  then
    __DEBUG_COUNTER=$((__DEBUG_COUNTER+1))
    # Prefix debug message with "bug (U+1F41B)"
    printf "🐛  %s " "${__DEBUG_COUNTER}"
    "${@}"
    printf "――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――\\n"
  fi
}
# debug()
#
# Usage:
#   debug "Debug info. Variable: $0"
#
# Print the specified message if the `$_USE_DEBUG` variable has been set.
#
# This is a shortcut for the _debug() function that simply echos the message.
debug() {
  _debug echo "${@}"
}

###############################################################################
# Die
###############################################################################

# _die()
#
# Usage:
#   _die printf "Error message. Variable: %s\n" "$0"
#
# A simple function for exiting with an error after executing the specified
# command. The command is expected to print a message and should typically
# be either `echo`, `printf`, or `cat`.
_die() {
  # Prefix die message with "cross mark (U+274C)", often displayed as a red x.
  printf "❌  "
  "${@}" 1>&2
  exit 1
}
# die()
#
# Usage:
#   die "Error message. Variable: $0"
#
# Exit with an error and print the specified message.
#
# This is a shortcut for the _die() function that simply echos the message.
die() {
  _die echo "${@}"
}

###############################################################################
# Help
###############################################################################

# _print_help()
#
# Usage:
#   _print_help
#
# Print the program help information.
_print_help() {
  cat <<HEREDOC
This script binds the dotfiles in this directory with your \$HOME folder and
can install all necessary tools to setup a brand new environment.

Usage:
  ${_ME} [--options]
  ${_ME} -h | --help

Options:
  -h --help         Display this help information.

  -I, --no-install  Doesn't install necessary tools to setup a new environment
HEREDOC
}

###############################################################################
# Options
#
# NOTE: The `getops` builtin command only parses short options and BSD `getopt`
# does not support long arguments (GNU `getopt` does), so the most portable
# and clear way to parse options is often to just use a `while` loop.
#
###############################################################################

# Parse Options ###############################################################

# Initialize program option variables.
_PRINT_HELP=0
_USE_DEBUG=0

# Initialize additional expected option variables.
_OPTION_INSTALL=0
_OPTION_BACKUP=0
_OPTION_LINK=0

# _require_argument()
#
# Usage:
#   _require_argument <option> <argument>
#
# If <argument> is blank or another option, print an error message and  exit
# with status 1.
_require_argument() {
  # Set local variables from arguments.
  #
  # NOTE: 'local' is a non-POSIX bash feature and keeps the variable local to
  # the block of code, as defined by curly braces. It's easiest to just think
  # of them as local to a function.
  local _option="${1:-}"
  local _argument="${2:-}"

  if [[ -z "${_argument}" ]] || [[ "${_argument}" =~ ^- ]]
  then
    _die printf "Option requires a argument: %s\\n" "${_option}"
  fi
}

while [[ ${#} -gt 0 ]]
do
  __option="${1:-}"
  __maybe_param="${2:-}"
  case "${__option}" in
    -h|--help)
      _PRINT_HELP=1
      ;;
    --debug)
      _USE_DEBUG=1
      ;;
    -a|--all)
      _OPTION_INSTALL=1
      _OPTION_LINK=1
      ;;
    -i|--install)
      _OPTION_INSTALL=1
      ;;
    -l|--link)
      _OPTION_LINK=1
      ;;
    -b|--backup)
      _OPTION_BACKUP=1
      ;;
    --endopts)
      # Terminate option parsing.
      break
      ;;
    -*)
      _die printf "Unexpected option: %s\\n" "${__option}"
      ;;
  esac
  shift
done

###############################################################################
# Program Functions
###############################################################################

backup_file(){
  for f in "$@"
    do
      # Don't follow symlink, preserves attributes, recursively
      if [[ -f "$f" || -d "$f" ]] ; then
        echo "Backuping $f"
        cp -a "$f" "$f".$(date +%Y%m%d%H%M)
      fi
  done
}

# Install homebrew if it is not installed
install_homebrew () {
  which brew 1>&/dev/null
  if [ ! "$?" -eq 0 ] ; then
    echo "Homebrew is not installed. Installation attempt 💪."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile is not necessary because it is handled by .zshrc file
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if [ ! "$?" -eq 0 ] ; then
      die "Something went wrong during Homebrew installation."
    fi
  else
    echo "Homebrew is already installed ✅."
  fi

  echo "Updating Homebrew."
  brew update
}

# Install command line utility for the mac app store
# https://github.com/mas-cli/mas
install_mac_app_store () {
  brew install mas
}

install_xcode () {
  printf  "Installing Xcode 🗜.\n"
  mas install 497799835
  # https://stackoverflow.com/questions/15371925/how-to-check-if-command-line-tools-is-installed

  xcode-select -p 1>/dev/null
  if [ ! "$?" -eq 0 ] ; then
    echo  "Xcode command line tools aren't install. Installation attempt ⚙️."
    xcode-select --install
    if [ ! "$?" -eq 0 ] ; then
      die "Something went wrong during Xcode tools installation."
    fi
  else
    echo  "Xcode command line tools are already installed ✅."
  fi
}

install_mac_app_store_applications () {
  printf "Installing Mac App Store applications 💻.\n"
  while read p; do
    app=$(echo $p | sed -E 's/([0-9a-zA-Z\/]+)( *#.*)/\1/')
    mas install "$app"
  done <mas.txt
}

install_homebrewpackages () {
  printf "Installing homebrew packages from brew.txt\n"
  brew install $( < brew.txt )
}

install_homebrewcask () {
  printf "Installing cask packages from cask.txt\n"
  while read p; do
    app=$(echo $p | sed -E 's/([0-9a-zA-Z\/]+)( *#.*)/\1/')
    brew install --cask "$app"
  done <cask.txt
}

# https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
install_nerd_fonts () {
  brew tap homebrew/cask-fonts
  brew install font-hack-nerd-font
}

brew_cleanup () {
  brew cleanup
}

install_rvm () {
  curl -sSL https://get.rvm.io | bash -s stable --ruby
}

install_iterm2_shell_integration () {
  curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
}

link_zshrc () {
  ln -sf `pwd`/.zshrc $HOME/.zshrc
  ln -sf `pwd`/.p10k.zsh $HOME/.p10k.zsh
  ln -sf `pwd`/.aliases $HOME/.aliases
  ln -sf `pwd`/.functions $HOME/.functions
}

link_jq () {
  ln -sf `pwd`/.jq ~/.jq
}

link_git_config () {
  ln -sf `pwd`/.gitconfig $HOME/.gitconfig
  ln -sf `pwd`/.gitignore_global $HOME/.gitignore_global
}

link_and_setup_nvm () {
  ln -sf `pwd`/.nvmrc $HOME/.nvmrc
  mkdir -p $HOME/.nvm

  echo "With your first session, you must run \`nvm install\`."
}

link_powerlevelink_powerlevel10k () {
  ln -sf `pwd`/vendors/powerlevel10k vendors/oh-my-zsh/custom/themes/powerlevel10k
}

link_zshcompletions () {
  ln -sf `pwd`/vendors/zsh-completions vendors/oh-my-zsh/custom/plugins/zsh-completions
}

link_zshautosuggestions () {
  ln -sf `pwd`/vendors/zsh-autosuggestions vendors/oh-my-zsh/custom/plugins/zsh-autosuggestions
}

link_zsh_syntax_highlighting () {
  ln -sf `pwd`/vendors/zsh-syntax-highlighting vendors/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
}

link_ohmyzsh () {
  ln -sf `pwd`/vendors/oh-my-zsh ~/.oh-my-zsh
}

_execution() {
  _debug printf ">> Performing operation...\\n"

  if ((_OPTION_INSTALL))
  then
    printf "Installing all necessary tools to setup a new environment 🛠\n"
    install_homebrew
    install_mac_app_store
    install_xcode
    install_mac_app_store_applications
    install_homebrewpackages
    install_homebrewcask
    install_nerd_fonts
    brew_cleanup
    install_rvm
    install_iterm2_shell_integration
  fi

  if ((_OPTION_BACKUP))
  then
    printf "Backuping dotfiles\n"
    backup_file $HOME/.zshrc
    backup_file $HOME/.oh-my-zsh
    backup_file $HOME/.jq
    backup_file $HOME/.gitconfig
    backup_file $HOME/.gitignore_global
    backup_file $HOME/.nvmrc
  fi

  if ((_OPTION_LINK))
  then
    printf "Linking theme and plugins for oh-my-zsh\n"
    link_powerlevelink_powerlevel10k
    link_zshcompletions
    link_zshautosuggestions
    link_zsh_syntax_highlighting

    printf "Linking oh-my-zsh\n"
    link_ohmyzsh

    printf "Linking dotfiles\n"
    link_zshrc
    link_jq
    link_git_config
    link_and_setup_nvm
  fi
}

###############################################################################
# Main
###############################################################################

# _main()
#
# Usage:
#   _main [<options>] [<arguments>]
#
# Description:
#   Entry point for the program, handling basic option parsing and dispatching.
_main() {
  if ((_PRINT_HELP))
  then
    _print_help
  else
    _execution "$@"
  fi
}

_main "$@"

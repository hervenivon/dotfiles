#!/usr/bin/env bash

# Strict Mode
set -o nounset

# Exit immediately if a pipeline returns non-zero.
set -o errexit

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
_OPTION_INSTALL=1
_OPTION_BACKUP=0

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
    -I|--no-install)
      _OPTION_INSTALL=0
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
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
    app=$(echo $p | sed -E 's/([0-9]+)( *#.*)/\1/')
    mas install "$app"
  done <mas.txt
}


install_homebrewpackages () {
  printf "Installing homebrew packages from brew.txt\n"
  while read p; do
    brew install "$p"
  done <brew.txt
}

install_homebrewcask () {
  echo "Taping Homebrew cask."
  brew tap caskroom/cask

  printf "Installing cask packages from cask.txt\n"
  while read p; do
    brew cask install "$p"
  done <cask.txt
}

brew_cleanup () {
  brew cleanup
}

install_oh_my_zsh () {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

install_fonts () {
  brew tap caskroom/cask-fonts
  brew cask install font-hack-nerd-font
  brew cask install font-hack-nerd-font-mono
}

set_zsh_as_default () {
  chsh -s $(which zsh)
}

link_powerlevel9k () {
  ln -sf `pwd`/vendors/powerlevel9k vendors/oh-my-zsh/custom/themes/powerlevel9k
}

link_zshcompletions () {
  ln -sf `pwd`/vendors/zsh-completions vendors/oh-my-zsh/custom/plugins/zsh-completions
}

link_ohmyzsh () {
  ln -sf `pwd`/vendors/oh-my-zsh ~/.oh-my-zsh
}

link_zshrc () {
  ln -sf `pwd`/.zshrc $HOME/.zshrc
  ln -sf `pwd`/.aliases $HOME/.aliases
  ln -sf `pwd`/.functions $HOME/.functions
}

link_jq () {
  ln -sf `pwd`/.jq ~/.jq
}

link_iterm2integration () {
  ln -sf `pwd`/.iterm2_shell_integration.zsh ~/.iterm2_shell_integration.zsh
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
    install_fonts
    brew_cleanup

    printf "Making zsh the default shell\n"
    set_zsh_as_default
  fi

  printf "Linking theme and plugins for oh-my-zsh\n"
  link_powerlevel9k
  link_zshcompletions

  if ((_OPTION_BACKUP))
  then
    printf "Backuping dotfiles\n"
    backup_file $HOME/.zshrc
    backup_file $HOME/.oh-my-zsh
    backup_file $HOME/.jq
    backup_file $HOME/.iterm2_shell_integration
  fi

  printf "Linking dotfiles\n"
  link_ohmyzsh
  link_zshrc
  link_jq
  link_iterm2integration
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

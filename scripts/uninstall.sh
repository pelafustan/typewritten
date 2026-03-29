#!/usr/bin/env zsh

# This script is a clone/fork of the spaceship-prompt uninstall script and it was
# changed in order to install the typewritten prompt instead.
#
# Original author: Denys Dovhan, denysdovhan.com
# From: https://github.com/spaceship-prompt/spaceship-prompt

# ------------------------------------------------------------------------------
# Colors
# Set color variables for colorful output
# ------------------------------------------------------------------------------

# If we have tput, let's set colors
if command -v tput >/dev/null 2>&1; then
  reset=$(tput sgr0)
  bold=$(tput bold)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
fi

# ------------------------------------------------------------------------------
# VARIABLES
# Paths to important resources
# ------------------------------------------------------------------------------

ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
USER_SOURCE="${ZDOTDIR:-$HOME}/.typewritten-prompt"

PROMPT_SETUP="prompt_typewritten_setup"
PROMPT_ASYNC="async"

GLOBAL_DEST_SETUP="/usr/local/share/zsh/site-functions/$PROMPT_SETUP"
USER_DEST_SETUP="${ZDOTDIR:-$HOME}/.zfunctions/$PROMPT_SETUP"

GLOBAL_DEST_ASYNC="/usr/local/share/zsh/site-functions/$PROMPT_ASYNC"
USER_DEST_ASYNC="${ZDOTDIR:-$HOME}/.zfunctions/$PROMPT_ASYNC"

TYPEWRITTEN_BLOCK_START="# >>> typewritten prompt >>>"
TYPEWRITTEN_BLOCK_END="# <<< typewritten prompt <<<"
TYPEWRITTEN_FPATH_LINE="fpath=(\$fpath \"${ZDOTDIR:-$HOME}/.zfunctions\")"

# ------------------------------------------------------------------------------
# HELPERS
# Useful functions for common tasks
# ------------------------------------------------------------------------------

# Paint text in specific color with reset
# USAGE:
#   paint <color> [text...]
paint() {
  local color=$1 rest=${@:2}
  echo "$color$rest$reset"
}

# Aliases for common used colors
# Colon at the end is required: https://askubuntu.com/a/521942
# USAGE:
#   info|warn|error|success|code [...text]
info()    { paint "$cyan"   "typewritten: $@" ; }
warn()    { paint "$yellow" "typewritten: $@" ; }
error()   { paint "$red"    "typewritten: $@" ; }
success() { paint "$green"  "typewritten: $@" ; }
code()    { paint "$bold"   "typewritten: $@" ; }

# Check if symlink is exists and remove it
# USAGE:
#   rmln <target>
rmln() {
  local target=$1
  if [[ -L "$target" ]]; then
    info "Removing $target..."
    rm -f "$target"
  fi
}

# ------------------------------------------------------------------------------
# MAIN
# Checkings and uninstalling process
# ------------------------------------------------------------------------------

remove_zshrc_content() {
  info "Removing typewritten from \"${ZDOTDIR:-$HOME}/.zshrc\""
  # Remove enabling statements from .zshrc
  awk -v start="$TYPEWRITTEN_BLOCK_START" -v end="$TYPEWRITTEN_BLOCK_END" '
    $0 == start { in_block = 1; next }
    $0 == end { in_block = 0; next }
    !in_block { print }
  ' "$ZSHRC" > "$ZSHRC.bak"

  grep -Fvx "$TYPEWRITTEN_FPATH_LINE" "$ZSHRC.bak" > "$ZSHRC.tmp" || true
  mv "$ZSHRC.tmp" "$ZSHRC"
  rm -f "$ZSHRC.bak"
}

main() {
  # Remove prompt setup symlink
  if [[ -L "$GLOBAL_DEST_SETUP" || -L "$USER_DEST_SETUP" ]]; then
    rmln "$GLOBAL_DEST_SETUP"
    rmln "$USER_DEST_SETUP"
  else
    warn "Symlinks to typewritten setup are not found."
  fi

  # Remove prompt async symlink
  if [[ -L "$GLOBAL_DEST_ASYNC" || -L "$USER_DEST_ASYNC" ]]; then
    rmln "$GLOBAL_DEST_ASYNC"
    rmln "$USER_DEST_ASYNC"
  else
    warn "Symlinks to typewritten async are not found."
  fi

  # Remove typewritten from .zshrc
  if [[ -f "$ZSHRC" ]] && grep -q "typewritten" "$ZSHRC"; then
    if [[ '-y' == $1 ]]; then
      remove_zshrc_content
    else
      read "answer?Would you like to remove your typewritten ZSH configuration from .zshrc? (y/N)"
      if [[ 'y' == ${answer:l} ]]; then
        read "answer?Are you sure? Any symlinks to your ZSH configuration file might be removed? (y/N)"
        if [[ 'y' == ${answer:l} ]]; then
          remove_zshrc_content
        fi
      fi
    fi
  else
    warn "typewritten configuration not found in \"${ZDOTDIR:-$HOME}/.zshrc\"!"
  fi

  success "Done! typewritten installation has been removed!"
  success "Please, reload your terminal."
}

main "$@"

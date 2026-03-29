#!/usr/bin/env zsh

export TYPEWRITTEN_ROOT=${${(%):-%x}:A:h}
source "$TYPEWRITTEN_ROOT/lib/prompt.zsh"

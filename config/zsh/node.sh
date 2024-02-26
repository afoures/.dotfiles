#!/bin/bash
eval "$(fnm env --use-on-cd --corepack-enabled)"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

#!/usr/bin/env bash

clone_and_update_repository() {
  local repository=$1
  local git_repo="git@github.com:$repository.git"
  local path="$2"
  local update_submodules=$3

  # check if the directory exists
  if [ -d "$path" ]; then
    # check if directory is empty
    if [ "$(ls -A "$path")" ]; then
      echo "repository directory exists but is effectively empty. removing and cloning '$repo_name'..."
      rm -rf "$path"
      git clone "$git_repo" "$path" >/dev/null 2>&1
    elif [ "$(ls -A "$path")" ]; then
      echo "repository '$repository' already exists. pulling latest changes..."
      cd "$path" && git pull
    fi
  else
    echo "cloning repository '$repository'..."
    git clone "$git_repo" "$path" >/dev/null 2>&1
  fi

  if [ ! -d "$path" ]; then
    echo "warning: failed to clone the '$repository' repo. check this manually."
    exit 1
  fi

  if [ "$update_submodules" = "true" ]; then
    if [ -f "$path/.gitmodules" ]; then
      echo "submodules detected. initializing and updating..."
      git -C "$path" submodule update --init --recursive
    else
      echo "warning: submodules were requested, but no '.gitmodules' file found in '$path'."
    fi
  fi
}

clone_and_update_repository afoures/.dotfiles $DOTFILES true

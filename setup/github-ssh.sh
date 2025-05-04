#!/usr/bin/env bash

read -rp "enter your github email: " EMAIL

SSH_KEY="$HOME/.ssh/id_ed25519_github"
SSH_CONFIG="$HOME/.ssh/config"

if [ ! -f "$SSH_KEY" ]; then
    echo "generating a new ssh key..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N ""
    echo "ssh key generated."
else
    echo "ssh key already exists. skipping generation."
fi

eval "$(ssh-agent -s)"
ssh-add -K "$SSH_KEY"

if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    echo "setting up ssh config for GitHub..."
    {
        echo ""
        echo "Host github.com"
        echo "  HostName github.com"
        echo "  User git"
        echo "  IdentityFile $SSH_KEY"
        echo "  AddKeysToAgent yes"
        echo "  UseKeychain yes"
    } >> "$SSH_CONFIG"
    echo "ssh config updated."
else
    echo "ssh config for GitHub already exists. skipping."
fi

echo ""
echo "your public ssh key (already copied to your clipboard):"
cat "${SSH_KEY}.pub"
cat "${SSH_KEY}.pub" | pbcopy

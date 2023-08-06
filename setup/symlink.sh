if [ ! -d $HOME/.config ]; then
  mkdir -p $HOME/.config
fi

for config in $SETUP_FOLDER/config/*; do
  target="$HOME/.config/$(basename "$config")"
  if [ -e "$target" ]; then
    echo "~${target#$HOME} already exists... Skipping."
  else
    echo "Creating symlink for $config"
    ln -s "$config" "$target"
  fi
done

if [ ! -e "$HOME/.zshenv" ]; then
  ln -s ".config/zsh/.zshenv" "$HOME/.zshenv"
fi

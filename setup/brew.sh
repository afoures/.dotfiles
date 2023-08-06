if test ! "$(command -v brew)"; then
  info "Homebrew not installed. Installing."
  # Run as a login shell (non-interactive) so that the script doesn't pause for user input
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
fi

brew bundle

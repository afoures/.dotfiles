# .zprofile is sourced by login shells, after /etc/zprofile.
# /etc/zprofile runs macOS's path_helper, which puts system dirs (/usr/bin, /bin, ...)
# ahead of everything set in .zshenv, so restore our order here.
set_path_order

#!/bin/bash

# Function to prompt the user for continuation
# https://raw.githubusercontent.com/barabasz/lib/main/prompt_continue.sh

prompt_continue() {
  while true; do
      if [ -n "$BASH_VERSION" ]; then
          read -p "Do you want to continue? (Y/N): " yn
      else
          read "yn?Do you want to continue? (Y/N): "
      fi
      case $yn in
          [Yy]* ) echo "You chose to continue."; return 0;;
          [Nn]* ) echo "You chose not to continue."; return 1;;
          * ) echo "Please answer Y/y or N/n.";;
      esac
  done
}

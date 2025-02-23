#!/bin/bash

# Function to prompt the user for continuation
prompt_continue() {
  while true; do
      read "yn?Do you want to continue? (Y/N): "
      case $yn in
          [Yy]* ) echo "You chose to continue."; return 0;;
          [Nn]* ) echo "You chose not to continue."; return 1;;
          * ) echo "Please answer Y/y or N/n.";;
      esac
  done
}

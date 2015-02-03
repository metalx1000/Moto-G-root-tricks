#!/bin/bash

#check if root user
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user"
  echo "Trying to restart script as sudo"
  sudo $0
  exit
fi

echo "Cleaning..."
rm -fr work

echo "Clean complete!"

#!/bin/bash

##
# Author: Alex Kulikov <alex.kulikov@xing.com>
# Rewritten by: Koen Punt <me@koen.pt>
# Version: 0.3
# Description: Installer for TinyPNG.
##

# Check the script is not being run by root
if [ "$(id -u)" == "0" ]; then
  echo "This script should not be run as root"
  exit 1
fi

echo "\
This script will now ask for your sudo password, \
this is needed for some filesystem operations"

# Always ask for password
sudo -k
sudo -v || exit 1

# Determine package manager and if its needed to use sudp
if PKG_MANAGER=$(command -v apt-get) > /dev/null 2>&1; then
  USE_SUDO='sudo '
elif PKG_MANAGER=$(command -v brew) > /dev/null 2>&1; then
  USE_SUDO=''
elif PKG_MANAGER=$(command -v port) > /dev/null 2>&1; then
  USE_SUDO='sudo '
fi

PNGOUT_VERSION='20120530'

function installTinyPng ()
{
  sudo cp tinypng /usr/bin/tinypng
  sudo chmod +x /usr/bin/tinypng
  echo "TinyPNG installed in /usr/bin/tinypng"
}

function installUtils ()
{
  echo "Installing utilities..."
  $USE_SUDO$PKG_MANAGER update 2>&1 > /dev/null
  $USE_SUDO$PKG_MANAGER install pngcrush advancecomp optipng 2>&1 > /dev/null
  echo "Installed pngcrush, advancecomp and optipng"
}

function detectArchitecture ()
{
  if ARCH=`lscpu | grep Architecture | tr -s " " | cut -d " " -f 2`; then
    echo $ARCH
  fi
}

function instDarwin ()
{ 
  if [ ! $PKG_MANAGER ]; then
    echo "\
No package manager found!
You need to install one of the following
  - Homebrew (http://mxcl.github.com/homebrew/)
  - Mac-Ports. (http://www.macports.org)"
    exit 1
  else
    installUtils
    
    echo "Downloading PNGOUT..."
    mkdir -p pngout
    PNGOUT_URL="http://static.jonof.id.au/dl/kenutils/pngout-${PNGOUT_VERSION}-darwin.tar.gz"
    curl -# $PNGOUT_URL | tar -xz --strip 1 --directory pngout 2>&1 > /dev/null
    sudo mv pngout/pngout /usr/bin/pngout
    sudo chmod +x /usr/bin/pngout
    echo "PNGOUT installed in /usr/bin/pngout"
    
    installTinyPng
    cleanup
    
    echo "Done"
  fi
}

function instLinux ()
{
  if [ ! $PKG_MANAGER ]; then
    echo "No package manager found!"
    exit 1
  else
    installUtils
    
    echo "Downloading PNGOUT..."
    mkdir -p pngout
    PNGOUT_URL="http://static.jonof.id.au/dl/kenutils/pngout-${PNGOUT_VERSION}-linux.tar.gz"
    curl -# $PNGOUT_URL | tar -xz --strip 1 --directory pngout 2>&1 > /dev/null
    ARCHS=`find ./pngout -mindepth 1 -type d -exec basename {} \;` 
    
    if ARCH=`detectArchitecture`; then
      # If architecture is detected, check if supported
      if [[ $ARCHS != *"$ARCH"* ]]; then
        echo "Architecture $ARCH not supported, supporter are: $ARCHS"
        exit 1
      fi
    else
      echo "Choose your processor architecture."
      I=1
      for arch in ${ARCHS[@]}; do
        echo " $I) $arch"
        TARGETS[$I]="$arch"
        let I++
      done
      read architecture
      ARCH=${TARGETS[$architecture]}
    fi
    sudo cp pngout/$ARCH/pngout /usr/bin/pngout
    # Make pngout executable
    sudo chmod +x /usr/bin/pngout
    echo "PNGOUT installed in /usr/bin/pngout"

    installTinyPng
    cleanup
    echo "Done."
  fi
}

function abort ()
{
  cleanup
  echo "Exiting.."
  exit 1
}

function cleanup () 
{
  echo "Cleaning.."
  rm -rf pngout
}

function init ()
{
  # Check the OS Type
  OS=`uname`
  if [ $OS = "Darwin" ]; then
    instDarwin
  elif [ $OS = "Linux" ]; then
    instLinux
  else
    echo "Not compatible"
    exit 1
  fi
}

trap abort SIGINT

init
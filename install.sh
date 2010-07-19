#!/bin/bash

##
# Author: Alex Kulikov <alex.kulikov@xing.com>
# Version: 0.2
# Description: Installer for TinyPNG.
##

# Check the script is being run by root
if [ "$(id -u)" != "0" ]; 
  then
  echo "This script must be run as root"
  exit 1
fi

function instDarwin ()
{
  if [ `which port > /dev/null || echo "1"` ]; 
    then
      echo "You need Mac-Ports. (http://www.macports.org)"
    else
      mv README README.bak
      curl http://static.jonof.id.au/dl/kenutils/pngout-20070430-darwin.tar.gz > pngout.tar.gz
      tar -xzvf pngout.tar.gz
      rm README
      rm pngout.tar.gz
      sudo mv pngout-darwin /usr/bin/pngout
      sudo cp tinypng /usr/bin/tinypng
      sudo chmod 755 /usr/bin/tinypng
      sudo port install pngcrush AdvanceCOMP optipng
      mv README.bak README
      echo "done."
  fi
}

function instLinux ()
{
  if [ `which apt-get > /dev/null || echo "1"` ]; 
    then
      echo "apt-get not avaible!"
    else
      mv README README.bak
      curl http://static.jonof.id.au/dl/kenutils/pngout-20070430-linux.tar.gz > pngout.tar.gz
      tar -xzvf pngout.tar.gz
      echo "Choose your processor architecture."
      echo "1) athlon"
      echo "2) i386"
      echo "3) i686"
      echo "4) pentium4"
      read architecture;
      case $architecture in
          1) sudo cp pngout-linux-athlon /usr/bin/pngout;;
          2) sudo cp pngout-linux-i386 /usr/bin/pngout;;
          3) sudo cp pngout-linux-i686 /usr/bin/pngout;;
          4) sudo cp pngout-linux-pentium4 /usr/bin/pngout;;
      esac
      rm README
      rm pngout.tar.gz
      rm pngout-linux-athlon
      rm pngout-linux-i386
      rm pngout-linux-i686
      rm pngout-linux-pentium4
      sudo apt-get install pngcrush AdvanceCOMP optipng
      sudo cp tinypng /usr/bin/tinypng
      mv README.bak README
      echo "done."
  fi
}

# Check the OS Type
OS=`uname`
if [ $OS = "Darwin" ];
  then
    instDarwin
fi
if [ $OS = "Linux" ];
  then
    instLinux
fi
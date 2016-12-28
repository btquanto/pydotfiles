#!/bin/bash
set -e

bin_dir="$(cd "$(dirname "$0")" && pwd)";
home_dir="$(cd && pwd)";

if [ ! -d "dotfiles" ];
then
    mkdir dotfiles;
fi;

cd dotfiles;
git init >/dev/null 2>&1;
git add .;
timestamp=$(date +"%Y-%m-%d_%H-%M-%S");
git commit -am "Version $timestamp" >/dev/null 2>&1 || true; # ignore if command fail
cd "$bin_dir";

# Check if config.json exists
if [ ! -f "config.json" ]
then
   echo "Config file not found. Create your config.json file based on config.json.template";
   exit 0;
else
   echo "Config file found. Proceeding to install the dotfiles";
fi;

# Check if virtualenv exists. If not, install it. Exit if installation failed.
if hash virtualenv 2> /dev/null
then
	echo "Virtualenv is found";
else
	echo "Virtualenv is not found. Proceed with installing virtual environment";
    if [ $(whoami) == "root" ]
    then
        apt-get install python-virtualenv -y;
    else
        if [ "$EUID" -ne 0 ]
        then
            if hash sudo 2> /dev/null
            then
                sudo apt-get install python-virtualenv -y;
            fi;
        fi;
    fi;

	if hash virtualenv 2> /dev/null;
	then
		echo "Virtualenv is installed"
	else
		echo "Virtualenv is not installed. Abort the installation of the dot files";
		exit 0;
	fi;
fi;

# Check if any virtual environment has been initialized
if [ ! -f ".virtual_environment/bin/activate" ];
then
	echo "Virtual environment not installed. Creating a new virtual environment";
	virtualenv .virtual_environment;
fi

echo "Activating virtual environment";
. "$bindir"./.virtual_environment/bin/activate;

echo "Upgrading pip";
pip install -U pip

echo "Installing requirements";
pip install -r requirements.txt

python dotfiles.py "$bin_dir" "$home_dir";

echo "Activate bashrc"
source ~/.bashrc

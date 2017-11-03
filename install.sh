#!/bin/bash
set -e

bin_dir="$(cd "$(dirname "$0")" && pwd)";
home_dir="$(cd && pwd)";

cd $bin_dir;

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
    echo "Config file not found. Creating one...";
    echo
    echo "===== Configuring git ===="
    echo -n 'User: '
    read git_user
    echo -n 'Email: '
    read git_email
    echo "\
{
	\"_gitconfig\" : {
		\"name\" : \"$git_user\",
        \"email\" : \"$git_email\"
	}
}\
" > config.json
    echo "Config file has been generated"
else
    echo "Config file found. Proceeding to install the dotfiles";
fi;

# Check if virtualenv exists. If not, install it. Exit if installation failed.
if hash virtualenv 2> /dev/null
then
	echo "Virtualenv is found";
else
	echo "Virtualenv is not found. Proceed with installing virtual environment";
    if hash apt-get 2> /dev/null;
    then 
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
            echo "Virtualenv is installed";
        else
            echo "Virtualenv is not installed. Abort the installation of the dot files";
            exit 0;
        fi;
    else
        echo "This script currently only support linux distros with apt-get";
        echo "If you wish to continue, please proceed to install virtualenv manually";
        exit 0;
    fi;
fi;

# Check if any virtual environment has been initialized
if [ ! -f ".virtual_environment/bin/activate" ];
then
	echo "Virtual environment not installed. Creating a new virtual environment";
	virtualenv .virtual_environment --python=python2;
fi

echo "Activating virtual environment";
. "$bindir"./.virtual_environment/bin/activate;

echo "Upgrading pip";
pip install -U pip

echo "Installing requirements";
pip install -r requirements.txt

python dotfiles.py "$bin_dir" "$home_dir";

if ! [ -f ~/.bash_extras ]; then
    echo "Generating '~/.bash_extras'"
    touch ~/.bash_extras
fi

echo "Activate bashrc"
source ~/.bashrc


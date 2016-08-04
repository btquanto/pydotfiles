This is intended for my personal use. If you want to use it, follow the following steps:
This works in Ubuntu 16.04. I don't guarantee other operating systems.

1. The templates for the dotfiles are in, well, folder `templates`. Edit as fit.
2. Copy `config.json.template` to `config.json`, then edit as fit.
3. Run install.sh. If you haven't had virtualenv, it may ask you to enter your password to install using apt-get.
4. Do not delete the generated files in build folder.

Copy and paste for the lazy me:

    git clone --recursive https://github.com/btquanto/dotfiles.git
    ./dotfiles/install.sh
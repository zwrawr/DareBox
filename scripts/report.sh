#!/bin/bash


# bashrc normally loads nvm but here we have to do it manually

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1073,SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# load rust
# shellcheck disable=SC1073,SC1091
source "$HOME/.cargo/env"

# FINISHING UP
echo "#====================#"
echo "#    DareBox Info    #"
echo "#====================#"
echo "HOST OS: $HOST_OS"
echo "USER   : $(whoami)"
echo "PWD    : $(pwd)"
echo ""
echo "PHP    : $(php -r 'echo PHP_VERSION;')"
echo "NVM    : $(nvm --version)"
echo "NODE   : $(node -v)"
echo "NPM    : $(npm -v)"
echo "RUST   : $(rustc -V)"
echo "CARGO  : $(cargo -V)"
echo "PYTHON : $(python3 --version)"
echo "PIP    : $(pip --version)"
echo "APACHE : $(apache2 -v | grep -Po "(?<=^Server version: Apache\/)\d\.\d.\d+")"
echo "MySQL  : $(mysql -V)"

touch report.provisioned
ls ~

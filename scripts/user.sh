#!/bin/bash

whoami

echo "Installing Node"
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

# bashrc normally loads nvm but here we have to do it manually
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1073,SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# installs all current lts
nvm install --no-progress 16
nvm install --no-progress 14
nvm install --no-progress 12

nvm use --silent 16

echo "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

touch ~/user.provisioned

#!/bin/bash

# Some Steps taken from
# https://github.com/chef/bento/blob/main/packer_templates/ubuntu/scripts/cleanup.sh
# We don't need to repeat all of them.


# Clear APT cache (make it smaller)

echo "Remove unneeded packages"
apt-get -y -qq autoremove
apt-get -y -qq clean

echo "remove docs packages"
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-doc$' \
    | xargs apt-get -y purge;


echo "remove /usr/share/doc/"
rm -rf /usr/share/doc/*

echo "remove /var/cache"
find /var/cache -type f -exec rm -rf {} \;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "clear the history so our install isn't there"
rm -f /root/.wget-hsts
export HISTSIZE=0

# Delete bash histroy and exit
cat /dev/null > ~/.bash_history && history -c
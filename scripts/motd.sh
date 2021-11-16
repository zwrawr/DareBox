#!/bin/bash


rm /etc/update-motd.d/{10-help-text,99-bento,50-landscape-sysinfo}

touch /etc/update-motd.d/{45-darebox,55-info}

cp /vagrant/scripts/motd/* /etc/update-motd.d/

chmod 755 /etc/update-motd.d/*

touch motd.provisioned
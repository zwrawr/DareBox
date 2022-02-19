#!/bin/bash

vLINUX="5.4"

vUBUNTU="20"

vVBOX="6.1"

vPHP="7.4"

vNODE="16"
vNPM="8"

vPYTHON3="3.8"
vPIP3="3.8"

vRUST="1.5"
vCARGO="1.5"

vGIT="2.25"

vMARIA="10"

vSPHINX="2"

vAPACHE="2.4"

vCONVERT="6.9"
vIDENTIFY="6.9"

vFFMPEG="4.2"

LOG="/vagrant/versions.csv"

command_exists() {
    command -v "$1" &> /dev/null
}

report_error() {
	echo -e "\u001b[41m[ERR!]\u001b[0m \u001b[31m$*\u001b[0m" 1>&2
}

report_success() {
	echo -e "\u001b[42m[OKAY]\u001b[0m \u001b[32m$*\u001b[0m"
}

report_warning() {
	echo -e "\u001b[43m[WARN]\u001b[0m \u001b[33m$*\u001b[0m"
}

report_message() {
	echo "      $*"
}

version() {
	echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}

version_up_to_date() {
	if [[ $(version "$1") -ge $(version "$2") ]]; then
		return 0
	else
		return 1
	fi
}

# args, command, curr version, wanted version
check_command() {

	if ! [[ $# -eq 3 ]] ; then
    	report_error "incorrect args for check command : $*"
    	exit 1
	fi

	if command_exists "$1" ;
	then
		
		ver=$2
		if version_up_to_date "$ver" "$3" ;
		then
			report_message "$1, $ver"
			echo "$1, $3, $ver" >> $LOG
			return 0
		else
			report_error "$1 doesn't meet spec,	$ver	<  $3"
			report_error "$ver"
			return 2
		fi
	else
		report_error "$1 does not exist"
		return 1
	fi
}

load_sources() {
	# shellcheck source=/dev/null
	source ~/.bashrc
	
	export NVM_DIR="$HOME/.nvm"
	# shellcheck disable=SC1073,SC1091
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

	# load rust
	# shellcheck disable=SC1073,SC1091
	source "$HOME/.cargo/env"
}

load_sources

if [ -f $LOG ]; then
	if [ -f "$LOG.old" ]; then
		rm "$LOG.old"
	fi
	mv $LOG "$LOG.old"
fi

echo "tool, wanted, installed" >> $LOG

# Linux
check_command  "uname" "$(uname -r | grep -Po '\d+\.\d+\.\d+')" $vLINUX

# Linux
check_command  "lsb_release" "$(lsb_release -d | grep -Po '\d+\.\d+\.\d+')" $vUBUNTU

# Virtual Box Additions
check_command  "VBoxService" "$(VBoxService --version | grep -Po '\d+\.\d+\.\d+(?=r)')" $vVBOX

# php
check_command "php" "$(php -v | grep -Po '(?<=PHP )\d+\.\d+\.\d+')" $vPHP

# node
check_command "node" "$(node -v | grep -Po '\d+\.\d+\.\d+')" $vNODE
check_command "npm" "$(npm -v)" $vNPM

# python
check_command "python3" "$(python3 --version | grep -Po '\d+\.\d+\.\d+')" $vPYTHON3
check_command "pip3" "$(pip3 --version | grep -Po '\d+\.\d+\.\d+')" $vPIP3

# rust
check_command "rustc" "$(rustc -V | grep -Po '\d+\.\d+\.\d+')" $vRUST
check_command "cargo" "$(cargo -V | grep -Po '\d+\.\d+\.\d+')" $vCARGO

# git
check_command "git" "$(git --version | grep -Po '(?<=git version )\d+\.\d+\.\d+')" $vGIT


# mariadb
check_command "mysql" "$(mysql --version | grep -Po '\d+\.\d+\.\d+(?=\-MariaDB)')" $vMARIA

# spinx
check_command "searchd" "$(searchd | grep -Po '(?<=Sphinx )\d+\.\d+\.\d+')" $vSPHINX

# apache
check_command "apache2" "$(apache2 -v | grep -Po '(?<=Apache\/)\d+\.\d+\.\d+')" $vAPACHE

# imagemagik
check_command "convert" "$(convert -version | grep -Po '(?<=ImageMagick )\d+\.\d+\.\d+')" $vCONVERT
check_command "identify" "$(identify -version | grep -Po '(?<=ImageMagick )\d+\.\d+\.\d+')" $vIDENTIFY

# ffmpeg
check_command "ffmpeg" "$(ffmpeg -version | grep -Po '(?<=ffmpeg version )\d+\.\d+\.\d+')" $vFFMPEG

if [ -f "$LOG.old" ]; then
	if ! diff -rq $LOG "$LOG.old"; then
    report_warning "Some tools have changed version, You should update the package version"
    report_warning "Run the following to see changes"
	report_warning "    git diff --color --word-diff=color /vagrant/versions.csv{,.old}  inside box"
	report_warning "    git diff --color --word-diff=color ./test/versions.csv{,.old}    outside box"
    exit 5
fi
fi

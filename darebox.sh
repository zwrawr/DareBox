#!/bin/bash

TEST_DIR="./test"

BOX="package.box"
BOXDIR="output-darebox"



# Checks to see if packer and vagrant are installed
reqs () {
	if command -v packer &> /dev/null 
	then
		:
	else
		echo "[ERR!] Hashicorp's Packer is not installed!"
		exit 10
	fi

	if command -v vagrant &> /dev/null
	then
		:
	else
		echo "[ERR!] Hashicorp's Vagrant is not installed!"
		exit 11
	fi
}


# Runs packer build
build () {
	if [ "$1" == "upload" ]
	then
		echo "Building Box and Uploading"
		packer build -var-file="vars.pkrvar.hcl" -force darebox.pkr.hcl
	else
		echo "Building Box (No Upload)"
		packer build -var-file="vars.pkrvar.hcl" -except="vagrant-cloud" -force darebox.pkr.hcl
	fi
	echo "Box Built"
}


# Brings an instance of our vagrant box up and runs our test script
test () {

	cd $TEST_DIR || exit 20

	vagrant up
	vagrant ssh -c /vagrant/test.sh

	cd ..
}

test_clean () {
	cd $TEST_DIR || exit 21

	vagrant halt
	vagrant destroy -f
	if vagrant box list | grep -q "../${BOXDIR}/package.box";
	then
		vagrant box remove "../${BOXDIR}/package.box"
	fi

	if [[ -d .vagrant ]]
	then
		rm -r .vagrant/
	fi

	cd ..
}

build_clean () {

	if [[ -d "${BOXDIR}/.vagrant" ]]
	then 
		rm -r "${BOXDIR}/.vagrant/"
	fi

	if  [[ -d "${BOXDIR}/Vagrantfile" ]]
	then
		rm "${BOXDIR}/Vagrantfile"
	fi
	# We don't want to remove the box file
}

clean () {
	test_clean
	build_clean
}

size () {
	if [[  -f "$BOXDIR/$BOX" ]]
	then
		echo "Size: $(du --human-readable --apparent-size --time  $BOXDIR/$BOX)"
	else
		echo "No box found at [$BOXDIR/$BOX]"
	fi
}

usage () {
	printf "\n./darebox.sh <command> <|subcommand>\n\n"
	printf "\t- build: Runs packer build generating a provisioned vagrant box \n"
	printf "\t    - upload: subcommand to automatically upload the built box\n"
	printf "\t- test: Runs our custom shell script to see if everything installed correctly\n"
	printf "\t- all: Runs build then test\n"
	printf "\t    - upload: subcommand to automatically upload the built box\n"
	printf "\t- clean: Removes build and test artifacts after shuting vms down\n"
	printf "\t- size: Reports the size of the packaged Box\n"
	printf "\t- help: Print this info\n"
}

case $1 in

	build)
		reqs
		build "$2"
		size
		;;

	test)
		reqs
		test
		;;

	all)
		reqs
		build "$2"
		test
		clean
		size
		;;

 	clean)
		clean
		;;

 	size)
		size
		;;

	help)
		usage
		reqs
		;;

	*)
    	echo "incorrect args for darebox : $*"
		usage
		exit 1
		;;
esac

exit 0

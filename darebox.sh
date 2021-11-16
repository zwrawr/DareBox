#!/bin/bash

TEST_DIR="./test"

all () {
	build
	test
	clean
}

build () {
	packer build --force darebox.pkr.hcl
}

test () {

	cd $TEST_DIR || exit 

	vagrant up
	vagrant ssh -c /vagrant/test.sh

	cd ..
}

test_clean () {
	cd $TEST_DIR || exit 

	vagrant halt
	vagrant destroy -f
	vagrant box remove ../output-darebox/package.box

	rm -r .vagrant/

	cd ..
}

build_clean () {
	rm -r output-darebox/.vagrant/
	#rm -r output-darebox
}

clean () {
	test_clean
	build_clean
}

usage () {
	printf "\n./darebox.sh <command>\n\n"
	printf "\tbuild - Runs packer build generating a provisioned vagrant box \n"
	printf "\ttest - Runs our custom shell script to see if everything installed correctly\n"
	printf "\tall - Runs build then test\n"
	printf "\tclean - Removes build and test artifacts after shuting vms down\n"
	printf "\thelp - Print this info\n"
}

case $1 in

	build)
		build
		;;

	test)
		test
		;;

	all)
		all
		;;

 	clean)
		clean
		;;

	help)
		usage
		;;

	*)
    	echo "incorrect args for darebox : $*"
		usage
		exit 1
		;;
esac

exit 0

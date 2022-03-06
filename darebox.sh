#!/bin/bash

# Checks to see if vagrant are installed
reqs () {

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

	echo "Vagrant Build"
	echo "Starting VM and Provisioning"
	vagrant up --provision

	echo "Packaging Box"
	vagrant package --output "${BOXDIR}/${VERSION}-${BOXFILE}"

	#link

	echo "Stopping VM"
	vagrant halt

	echo "Box Built"
}

upload () {
	echo "Uploading Box"
	vagrant cloud auth login --token="${KEY}"
	vagrant cloud publish "$BOX" "$VERSION" virtualbox "${BOXDIR}/${VERSION}-${BOXFILE}"
	
}

# Nothing seems to follow these symbolic links correctly so theres no point trying to do this
# link () {
# 	echo "Updating default box"
# 	if [[ -L "${BOXDIR}/${BOXFILE}" ]]
# 	then 
# 		echo "removing old link : ${BOXDIR}/${BOXFILE}"
# 		rm "${BOXDIR}/${BOXFILE}"
# 	fi

# 	echo "adding new link ${BOXDIR}/${VERSION}-${BOXFILE} to ${BOXDIR}/${BOXFILE}"
# 	ln -s "${BOXDIR}/${VERSION}-${BOXFILE}" "${BOXDIR}/${BOXFILE}"
# }

# Brings an instance of our vagrant box up and runs our test script
test () {
	## TODO ::
	# Vagrant doesn't follow smylinks properly so we need to rewrite the Vagrant File.
	echo "testing box"
	cd "$TEST_DIR" || exit 20
	sed -ri "s:(config.vm.box =) (\"../output/([0-9]|[a-b]|.)+):\1 \"../output/${VERSION}-${BOXFILE}\":" Vagrantfile 

	vagrant up
	vagrant ssh -c /vagrant/test.sh

	cd ..
}

test_clean () {
	cd "$TEST_DIR" || exit 21

	vagrant halt
	vagrant destroy -f
	if vagrant box list | grep -q "../${BOXDIR}/${BOXFILE}";
	then
		vagrant box remove "../${BOXDIR}/${BOXFILE}"
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

	vagrant destroy -f
	# We don't want to remove the box file
}

clean () {
	test_clean
	build_clean
}

size () {
	if [[ -f "$BOXDIR/$VERSION-$BOXFILE" ]]
	then
		box="$BOXDIR/$VERSION-$BOXFILE"
		echo "Size: $(du --human-readable --apparent-size --time  "$box")"
	else
		echo "No box found at [$BOXDIR/$VERSION-$BOXFILE]"
	fi
}

load_key () {
	if [[ -f "apikey.conf" ]]
	then
		k=$(grep -Po "(?<=apikey = )[\w|\.]+" apikey.conf | xargs)
		echo "$k"
	else
		echo "Failed to load key"
		exit 12 
	fi
}

load_var () {
	if [[ -f "vars.conf" ]]
	then
		k=$(grep -Po "(?<=$1 = )[\w|\.|\/]+" vars.conf | xargs)
		echo "$k"
	else
		echo "Failed to load $1"
		exit 11 
	fi
}

report_config() {

	echo "TEST_DIR = $TEST_DIR"
	echo "BOX = $BOX"
	echo "BOXFILE = $BOXFILE"
	echo "BOXDIR = $BOXDIR"
	echo "VERSION = $VERSION"

}


# check_version () {
	# TODO: check to see if the version exist online before trying to create a new version
# }

usage () {
	printf "\n./darebox.sh <command>\n\n"
	printf "\t- build: Runs packer build generating a provisioned vagrant box \n"
	printf "\t- test: Runs our custom shell script to see if everything installed correctly\n"
	printf "\t- all: Runs build then test\n"
	printf "\t- clean: Removes build and test artifacts after shuting vms down\n"
	printf "\t- upload: Uploads the box to vagrant\n"
	printf "\t- size: Reports the size of the packaged Box\n"
	printf "\t- config: Reports the current config\n"
	printf "\t- help: Print this info\n"
}

TEST_DIR="$(load_var TEST_DIR)"
BOX=$(load_var BOX)
BOXFILE=$(load_var BOXFILE)
BOXDIR=$(load_var BOXDIR)
VERSION=$(load_var VERSION)

KEY=$(load_key)



case $1 in

	build)
		reqs
		report_config
		clean
		build
		size
		;;

	test)
		reqs
		test
		;;

	upload)
		reqs
		size
		upload
		;;
	
	all)
		reqs
		build
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
	config)
		report_config
		;;


	*)
    	echo "incorrect args for darebox : $*"
		usage
		exit 1
		;;
esac

exit 0

Vagrant.configure(2) do |config|
	
	config.vm.box = "bento/ubuntu-20.04"
	#config.vm.box_version = "0"

	# These ‘provider’ definitions are not present in the original template.
	config.vm.provider "virtualbox" do |v|
	  v.memory = 4096
	  v.cpus = 4
	end
	
	config.vm.provision :shell, path: "scripts/20-root.sh"
	config.vm.provision :shell, privileged: false, path: "scripts/40-user.sh"
	config.vm.provision :shell, path: "scripts/60-motd.sh"
	config.vm.provision :shell, privileged: false, path: "scripts/80-report.sh"
	config.vm.provision :shell, path: "scripts/90-cleanup.sh"
	
	
	config.vm.synced_folder "/mnt/storage/Repos/dareBox", "/vagrant"

  end
  
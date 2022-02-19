Vagrant.configure(2) do |config|
		
	config.vm.define "source", autostart: false do |source|
	  source.vm.box = "{{.SourceBox}}"
	  config.ssh.insert_key = {{.InsertKey}}
	end
  
	config.vm.define "output" do |output|
	  output.vm.box = "{{.BoxName}}"
	  output.vm.box_url = "file://package.box"
	  config.ssh.insert_key = {{.InsertKey}}
	end
  
	# These ‘provider’ definitions are not present in the original template.
	config.vm.provider "virtualbox" do |v|
	  v.memory = 4096
	  v.cpus = 4
	end
	
	
	{{if ne .SyncedFolder "" -}}
	  config.vm.synced_folder "{{.SyncedFolder}}", "/vagrant"
	{{- else -}}
	  config.vm.synced_folder ".", "/vagrant", disabled: false
	{{- end}}

  end
  
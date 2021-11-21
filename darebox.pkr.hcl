variable "version" {
  type    = string
  default = "0.0.1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "vagrant" "darebox" {
  add_force    = true
  communicator = "ssh"
  provider     = "virtualbox"
  source_path  = "bento/ubuntu-20.04"
 
  template = "Vagrantfile"
  synced_folder = "."

}

build {
  sources = ["source.vagrant.darebox"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script = "scripts/root.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -u vagrant -S -E bash '{{.Path}}'"
    script = "scripts/user.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script = "scripts/motd.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -u vagrant -S -E bash '{{.Path}}'"
    script = "scripts/report.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script = "scripts/cleanup.sh"
  }
}

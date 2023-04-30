# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  total_cpus = `nproc`.to_i
  assigned_cpus = (total_cpus * 2 / 3.0).ceil

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 10240
    vb.cpus = assigned_cpus
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
  end

  # config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox", SharedFoldersEnableSymlinksCreate: false

  config.vm.define "Inseption-Of-Things" do |iot|
    iot.vm.hostname = "Inseption-Of-Things"
    iot.vm.network "private_network", ip: "192.168.57.2"
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update -q
    # sudo apt-get upgrade -y -q -o Dpkg::Options::="--force-confold"
    sudo apt-get install -y virtualbox vagrant sshpass -q
  SHELL

end
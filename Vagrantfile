# -*- mode: ruby -*-
# vi: set ft=ruby :

username = `whoami`.strip

Vagrant.configure("2") do |config|
  
  config.vm.box = "angelv/ubuntu_22.04"
  config.vm.box_version = "1.0.0"
  
  config.vm.define "Inseption-Of-Things" do |iot|
    iot.vm.hostname = "Inseption-Of-Things"
  end
  
  total_cpus = `nproc`.to_i
  assigned_cpus = (total_cpus * 2 / 3.0).ceil
  
  config.vm.provider "virtualbox" do |vb|
    
    vb.memory = 10240
    vb.cpus = assigned_cpus
    
    vb.gui = true
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
  end

  config.vm.synced_folder ".", "/home/#{username}/hote", type: "virtualbox", SharedFoldersEnableSymlinksCreate: false

  config.vm.provision "shell", path: "scripts.sh", env: {"USER_NAME" => username}, privileged: true
end

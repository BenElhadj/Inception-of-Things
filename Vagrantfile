# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 10240
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--acpi", "off"] # Désactive ACPI pour empêcher la mise en pause
  end

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.define "Inseption-Of-Things" do |iot|
    iot.vm.hostname = "Inseption-Of-Things"
    iot.vm.network "private_network", type: "dhcp"
  end

  config.vm.provision "shell", inline: <<-SHELL

  SHELL
end



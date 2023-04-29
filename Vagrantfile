Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 10240
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["setproperty", "machinefolder", "/mnt/nfs/homes/bhamdi/sgoinfre/Inception-of-Things/VirtualBoxVMs"]
  end

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.define "Inseption-Of-Things" do |iot|
    iot.vm.hostname = "Inseption-Of-Things"
    iot.vm.network "private_network", ip: "192.168.57.2"
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y virtualbox vagrant sshpass
  SHELL

end
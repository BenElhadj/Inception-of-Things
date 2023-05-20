# -*- mode: ruby -*-
# vi: set ft=ruby :

username = `whoami`.strip

Vagrant.configure("2") do |config|
  
  config.vm.box = "angelv/ubuntu_22.04"
  config.vm.box_version = "1.0.0"
  # Configuration du nom d'hôte
  config.vm.define "Inseption-Of-Things" do |iot|
    iot.vm.hostname = "Inseption-Of-Things"
  end
  
  total_cpus = `nproc`.to_i
  assigned_cpus = (total_cpus * 2 / 3.0).ceil
  
  # Attribution des ressources système à la VM
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 10240
    vb.cpus = assigned_cpus
    
    # Configuration de l'interface graphique et des paramètres de la machine virtuelle
    vb.gui = true
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
  end

  # Configuration du partage de dossier
  config.vm.synced_folder ".", "/hote", 
  type: "virtualbox", 
  SharedFoldersEnableSymlinksCreate: true, 
  mount_options: ["dmode=777","fmode=666"]

  # Configuration du partage de dossier
  config.vm.synced_folder "~/.ssh", "/ssh", 
  type: "virtualbox", 
  SharedFoldersEnableSymlinksCreate: true, 
  mount_options: ["dmode=777","fmode=666"]

  # Script de configuration d'utilisateur
  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "============= Configuration d'utilisateur =============="
    echo "========================================================"      
    username=$1      
    sudo apt-get update -q
    sudo apt-get upgrade -yq
    # Install required packages
    sudo apt-get install -yq virtualbox net-tools sshpass
    wget https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.deb
    sudo dpkg -i vagrant_2.2.10_x86_64.deb
    # Add user
    useradd -m -s /bin/bash $username
    # Set password and give sudo access
    echo "$username:iot42" | sudo chpasswd
    usermod -aG sudo $username
    # Modify sudoers file to give passwordless sudo access
    echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    # Disable password
    passwd -d $username
    # Set lightdm to auto login our user
    echo "[Seat:*]" > /etc/lightdm/lightdm.conf.d/50-autologin.conf
    echo "autologin-user=$username" >> /etc/lightdm/lightdm.conf.d/50-autologin.conf
  SHELL

  # Script d'installation de Google Chrome
  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    echo "========================================================"
    echo "============ Installation de Google Chrome ============="
    echo "========================================================"
    # Ajoutez la clé du dépôt Google à apt
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    # Ajoutez le dépôt Google à la liste des sources de packages
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google.list
    # Mettez à jour la liste des packages et installez Google Chrome
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
  SHELL

  # Script de création de raccourci pour Google Chrome
  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "============== Création du raccourci Chrome ==========="
    echo "========================================================"
    username=$1
    # Créer le répertoire Desktop si il n'existe pas
    mkdir -p /home/$username/Desktop
    # Création du fichier .desktop
    echo "[Desktop Entry]
    Version=1.0
    Name=Google Chrome
    Exec=/usr/bin/google-chrome-stable %U --password-store=basic
    Terminal=false
    Icon=google-chrome
    Type=Application
    Categories=Network;WebBrowser;" > /home/$username/Desktop/chrome.desktop
    # Rendre le raccourci exécutable
    chmod +x /home/$username/Desktop/chrome.desktop
  SHELL

  # Script d'installation de ZSH
  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "================= Installation de ZSH =================="
    echo "========================================================"
    username=$1
    # Installez zsh
    sudo apt-get install -y zsh
    # Téléchargez l'installateur de Oh My Zsh dans le répertoire de l'utilisateur
    sudo -u $username wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O /home/$username/ohmyzsh-install.sh
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Changer le propriétaire du fichier
    sudo chown $username:$username /home/$username/ohmyzsh-install.sh
    # Rendre le script exécutable
    sudo chmod 777 /home/$username/ohmyzsh-install.sh
    # Exécute le script en tant qu'utilisateur non privilégié
    sudo -u $username sh -c "$(cat /home/$username/ohmyzsh-install.sh)" "" --unattended
    # # Définit Zsh comme shell par défaut pour l'utilisateur
    # sudo chsh -s $(which zsh) $username
    # sudo chmod 777 /home/bhamdi/.zshrc
    echo "ZSH_THEME='robbyrussell'" >> /home/$username/.zshrc
  SHELL

  # Script d'installation de Docker
  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    echo "========================================================"
    echo "================ Installation de Docker ================"
    echo "========================================================"
    sudo apt-get update -q
    sudo apt-get upgrade -yq
    sudo apt-get install -yq apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -yq docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    newgrp docker 
  SHELL

  # Script de création du dossier IOT
  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "=============== Création du dossier IOT ================"
    echo "========================================================"
    username=$1
    # Copier les dossiers IOT et .ssh
    rsync -a /ssh/* /home/$username/.ssh/
    rsync -a /hote/p1 /home/$username/Desktop/IOT/
    rsync -a /hote/p2 /home/$username/Desktop/IOT/
    rsync -a /hote/p3 /home/$username/Desktop/IOT/
    rsync -a /hote/bonus /home/$username/Desktop/IOT/
    rsync -a /hote/cmdVagrant /home/$username/Desktop/IOT/
    # Donner tous les droits
    chmod -R 777 /home/$username/Desktop/IOT
    # Assurez-vous que l'utilisateur est le propriétaire du dossier
    chown -R $username:$username /home/$username/Desktop/IOT
  SHELL

  # Script de redémarrage
  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "======================= reboot ========================="
    echo "========================================================"
    sudo reboot
  SHELL

end

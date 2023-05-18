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
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
  end

  config.vm.synced_folder ".", "/home/vagrant/hote", type: "virtualbox", SharedFoldersEnableSymlinksCreate: false

  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "============= Configuration d'utilisateur =============="
    echo "========================================================"      
    username=$1      
    apt-get update -q
    apt-get upgrade -yq
    # Install required packages
    apt-get install -yq sudo virtualbox vagrant net-tools sshpass
    # Add user
    useradd -m -s /bin/bash $username
    # Set password and give sudo access
    echo "$username:iot42" | sudo chpasswd
    usermod -aG sudo $username
    # Disable password
    passwd -d $username
    # Set lightdm to auto login our user
    echo "[Seat:*]" > /etc/lightdm/lightdm.conf.d/50-autologin.conf
    echo "autologin-user=$username" >> /etc/lightdm/lightdm.conf.d/50-autologin.conf
  SHELL

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

  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    echo "========================================================"
    echo "================= Installation de ZSH =================="
    echo "========================================================"
    # Installez zsh
    sudo apt-get install -y zsh
    # Téléchargez l'installateur de Oh My Zsh dans /usr/local
    sudo wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O /ohmyzsh-install.sh
    # Rendre le script exécutable
    sudo chmod a+x /ohmyzsh-install.sh
  SHELL

  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "================= Exécution du script Oh My Zsh ========"
    echo "========================================================"
    username=$1
    # Exécute le script en tant qu'utilisateur non privilégié
    sudo -u $username sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Définit Zsh comme shell par défaut pour l'utilisateur avec sudo
    sudo chsh -s $(which zsh) $username
  SHELL

  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "=============== Création du dossier IOT ================"
    echo "========================================================"
    username=$1
    # Assurez-vous que le dossier de l'hôte est monté
    while [ ! -d /home/vagrant/hote ]; do
      sleep 1
    done
    # Créer le dossier sur le bureau
    mkdir -p /home/$username/Desktop/IOT
    # Copier les fichiers
    rsync -a /home/vagrant/hote/ /home/$username/Desktop/IOT/
    # Donner tous les droits
    chmod -R 777 /home/$username/Desktop/IOT
    # Assurez-vous que l'utilisateur est le propriétaire du dossier
    chown -R $username:$username /home/$username/Desktop/IOT
  SHELL

  config.vm.provision "shell", privileged: true, args: username, inline: <<-SHELL
    echo "========================================================"
    echo "======================= reboot ========================="
    echo "========================================================"
    sudo reboot
  SHELL

end

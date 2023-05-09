# -*- mode: ruby -*-
# vi: set ft=ruby :

# Récupérer le nom d'utilisateur actuel
username = `whoami`.strip

Vagrant.configure("2") do |config|
  
  # Choisir la box et sa version
  config.vm.box = "angelv/ubuntu_22.04"
  config.vm.box_version = "1.0.0"
  
  # Définir le nom d'hôte
  config.vm.define "Inseption-Of-Things" do |iot|
    iot.vm.hostname = "Inseption-Of-Things"
  end
  
  # Calculer le nombre de CPU à assigner
  total_cpus = `nproc`.to_i
  assigned_cpus = (total_cpus * 2 / 3.0).ceil
  
  # Configurer le provider VirtualBox
  config.vm.provider "virtualbox" do |vb|
    
    # Configurer la mémoire et le nombre de CPU
    vb.memory = 10240
    vb.cpus = assigned_cpus
    
    # Activer l'interface graphique et configurer les options d'affichage
    vb.gui = true
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
  end
  
  # Créer et configurer l'utilisateur belha avant la connexion SSH
  config.vm.provision "shell", name: "create_user_belha", privileged: true, inline: <<-SHELL
    # Démarrer l'agent SSH
    eval "$(ssh-agent)"
    
    # Ajouter un nouvel utilisateur avec le nom d'utilisateur récupéré précédemment
    sudo adduser #{username} --gecos "" --disabled-password
    # Changer le mot de passe de l'utilisateur
    echo "#{username}:iot42" | sudo chpasswd
    # Ajouter l'utilisateur au groupe sudo
    sudo adduser #{username} sudo
    # Ajouter l'utilisateur au groupe nopasswdlogin
    sudo addgroup nopasswdlogin
    sudo adduser #{username} nopasswdlogin
    # Autoriser l'utilisateur à exécuter des commandes en tant que root sans mot de passe
    echo "#{username} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/#{username}
    # Modifier les permissions et la propriété du dossier personnel de l'utilisateur
    sudo chown -R #{username}:#{username} /home/#{username}
    sudo chmod 755 /home/#{username}
    
    # Mettre à jour et installer les paquets nécessaires
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y virtualbox vagrant net-tools sshpass x11-xkb-utils

  SHELL

  config.vm.synced_folder ".", "/home/#{username}/Desktop/hote", type: "virtualbox", SharedFoldersEnableSymlinksCreate: false

  # Configurer l'utilisateur et le mot de passe
  config.vm.provision "shell", name: "#{username}", privileged: true, inline: <<-SHELL

    # Créer le dossier .ssh pour l'utilisateur
    sudo mkdir -p /home/#{username}/.ssh
    sudo chown -R #{username}:#{username} /home/#{username}/.ssh
    sudo chmod 700 /home/#{username}/.ssh

    # Copier les clés SSH de l'utilisateur actuel vers le nouvel utilisateur
    sudo rsync -av --no-owner --no-group -e "ssh -o StrictHostKeyChecking=no" "C:/Users/belha/.ssh/" "/home/#{username}/.ssh/"
    sudo chown #{username}:#{username} /home/#{username}/.ssh/authorized_keys
    sudo chmod 600 /home/#{username}/.ssh/authorized_keys

    # Ajouter l'utilisateur au groupe autologin pour la connexion automatique
    sudo addgroup autologin
    sudo adduser #{username} autologin

    # Mettre à jour les paramètres PAM pour permettre aux utilisateurs du groupe nopasswdlogin de se connecter sans mot de passe
    sudo bash -c 'echo "auth sufficient pam_succeed_if.so user ingroup nopasswdlogin" >> /etc/pam.d/common-auth'

    # Désactiver la mise en veille automatique
    sudo su - #{username} -c 'gsettings set org.gnome.desktop.session idle-delay 0'
    sudo su - #{username} -c 'gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"'
    sudo su - #{username} -c 'gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"'
    
    # Ajouter le dépôt Google Chrome
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4EB27DB2A3B88B8B
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

    # Configurer Google Chrome comme navigateur par défaut
    sudo update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
    sudo update-alternatives --set gnome-www-browser /usr/bin/google-chrome-stable
    sudo apt-get install -y git google-chrome-stable zsh

    # Crée un lien symbolique vers Google Chrome et Terminal sur le bureau
    sudo su - #{username} -c 'ln -s /usr/bin/google-chrome-stable "/home/#{username}/Desktop/Google Chrome"'
    sudo su - #{username} -c 'ln -s /usr/bin/gnome-terminal "/home/#{username}/Desktop/Terminal"'

    # Supprimer Firefox
    sudo apt-get remove -y --purge firefox

    # Installer zsh
    sudo apt-get install -y zsh

    # Changer le shell par défaut de l'utilisateur pour zsh
    sudo chsh -s /bin/zsh #{username}
    
    # Installer oh-my-zsh pour le nouvel utilisateur
    sudo su - #{username} -c 'sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"'

    # Configurer l'historique des commandes zsh pour le nouvel utilisateur
    sudo su - #{username} -c 'echo "HISTFILE=$HOME/.zsh_history" >> $HOME/.zshrc'
    sudo su - #{username} -c 'echo "SAVEHIST=1000" >> $HOME/.zshrc'
    sudo su - #{username} -c 'echo "setopt INC_APPEND_HISTORY" >> $HOME/.zshrc'
    sudo su - #{username} -c 'echo "setopt SHARE_HISTORY" >> $HOME/.zshrc'

    # Mettre à jour et installer les paquets supplémentaires
    sudo apt-get update -q
    sudo apt-get upgrade -yq

    # Afficher un message pour indiquer la fin de la configuration
    echo "========================================================"
    echo "=========================reboot========================="
    echo "========================================================"
        
    # Redémarrer la VM
    sudo reboot
  SHELL

end
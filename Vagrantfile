# -*- mode: ruby -*-
# vi: set ft=ruby :

# Récupérer le nom d'utilisateur actuel
username = `whoami`.strip

Vagrant.configure("2") do |config|
  # Choisir la box et sa version
  config.vm.box = "angelv/ubuntu_22.04"
  
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

  # Configurer le dossier partagé
  config.vm.synced_folder ".", "/hote", type: "virtualbox", SharedFoldersEnableSymlinksCreate: false

  # Définir le nom d'hôte
  config.vm.define "Inseption-Of-Things" do |iot|
    iot.vm.hostname = "Inseption-Of-Things"
  end

  # Configurer l'utilisateur et le mot de passe
  config.vm.provision "shell", name: "setup_user", privileged: true, inline: <<-SHELL
    sudo adduser #{username} --gecos "" --disabled-password
    echo "#{username}:iot42" | sudo chpasswd
    sudo adduser #{username} sudo
    sudo chown -R #{username}:#{username} /home/#{username}
    sudo chmod 755 /home/#{username}
    sudo mkdir -p /home/#{username}/.ssh
    sudo chown -R #{username}:#{username} /home/#{username}/.ssh
    sudo chmod 700 /home/#{username}/.ssh

    sudo rsync -av --no-owner --no-group -e "ssh -o StrictHostKeyChecking=no" "C:/Users/belha/.ssh/" "/home/#{username}/.ssh/"
    sudo chown #{username}:#{username} /home/#{username}/.ssh/authorized_keys
    sudo chmod 600 /home/#{username}/.ssh/authorized_keys

    sudo bash -c 'echo "AutomaticLoginEnable=true" >> /etc/gdm3/custom.conf'
    sudo bash -c 'echo "AutomaticLogin=#{username}" >> /etc/gdm3/custom.conf'
    sudo apt-get update -q

    sudo apt-get install -y virtualbox vagrant net-tools sshpass x11-xkb-utils -q
    # sudo usermod --expiredate 1 vagrant
    # sudo passwd -l vagrant
  SHELL

  # Recharger la configuration réseau et les paramètres d'utilisateur sans redémarrer
  # config.vm.provision "shell", name: "reload_network_and_user_settings", privileged: true, inline: <<-SHELL
  #   systemctl daemon-reload
  #   systemctl restart networking
  #   systemctl restart NetworkManager
  #   sudo -u #{username} dconf write /org/gnome/desktop/interface/scaling-factor 'uint32 2'
  # SHELL

  # Configurer les paramètres restants et installer les logiciels
  config.vm.provision "shell", name: "setup_remaining", privileged: true, run: "always", inline: <<-SHELL
    config.ssh.username = "#{username}"
    config.ssh.authorized_keys = "C:/Users/belha/.ssh/id_rsa"

    eval "$(ssh-agent)"

    sudo apt-get update -q
    sudo apt-get upgrade -y
    sudo apt-get install -y virtualbox vagrant net-tools sshpass x11-xkb-utils -q

    echo "#{username}" > /home/#{username}/username
    chmod +x /home/#{username}/username
    sudo bash -c "sed -i 's/^#{username}:[^:]*:/#{username}::/' /etc/shadow"
    sudo -u #{username} dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface scaling-factor 2
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

    sudo apt-get update -q
    sudo apt-get install -y git google-chrome-stable zsh
    sudo apt-get remove -y --purge firefox
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

    echo "HISTFILE=$HOME/.zsh_history" >> $HOME/.zshrc
    echo "SAVEHIST=1000" >> $HOME/.zshrc
    echo "setopt INC_APPEND_HISTORY" >> $HOME/.zshrc
    echo "setopt SHARE_HISTORY" >> $HOME/.zshrc

    favorites=$(sudo -u #{username} dconf read /org/gnome/shell/favorite-apps)
    favorites=$(echo $favorites | sed "s/]/, 'google-chrome.desktop']/")
    favorites=$(echo $favorites | sed "s/]/, 'org.gnome.Terminal.desktop']/")
    sudo -u #{username} dconf write /org/gnome/shell/favorite-apps "$favorites"
    sudo update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
    sudo update-alternatives --set gnome-www-browser /usr/bin/google-chrome-stable
    ln -s /hote $HOME/hote
    sudo chsh -s /bin/zsh #{username}
    echo "========================================================"
    echo "==========================fini=========================="
    echo "========================================================"
  SHELL
end

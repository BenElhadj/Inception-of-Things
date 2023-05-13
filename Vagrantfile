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
  
  config.vm.provision "shell", name: "create_user_belha", privileged: true, inline: <<-SHELL
    eval "$(ssh-agent)"
    
    sudo adduser #{username} --gecos "" --disabled-password
    echo "#{username}:iot42" | sudo chpasswd
    sudo adduser #{username} sudo
    sudo addgroup nopasswdlogin
    sudo adduser #{username} nopasswdlogin
    echo "#{username} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/#{username}
    echo "#{username} ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /root/.bashrc
    echo "sudo su -" | sudo tee -a /home/#{username}/.bashrc

    sudo chown -R #{username}:#{username} /home/#{username}
    sudo chmod -R 755 /home/#{username}
    
    sudo apt-get remove -yq gnome-keyring
    
    sudo apt-get update -q
    sudo apt-get upgrade -yq
    sudo apt-get install -yq net-tools vagrant sshpass x11-xkb-utils virtualbox
    
  SHELL

  config.vm.synced_folder ".", "/home/#{username}/hote", type: "virtualbox", SharedFoldersEnableSymlinksCreate: false

  config.vm.provision "shell", name: "#{username}", privileged: true, inline: <<-SHELL
    
    sudo chmod -R 755 /home/#{username}/hote

    mkdir -p /home/#{username}/Desktop/IOT
    cp -R /home/#{username}/hote/p1 /home/#{username}/Desktop/IOT
    cp -R /home/#{username}/hote/p2/* /home/#{username}/Desktop/IOT
    cp -R /home/#{username}/hote/p3/* /home/#{username}/Desktop/IOT
    cp -R /home/#{username}/hote/bonus/* /home/#{username}/Desktop/IOT
    cp -R /home/#{username}/hote/cmdVagrant /home/#{username}/Desktop/IOT
    sudo chmod -R 777 /home/#{username}/Desktop/IOT

    sudo mkdir -p /home/#{username}/.ssh
    sudo chown -R \#{username}:#{username} /home/#{username}/.ssh

    sudo rsync -av --no-owner --no-group -e "ssh -o StrictHostKeyChecking=no" "C:/Users/belha/.ssh/" "/home/#{username}/.ssh/"
    sudo chown \#{username}:#{username} /home/#{username}/.ssh/authorized_keys
    sudo chmod -R 755 /home/#{username}/.ssh

    sudo addgroup autologin
    sudo adduser #{username} autologin

    sudo bash -c 'echo "auth sufficient pam_succeed_if.so user ingroup nopasswdlogin" >> /etc/pam.d/common-auth'

    sudo su - #{username} -c 'gsettings set org.gnome.desktop.session idle-delay 0'
    sudo su - #{username} -c 'gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"'
    sudo su - #{username} -c 'gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"'

    url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    file=$(basename "$url")
    echo "Downloading $file..."
    wget -q "$url"
    if [ $? -eq 0 ]; then
        echo "$file downloaded successfully."
    else
        echo "Failed to download $file."
    fi
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt-get install -fyq
    
    sudo mkdir -p /etc/opt/chrome/policies/managed/
    
    echo "[Desktop Entry]
    Version=1.0
    Name=Google Chrome
    GenericName=Web Browser
    Exec=/usr/bin/google-chrome-stable --no-sandbox %U
    Terminal=false
    Icon=google-chrome
    Type=Application
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;" > "/home/#{username}/Desktop/GoogleChrome.desktop"
    
    sudo chmod +x "/home/#{username}/Desktop/GoogleChrome.desktop"

    sudo apt-get remove -yq --purge firefox
    
    sudo apt-get install -yq zsh
    
    sudo chsh -s /bin/zsh #{username}

    sudo apt-get install -yq zsh dconf-cli
    
    sudo su - #{username} -c 'sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"'
    
    sudo su - #{username} -c 'sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"'
    
    sudo su - #{username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color \\\"'rgb(0,0,0)'\\\""
    sudo su - #{username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/foreground-color \\\"'rgb(128,128,128)'\\\""
    sudo su - #{username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/bold-color \\\"'rgb(128,128,128)'\\\""
    sudo su - #{username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/underline-color \\\"'rgb(128,128,128)'\\\""    
    
    sudo su - #{username} -c 'echo "HISTFILE=$HOME/.zsh_history" >> $HOME/.zshrc'
    sudo su - #{username} -c 'echo "SAVEHIST=1000" >> $HOME/.zshrc'
    sudo su - #{username} -c 'echo "setopt INC_APPEND_HISTORY" >> $HOME/.zshrc'
    sudo su - #{username} -c 'echo "setopt SHARE_HISTORY" >> $HOME/.zshrc'

    echo "[SeatDefaults]" | sudo tee /etc/lightdm/lightdm.conf
    echo "autologin-user=#{username}" | sudo tee -a /etc/lightdm/lightdm.conf
    echo "autologin-user-timeout=0" | sudo tee -a /etc/lightdm/lightdm.conf

    sudo apt-get update -q
    sudo apt-get upgrade -yq

    echo "========================================================"
    echo "=========================reboot========================="
    echo "========================================================"
        
    sudo reboot
  SHELL

end

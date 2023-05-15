#!/bin/bash

username=$USER_NAME

create_user() {
  eval "$(ssh-agent)"

  sudo adduser ${username} --gecos "" --disabled-password
  echo "${username}:iot42" | sudo chpasswd
  sudo adduser ${username} sudo
  sudo addgroup nopasswdlogin
  sudo adduser ${username} nopasswdlogin
  echo "${username} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${username}
  echo "${username} ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /root/.bashrc
  echo "sudo su -" | sudo tee -a /home/${username}/.bashrc

  sudo chown -R ${username}:${username} /home/${username}
  sudo chmod -R 755 /home/${username}
  
  sudo apt-get remove -yq gnome-keyring
  
  sudo apt-get update -q
  sudo apt-get upgrade -yq
  sudo apt-get install -yq net-tools vagrant sshpass x11-xkb-utils virtualbox
}

setup_folders() {
  sudo chmod -R 755 /home/${username}/hote

  mkdir -p /home/${username}/Desktop/IOT
  cp -R /home/${username}/hote/p1 /home/${username}/Desktop/IOT
  cp -R /home/${username}/hote/p2/* /home/${username}/Desktop/IOT
  cp -R /home/${username}/hote/p3/* /home/${username}/Desktop/IOT
  cp -R /home/${username}/hote/bonus/* /home/${username}/Desktop/IOT
  cp -R /home/${username}/hote/cmdVagrant /home/${username}/Desktop/IOT
  sudo chmod -R 777 /home/${username}/Desktop/IOT
}

setup_ssh() {
  sudo mkdir -p /home/${username}/.ssh
  sudo chown -R ${username}:${username} /home/${username}/.ssh

  sudo rsync -av --no-owner --no-group -e "ssh -o StrictHostKeyChecking=no" "C:/Users/belha/.ssh/" "/home/${username}/.ssh/"
  sudo chown ${username}:${username} /home/${username}/.ssh/authorized_keys
  sudo chmod -R 755 /home/${username}/.ssh
}

install_chrome() {
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
}

setup_zsh() {
  sudo apt-get install -yq zsh
  sudo chsh -s /bin/zsh ${username}
  sudo apt-get install -yq zsh dconf-cli
  sudo su - ${username} -c 'sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"'
}

customize_gnome() {
  sudo su - ${username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color \"'rgb(0,0,0)'\""
  sudo su - ${username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/foreground-color \"'rgb(128,128,128)'\""
  sudo su - ${username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/bold-color \"'rgb(128,128,128)'\""
  sudo su - ${username} -c "dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/underline-color \"'rgb(128,128,128)'\""
}

setup_history() {
  sudo su - ${username} -c 'echo "HISTFILE=$HOME/.zsh_history" >> $HOME/.zshrc'
  sudo su - ${username} -c 'echo "SAVEHIST=1000" >> $HOME/.zshrc'
  sudo su - ${username} -c 'echo "setopt INC_APPEND_HISTORY" >> $HOME/.zshrc'
  sudo su - ${username} -c 'echo "setopt SHARE_HISTORY" >> $HOME/.zshrc'
}

autologin() {
  echo "[SeatDefaults]" | sudo tee /etc/lightdm/lightdm.conf
  echo "autologin-user=${username}" | sudo tee -a /etc/lightdm/lightdm.conf
  echo "autologin-user-timeout=0" | sudo tee -a /etc/lightdm/lightdm.conf
}

update_upgrade() {
  sudo apt-get update -q
  sudo apt-get upgrade -yq
}

reboot() {
  echo "========================================================"
  echo "=========================reboot========================="
  echo "========================================================"
  
  sudo reboot
}

# Execution of functions
create_user
setup_folders
setup_ssh
install_chrome
setup_zsh
customize_gnome
setup_history
autologin
update_upgrade
reboot

#!/bin/bash

exists() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  local type="$1"
  local message="$2"
  local color

  case "$type" in
    info) color="\033[0;34m" ;;
    success) color="\033[0;32m" ;;
    error) color="\033[0;31m" ;;
    *) color="\033[0m" ;;
  esac

  echo -e "${color}${message}\033[0m"
}

log "info" "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

if ! exists curl; then
  log "error" "curl not found. Installing..."
  sudo apt install curl -y
else
  log "success" "curl is already installed."
fi

if ! exists wget; then
  log "error" "wget not found. Installing..."
  sudo apt install wget -y
else
  log "success" "wget is already installed."
fi

if ! exists ufw; then
  log "error" "ufw not found. Installing..."
  sudo apt install ufw -y
else
  log "success" "ufw is already installed."
fi

clear
log "info" "Run and Install Start..."
sleep 1
curl -s https://raw.githubusercontent.com/Winnode/winnode/main/Logo.sh | bash
sleep 5

log "info" "Please provide the following information:"
read -p "Enter your desired password: " PASSWORD
echo
read -p "Enter your server IP (e.g., 185.192.97.28): " SERVER_IP

log "info" "Configuring firewall..."
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 8231/tcp
sudo ufw allow 8085/tcp
sudo ufw allow 7621/udp

log "info" "Installing PWR Chain Validator Node..."
sleep 5
sudo apt update
sudo apt install -y openjdk-19-jre-headless

wget https://github.com/pwrlabs/PWR-Validator-Node/raw/main/validator.jar
wget https://github.com/pwrlabs/PWR-Validator-Node/raw/main/config.json

echo "$PASSWORD" | sudo tee password > /dev/null

if echo "$password" | sudo java -jar validator.jar --import-key "$key" "$password"; then
        print_success 
        print_su
"Key imported successfully."
    
 
else
        print_error 
        print_erro

        print_
"Failed to import key."
    fi
}



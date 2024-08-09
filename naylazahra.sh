#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}
setup_working_directory() {
    print_info "Setting up working directory..."
    cd "$HOME"
    mkdir -p pwr-hca
    cd pwr-hca
    print_success "Working directory set up at $PWD"
}
configure_firewall() {
    print_info "Configuring firewall..."
    if ! sudo ufw status | grep -q "Status: active"; then
        yes | sudo ufw enable
        print_success "Firewall enabled"
    else
        print_info "Firewall is already active"
    fi

    local ports=("22" "80" "8231/tcp" "8085/tcp" "7621/udp")
    for port in "${ports[@]}"; do
        if ! sudo ufw status | grep -q "$port"; then
            sudo ufw allow "$port"
            print_success "Opened port $port"
        else
            print_info "Port $port is already open"
        fi
    done
}

update_and_install_dependencies() {
    print_info "Updating system and installing dependencies..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y screen openjdk-19-jre-headless
    print_success "System updated and dependencies installed"
}

download_required_files() {
    print_info "Downloading required files..."
    local files=("validator.jar" "config.json")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            wget "https://github.com/pwrlabs/PWR-Validator-Node/raw/main/$file"
            print_success "Downloaded $file"
        else
            print_info "$file already exists"
        fi
    done
}

get_and_store_password() {
    print_info "Setting up password..."
    read -p "Enter your desired password: " password
    echo "$password" | sudo tee password > /dev/null
    print_success "Password stored securely"
}

run_validator() {
    local key="<your key>"  # Replace <your key> with the actual key
    local password="password"  # Replace "password" with the actual password if needed

    print_info "Running validator with key $key..."
    if sudo java -jar validator.jar --import-key "$key" "$password"; then
        print_success "Validator ran successfully."
    else
        echo "[ERROR] Failed to run validator."
    fi
}

start_validator_node() {
    print_info "Starting validator node..."
    local server_ip
    server_ip=$(hostname -I | awk '{print $1}')
    screen -S pwr -dm
    screen -S pwr -p 0 -X stuff $'sudo java -jar validator.jar password '"$server_ip"' --compression-level 0\n'
    print_success "Validator node started in background"
}

main() {
    echo -e "\n${YELLOW}======= PWR Validator Node Setup =======${NC}\n"
    
    setup_working_directory
    configure_firewall
    update_and_install_dependencies
    download_required_files
    get_and_store_password
    start_validator_node

    echo -e "\n${GREEN}======= Setup Complete =======${NC}"
    print_success "Validator node is now running in the background."
    print_info "To check the node status, use: ${YELLOW}screen -Rd pwr${NC}"
}

main

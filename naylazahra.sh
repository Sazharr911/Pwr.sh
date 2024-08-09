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


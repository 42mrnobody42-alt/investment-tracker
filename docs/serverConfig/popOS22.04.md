# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker y Docker Compose
sudo apt install docker.io docker-compose-v2 -y
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker

# Instalar Java 21 LTS
sudo apt install openjdk-21-jdk -y
java --version

# Instalar Node.js 20 LTS y npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y
node --version && npm --version

# Instalar Maven
sudo apt install maven -y
mvn --version

# Instalar Git
sudo apt install git -y
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Extensiones VS Code recomendadas
code --install-extension vscjava.vscode-java-pack
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-ossdata.vscode-postgresql
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
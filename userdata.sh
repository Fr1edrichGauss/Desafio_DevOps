#!/bin/bash
# Ativa modo de debug e tratamento de erros
set -ex

# Salva logs detalhados
exec > >(tee /var/log/user-data.log) 2>&1

# --- Passo 1: Configurar Repositório NGINX ---
echo "Configurando repositório NGINX..."
apt-get update -y
apt-get install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring

curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list

# --- Passo 2: Instalar NGINX ---
echo "Instalando NGINX..."
apt-get update -y
apt-get install -y nginx

# --- Passo 3: Configurar Firewall ---
echo "Configurando firewall..."
ufw allow 'Nginx Full'
ufw --force enable

# --- Passo 4: Iniciar Serviço ---
echo "Iniciando NGINX..."
systemctl start nginx
systemctl enable nginx

# --- Validação Final ---
echo "Verificando instalação..."
systemctl status nginx --no-pager
curl -I http://localhost

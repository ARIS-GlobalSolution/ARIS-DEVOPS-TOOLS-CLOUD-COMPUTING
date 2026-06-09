#!/bin/bash

GRUPO=aris
LOCATION=canadacentral
USER=rm566059
PASSWORD='Fiap@YF2008Exes'

RG=rg-$GRUPO
VNET=vnet-$GRUPO
SUBNET=subnet-$GRUPO
NSG=nsg-$GRUPO
VM=vm-$GRUPO

az group create \
  --name $RG \
  --location $LOCATION \
  --tags owner=$GRUPO environment=dev cost-center=fiap

az network vnet create \
  --resource-group $RG \
  --name $VNET \
  --address-prefix 10.10.0.0/16 \
  --subnet-name $SUBNET \
  --subnet-prefix 10.10.1.0/24 \
  --tags owner=$GRUPO environment=dev cost-center=fiap

az network nsg create \
  --resource-group $RG \
  --name $NSG \
  --tags owner=$GRUPO environment=dev cost-center=fiap

az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-ssh \
  --protocol Tcp \
  --priority 1000 \
  --destination-port-range 22 \
  --access Allow

az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-http \
  --protocol Tcp \
  --priority 1001 \
  --destination-port-range 80 \
  --access Allow

az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-8080 \
  --protocol Tcp \
  --priority 1002 \
  --destination-port-range 8080 \
  --access Allow

az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-8081 \
  --protocol Tcp \
  --priority 1003 \
  --destination-port-range 8081 \
  --access Allow

az network vnet subnet update \
  --resource-group $RG \
  --vnet-name $VNET \
  --name $SUBNET \
  --network-security-group $NSG

az vm create \
  --resource-group $RG \
  --name $VM \
  --image Ubuntu2204 \
  --admin-username $USER \
  --admin-password $PASSWORD \
  --authentication-type password \
  --size Standard_D2s_v3 \
  --vnet-name $VNET \
  --subnet $SUBNET \
  --nsg $NSG \
  --tags owner=$GRUPO environment=dev cost-center=fiap

az vm run-command invoke \
  --resource-group $RG \
  --name $VM \
  --command-id RunShellScript \
  --scripts '
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl git nano

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker '$USER'
  '

az vm run-command invoke \
  --resource-group $RG \
  --name $VM \
  --command-id RunShellScript \
  --scripts '
    git clone https://github.com/ARIS-GlobalSolution/ARIS-Java.git /home/'$USER'/ARIS-Java
    cd /home/'$USER'/ARIS-Java/aris-api
    
    # Substitui o docker-compose para garantir que o banco levante corretamente
    cat << "EOF" > docker-compose.yaml
version: "3.8"

services:
  aris-api:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: aris-java-api
    restart: always
    ports:
      - "8080:8080"
      - "8081:8081"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:postgresql://aris-db:5432/aris_database
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=senha_super_segura
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
      - SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
      - SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.postgresql.Driver
    depends_on:
      - aris-db
    networks:
      - aris-network

  aris-db:
    image: postgres:15-alpine
    container_name: aris-postgres
    restart: always
    environment:
      POSTGRES_DB: aris_database
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: senha_super_segura
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - aris-network

networks:
  aris-network:
    driver: bridge

volumes:
  postgres_data:
EOF

    sudo docker compose up --build -d
    sudo docker ps
  '
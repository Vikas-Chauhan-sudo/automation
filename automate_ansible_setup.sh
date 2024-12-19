#!/bin/bash

# Update system and install required packages
echo "Updating package lists and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y lsb-release software-properties-common

# Install Ansible
echo "Installing Ansible..."
sudo apt-get install -y ansible

# Switch to root directory
cd ~

# Generate SSH key pair
echo "Generating SSH key pair..."
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

# Secure SSH directory
chmod 700 ~/.ssh/
cd ~/.ssh/

# Prompt user for nodes and configure SSH access
echo "Enter the nodes to configure (e.g., node1@192.168.1.11). Type 'done' when finished:"
nodes=()
while true; do
  read -p "Enter hostname@IP: " node
  if [[ "$node" == "done" ]]; then
    break
  elif [[ -n "$node" ]]; then
    nodes+=("$node")
  fi
done

# Add public key to each node's authorized_keys
for node in "${nodes[@]}"; do
  echo "Adding public key to $node..."
  ssh "$node" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
  cat id_rsa.pub | ssh "$node" "cat >> ~/.ssh/authorized_keys"
  ssh "$node" "chmod 600 ~/.ssh/authorized_keys"
done

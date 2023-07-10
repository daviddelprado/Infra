#!/bin/bash
# Use this for your user data (script from top to bottom)
# install and configure jupite node

apt update -y && apt install munge -y && apt install vim -y && apt install build-essential -y && apt install git -y && apt-get install mariadb-server -y && apt install wget -y

DEBIAN_FRONTEND=noninteractive
apt install slurm-client -y
apt install curl dirmngr apt-transport-https lsb-release ca-certificates -y
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt install  -y && apt install python3.9 python3-pip -y && useradd -m admin -s /usr/bin/bash -d /home/admin && echo "admin:admin" | chpasswd && adduser admin sudo && echo "admin     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

apt update -y && apt install nodejs -y && npm install -g configurable-http-proxy && pip3 install jupyterlab==2.1.2 
apt install libopenmpi-dev -y && pip3 install mpi4py && pip3 install jupyterlab_slurm
pip install markupsafe==2.0.1

apt install nfs-common -y
mkdir -p /shared
echo "172.31.0.100:/shared /shared nfs defaults 0 0" >> /etc/fstab
mount -a
cp /shared/config/slurm.conf /etc/slurm-llnl/slurm.conf
cp /shared/config/nodes.conf /etc/slurm-llnl/nodes.conf
cp /shared/config/partitions.conf /etc/slurm-llnl/partitions.conf
cp /shared/config/munge.key /etc/munge/munge.key
chown munge.munge /etc/munge/munge.key
service munge start

jupyter lab --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password=''




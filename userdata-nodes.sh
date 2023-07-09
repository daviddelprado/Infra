apt update -y && apt install munge -y && apt install vim -y && apt install build-essential -y && apt install git -y && apt-get install mariadb-server -y && apt install wget -y
DEBIAN_FRONTEND=noninteractive
apt install slurmd slurm-client -y
apt install -y && apt install python3.9 python3-pip -y && useradd -m admin -s /usr/bin/bash -d /home/admin && echo "admin:admin" | chpasswd && adduser admin  && echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
apt update -y && apt install libopenmpi-dev -y && pip3 install mpi4py


cat << 'EOF' > /etc/slurm-llnl/nodes.conf
NodeName=REPLACE_NODE REPLACE_CPU State=UNKNOWN
EOF

cat << 'EOF' > /etc/slurm-llnl/partitions.conf
PartitionName=team4 Nodes=REPLACE_NODE Default=YES MaxTime=INFINITE State=UP
EOF

sed -i "s/REPLACE_IT/CPUs=$(nproc)/g" /etc/slurm-llnl/nodes.conf
sed -i "s/REPLACE_NODE/CPUs=$(hostname -s)/g" /etc/slurm-llnl/nodes.conf
sed -i "s/REPLACE_NODE/CPUs=$(hostname -s)/g" /etc/slurm-llnl/partitions.conf


cp /shared/config/slurm.conf /etc/slurm-llnl/slurm.conf
slurmd -N $(hostname)

apt install nfs-common -y
mkdir -p /shared

echo "172.31.0.104:/shared /shared nfs defaults 0 0" /etc/fstab
mount -a
cp /shared/config/slurm.conf /etc/slurm-llnl/slurm.conf
cp /shared/config/munge.key /etc/munge/munge.key
chown munge.munge /etc/munge/munge.key
service munge start
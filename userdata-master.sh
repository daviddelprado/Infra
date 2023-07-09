#!/bin/bash
# Use this for your user data (script from top to bottom)
# install 
apt update -y && apt install munge -y && apt install vim -y && apt install build-essential -y && apt install git -y && apt-get install mariadb-server -y && apt install wget -y
DEBIAN_FRONTEND=noninteractive
apt install slurmd slurm-client slurmctld -y 
apt install -y && apt install python3.9 python3-pip -y && useradd -m admin -s /usr/bin/bash -d /home/admin && echo "admin:admin" | chpasswd && adduser admin  && echo "admin     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 
apt update -y && apt install libopenmpi-dev -y && pip3 install mpi4py


cat << 'EOF' > /etc/slurm-llnl/slurm.conf 
SlurmctldHost=REPLACE_MASTER
MpiDefault=none
ProctrackType=proctrack/linuxproc
ReturnToService=1
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=root
StateSaveLocation=/var/spool
SwitchType=switch/none
TaskPlugin=task/affinity
TaskPluginParam=Sched
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0
SchedulerType=sched/backfill
SelectType=select/cons_res
SelectTypeParameters=CR_Core
AccountingStorageType=accounting_storage/none
AccountingStoreJobComment=YES
ClusterName=cluster
JobCompType=jobcomp/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=error
SlurmctldLogFile=/var/log/slurm-llnl/slurmctld.log
SlurmdDebug=error
SlurmdLogFile=/var/log/slurm-llnl/slurmd.log

include /etc/slurm-llnl/nodes.conf
include /etc/slurm-llnl/partitions.conf

EOF

sed -i "s/REPLACE_MASTER/$(hostname -s)/g" /etc/slurm-llnl/slurm.conf

mkdir -p /shared
chown nobody:nogroup /shared
chmod 777 /shared
apt install nfs-kernel-server -y
echo "/shared 172.31.1.0/24(rw,sync,no_subtree_check)" >> /etc/exports
exportfs -a


mkdir /shared/config
cp /etc/slurm-llnl/slurm.conf /shared/config
cp /etc/munge/munge.key /shared/config

service munge start
service slurmctld start
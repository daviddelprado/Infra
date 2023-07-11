#!/bin/bash
# Use this for your user data (script from top to bottom)
# install and configure master node

mkdir -p /shared/software
chown nobody:nogroup /shared -R
chmod 777 /shared -R
apt install nfs-kernel-server -y
echo "/shared 172.31.1.0/24(rw,sync,no_subtree_check)" >> /etc/exports
echo "/shared 172.31.0.0/24(rw,sync,no_subtree_check)" >> /etc/exports
exportfs -a


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

cat << 'EOF' > /etc/slurm-llnl/nodes.conf
NodeName=ip-172-31-0-100,ip-172-31-0-101 REPLACE_CPU RealMemory=7000 State=UNKNOWN
EOF

cat << 'EOF' > /etc/slurm-llnl/partitions.conf
PartitionName=team4 Nodes=ip-172-31-0-100,ip-172-31-0-101 Default=YES MaxTime=INFINITE State=UP
EOF

sed -i "s/REPLACE_CPU/CPUs=$(nproc)/g" /etc/slurm-llnl/nodes.conf
sed -i "s/REPLACE_NODE/$(hostname -s)/g" /etc/slurm-llnl/nodes.conf
sed -i "s/REPLACE_NODE/$(hostname -s)/g" /etc/slurm-llnl/partitions.conf

mkdir /shared/config
cp /etc/slurm-llnl/slurm.conf /shared/config
cp /etc/slurm-llnl/nodes.conf /shared/config
cp /etc/slurm-llnl/partitions.conf /shared/config
cp /etc/munge/munge.key /shared/config
chmod 444 /shared/config/munge.key

service munge start
service slurmctld start
service slurmd start

mkdir /shared/software
wget -P /shared/software -O /shared/software/pi.tar.xz http://www.numberworld.org/y-cruncher/y-cruncher%20v0.7.10.9513-static.tar.xz
tar -xvf /shared/software/pi.tar.xz

cat << 'EOF' > /shared/software/job-pi.sl
#!/bin/bash
#SBATCH -J PI-1CPU
#SBATCH --time=01:00:00         # Walltime
#SBATCH --mem-per-cpu=1         # memory/cpu
#SBATCH --ntasks=1      # MPI processes
#SBATCH --output=1cpuslurm-%j.out

./y-cruncher skip-warnings bench 100m
EOF
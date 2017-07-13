#!/bin/bash
#debian 8 to db9 init

function db_testnetwork()
{
time wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip
time wget -O /dev/null http://cachefly.cachefly.net/100mb.test
}

function db_testspeed()
{
time (for((i=1;i<=10000;i++));do echo $(expr $i \* 4) > /dev/null ;done)
time echo "scale=2000; 4*a(1)" | bc -l -q
}

function db_bench()
{
wget -qO- bench.sh | bash
}

function db_aptsource()
{
mv /etc/apt/sources.list /etc/apt/sources.list._Jessie_org
cat << EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian/ stretch main
deb-src http://ftp.debian.org/debian/ stretch main

deb http://security.debian.org/ stretch/updates main
deb-src http://security.debian.org/ stretch/updates main

# stretch-updates, previously known as 'volatile'
deb http://ftp.debian.org/debian/ stretch-updates main
deb-src http://ftp.debian.org/debian/ stretch-updates main

EOF
}

function db_initpree()
{
apt-get update -y --fix-missing
apt-get install -y debian-archive-keyring nano screen 
}

function db_ss()
{
apt-get install -y shadowsocks-libev
$sspwd=$1
cat << EOF > /etc/shadowsocks-libev/config.json
{
    "server":"0.0.0.0",
    "server_port":12390,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"$sspwd",
    "timeout":600,
    "method":"chacha20-ietf"
}
EOF

systemctl restart shadowsocks-libev

}

function db_bbr()
{
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem="4096 65536 67108864"' >> /etc/sysctl.conf
sysctl -p
sysctl net.ipv4.tcp_congestion_control
lsmod | grep bbr
}

function db_ssport()
{
sed 's/\#Port\ 22/Port\ 27790/' /etc/ssh/sshd_config | tee > /etc/ssh/sshd_config
sed 's/Port\ 22/Port\ 27790/' /etc/ssh/sshd_config | tee > /etc/ssh/sshd_config
systemctl restart ssh.service 
}

function db_init()
{
db_aptsource
db_initpree
db_ss $sspwd
apt-get -y -qq dist-upgrade
apt-get -y install open-vm-tools open-vm-tools-dkms
db_bbr
#db_ssport

}

function db_help()
{
Cat << EOF
This is Help file for this script:

Usage:
. dbinitcmd.sh && db_help
and so on...
EOF
}

db_help
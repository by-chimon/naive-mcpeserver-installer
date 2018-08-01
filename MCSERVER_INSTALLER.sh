#!/bin/bash
#MCPESERVER_INSTALLER_1.5_SH
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
printf "
   __   _       ___   _   _     _   _____  
  |  \ | |     /   | | | | |   / / | ____| 
  |   \| |    / /| | | | | |  / /  | |__   
  | |\   |   / /_| | | | | | / /   |  __|  
  | | \  |  /  __  | | | | |/ /    | |___  
  |_|  \_| /_/   |_| |_| |___/     |_____| 
  System Required: CentOS 7+/Ubuntu 16.04+
"

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}
check_sys
[[ ${release} != "centos" ]] && [[ ${release} != "ubuntu" ]] && echo -e "\033[31m[Error] 本脚本不支持当前系统\033[0m \033[32m${release}\033[0m!" && exit 1

echo -n -e "\033[36m输入您的安装路径(默认为/home/mcpe):\033[0m "
read INSTALL_PATH
[[ -z "$INSTALL_PATH" ]] && INSTALL_PATH="/home/mcpe"
echo "您的安装路径被设定为"$INSTALL_PATH
sleep 3

#安装依赖
echo "开始安装......"
[[ ${release} == "centos" ]] && sudo yum update -y && sudo yum install -y wget jq
[[ ${release} == "ubuntu" ]] && sudo apt update -y && sudo apt install -y wget jq
#检测重名目录
[[ -d "$INSTALL_PATH" ]] && rm -rf $INSTALL_PATH"_old" && mv $INSTALL_PATH $INSTALL_PATH"_old"
mkdir $INSTALL_PATH
cd $INSTALL_PATH
#下载并安装资源
wget $(curl -s https://api.github.com/repos/codehz/mcpeserver/releases/latest|jq -r '.assets[0].browser_download_url')
chmod +x mcpeserver
wget https://minebbs-1251544790.file.myqcloud.com/MCPE86/Minecraft_1.5.2.1_X86.apk -O Minecraft.apk
./mcpeserver unpack -apk Minecraft.apk
./mcpeserver download
sleep 3

#创建服务
getuserid=`whoami`
echo -e "\033[32m开始为Naive创建服务......\033[0m"
[ -f /lib/systemd/system/naive.service ] && sudo rm -rf /lib/systemd/system/naive.service
sudo echo "[Unit]" >> /lib/systemd/system/naive.service
sudo echo "Description=Minecraft Naïve Server" >> /lib/systemd/system/naive.service
sudo echo "After=network.target" >> /lib/systemd/system/naive.service
sudo echo " " >> /lib/systemd/system/naive.service
sudo echo "[Service]" >> /lib/systemd/system/naive.service
sudo echo "Type=simple" >> /lib/systemd/system/naive.service
sudo echo "User="$getuserid >> /lib/systemd/system/naive.service
sudo echo "WorkingDirectory="$INSTALL_PATH >> /lib/systemd/system/naive.service
sudo echo "ExecStart=$INSTALL_PATH/mcpeserver daemon" >> /lib/systemd/system/naive.service
sudo echo " " >> /lib/systemd/system/naive.service
sudo echo "[Install]" >> /lib/systemd/system/naive.service
sudo echo "WantedBy=multi-user.target" >> /lib/systemd/system/naive.service
sudo systemctl enable naive
sudo systemctl start naive
echo -e "\033[32m安装成功,服务器已启动,若无法连接请检查防火墙策略(19132端口)\033[0m"
echo -e "现在你可在安装目录执行 \033[36m./mcpeserver attach\033[0m 操作服务端"

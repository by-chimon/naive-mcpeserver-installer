#!/bin/bash
#MCPESERVER_INSTALLER_1.5_SH
clear
echo " __   _       ___   _   _     _   _____  "
echo "|  \ | |     /   | | | | |   / / | ____| "
echo "|   \| |    / /| | | | | |  / /  | |__  "
echo "| |\   |   / /_| | | | | | / /   |  __|  "
echo "| | \  |  /  __  | | | | |/ /    | |___  "
echo "|_|  \_| /_/   |_| |_| |___/     |_____| "
echo ""

echo -n "输入您的安装路径：(默认为/home/mcpe)"
read INSTALL_PATH
if test -z "$INSTALL_PATH"
then 
	INSTALL_PATH="/home/mcpe"
	echo "您的安装路径被设定为"$INSTALL_PATH
else
	echo "您的安装路径被设定为"$INSTALL_PATH
fi
echo "建立名为mc_new的screen"
sleep 3
yum install -y wget jq screen
sleep 3
echo "建立名为mc_new的screen"
screen -S mc_new
mkdir $INSTALL_PATH
cd $INSTALL_PATH
wget $(curl -s https://api.github.com/repos/codehz/mcpeserver/releases/latest|jq -r '.assets[0].browser_download_url')
chmod +x  mcpeserver
./mcpeserver download
wget https://raw.githubusercontent.com/by-chimon/naive-mcpeserver-installer/master/Minecraft.apk -o Minecraft.apk
./mcpeserver unpack -apk Minecraft.apk
read -p "安装完毕是否直接启动，输入yes确认，否则直接退出......" yes
if  [ "$yes"="yes" ] ;then
    ./mcpeserver run
else
	echo "安装成功，稍后您可以使用./mcpeserver run启动服务器"
fi

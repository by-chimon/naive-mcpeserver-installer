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

echo -n -e "\033[36m输入您的安装路径(默认为/home/mcpe):\033[0m "
read INSTALL_PATH

if test -z "$INSTALL_PATH"
then 
	INSTALL_PATH="/home/mcpe"
	echo "您的安装路径被设定为"$INSTALL_PATH
else
	echo "您的安装路径被设定为"$INSTALL_PATH
fi

sleep 3

echo "开始安装......"
yum install -y wget jq screen

if [[ ! -d "$INSTALL_PATH" ]]
then
	mkdir $INSTALL_PATH
else
	mv $INSTALL_PATH $INSTALL_PATH"_old"
	mkdir $INSTALL_PATH
fi

cd $INSTALL_PATH
wget $(curl -s https://api.github.com/repos/codehz/mcpeserver/releases/latest|jq -r '.assets[0].browser_download_url')
chmod +x mcpeserver
wget http://d01-1251778924.coscd.myqcloud.com/Minecraft.apk -O Minecraft.apk
./mcpeserver unpack -apk Minecraft.apk
./mcpeserver download
sleep 3

echo -e "\033[36m \033[0m"

getuserid=`whoami`
read -p "是否为Naive创建服务？yes表示确定，否则跳过" check_sv_yes
if  [ "$check_sv_yes"="yes" ] 
then
	echo -e "\033[32m开始为Naive创建服务......\033[0m"
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
	echo -e "\033[32m安装成功，服务器已启动\033[0m"
else
	read -p "安装完毕是否直接启动，输入yes确认，否则直接退出......" yes
	if  [ "$yes"="yes" ] ;then
		echo -e "\033[32m安装成功，正在启动服务器(前台)\033[0m"
		./mcpeserver run
	else
		echo "\033[32m安装成功，稍后您可以自行启动服务器\033[0m"
	fi
fi


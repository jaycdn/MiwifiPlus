#!/bin/sh

pluginhost="vv2.vicp.net/miwifi"
clear
echo "Miwifi Plus安装程序"
echo "反馈请加QQ群：162049771"
sleep 2s
echo "您确认要安装Miwifi Plus插件吗？y/n"
read
[ "$REPLY" = "y" -o "$REPLY" = "Y" ] || { echo "退出安装..."; exit; }

echo "正在为您安装..."
MODEL=$(cat /proc/xiaoqiang/model)
if [ "$MODEL" = "R1D" -o "$MODEL" = "R2D" ];
then
	cpu="arm"
	MIWIFIPATH="/userdisk/data"
elif [ "$MODEL" = "R3" -o "$MODEL" = "R1CM" ];
then
	cpu="mipsel"
	if [ $(df|grep -Ec '\/extdisks\/sd[a-z][0-9]?$') -eq 0 ];
	then
		echo "未找到外置存储设备，退出。"
		return 1
	else
		MIWIFIPATH=$(df|awk '/\/extdisks\/sd[a-z][0-9]?$/{print $6;exit}')
	fi
else
	echo "暂不支持您的路由器。"
	return 1
fi
echo "您使用的是$cpu芯片，为您下载对应安装包..."
rm -rf /tmp/yuneon.tar.gz

wget http://$pluginhost/$cpu/yuneon.tar.gz -O /tmp/yuneon.tar.gz

if [ $? -eq 0 ];
then
    echo "安装包下载完成！"
else 
    echo "安装包下载失败，正在退出..."
	rm -rf /tmp/yuneon.tar.gz
    exit
fi

echo "正在为您解压安装包..."

tar -xvf /tmp/yuneon.tar.gz -C $MIWIFIPATH/

if [ $? -eq 0 ];
then
    echo "解压完成!"
	rm -rf /tmp/yuneon.tar.gz
else 
    echo "解压失败..."
	rm -rf /tmp/yuneon.tar.gz
    exit
fi

echo "正在配置安装程序..."
chmod +x $MIWIFIPATH/yuneon/scripts/*
$MIWIFIPATH/yuneon/scripts/yuneoninit

echo "MIWIFI PLUS已安装成功！"

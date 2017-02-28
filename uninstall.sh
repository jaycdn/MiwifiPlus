#!/bin/sh
LUAPATH="/usr/lib/lua"
DDNSPATH="/usr/lib/ddns"
CSSPATH="/www/xiaoqiang/web/css"
IMGPATH="/www/xiaoqiang/web/img"
echo "正在为您卸载..."
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
		MIWIFIPATH="$(ls /extdisks/sd*/yuneon/scripts/yuneoninit 2>/dev/null | sed 's/\/scripts\/yuneoninit//' | awk '{print;exit}')"
		[ -z $MIWIFIPATH ] && {
			echo "未找到插件目录，退出...";
			return 1;
		}
	fi
else
	echo "暂不支持您的路由器。"
	return 1
fi
success=0
removeconf=0
clear
echo "MIWIFI PLUS卸载程序"
echo "反馈请加QQ群：162049771"
sleep 2s

echo "开始卸载..."
echo "正在关闭服务..."
/etc/init.d/shadowsocks stop
/etc/init.d/adm stop
/etc/init.d/ngrok stop
/etc/init.d/shadowsocks disable
/etc/init.d/adm disable
/etc/init.d/ngrok disable

echo "正在移除服务脚本..."
rm -rf /etc/init.d/adm
rm -rf /etc/init.d/shadowsocks
rm -rf /etc/init.d/ngrok

echo "正在移除配置文件..."
rm -rf /etc/config/yuneon
rm -rf /etc/config/shadowsocks
rm -rf /etc/config/ngrok
rm -rf /etc/config/ddns
touch /etc/config/ddns
uci set ddns.ddns=global
uci set ddns.ddns.status=on
uci commit ddns

sed -i '/yuneon/d' /etc/firewall.user
umount -lf $DDNSPATH 2>/dev/null
umount -lf $CSSPATH 2>/dev/null
umount -lf $IMGPATH 2>/dev/null
umount -lf $LUAPATH 2>/dev/null

echo "正在移除程序目录..."
rm -rf $MIWIFIPATH/yuneon
rm -rf /tmp/luci-modulecache
rm -rf /tmp/luci-indexcache

echo "MIWIFI PLUS卸载成功！"

return $success

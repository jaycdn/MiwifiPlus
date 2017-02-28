success=0
pluginhost="vv2.vicp.net/miwifi"
clear
echo "MIWIFI PLUS更新程序"
echo "反馈请加QQ群：162049771"
sleep 2s

echo "开始下载新的程序包..."
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
		MIWIFIPATH=$(ls /extdisks/sd*/yuneon/scripts/yuneoninit 2>/dev/null | sed 's/\/scripts\/yuneoninit//' | awk '{print;exit}')
		[ -z $MIWIFIPATH ] && {
			echo "未找到插件目录，退出...";
			return 1;
		}
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
rm -rf /etc/init.d/miwifiplus

echo "删除旧文件.."
rm -rf $MIWIFIPATH/bin/ss-local
rm -rf $MIWIFIPATH/bin/dns2socks

sed -i '/miwifiplus/d' /etc/firewall.user

echo "正在为您解压安装包..."

tar -xvf /tmp/yuneon.tar.gz -C $MIWIFIPATH/

if [ $? -eq 0 ];
then
    echo "解压完成!"
	rm -rf /tmp/yuneon.tar.gz
else 
    echo "解压失败，退出..."
	rm -rf /tmp/yuneon.tar.gz
    return 1
fi

echo "正在配置安装程序..."
chmod +x $MIWIFIPATH/yuneon/scripts/*
$MIWIFIPATH/yuneon/scripts/yuneoninit
[ $? -eq 0 ] || success=1

if [ $success -eq 0 ];
then
	echo "MIWIFI PLUS升级成功！"
else
	echo "升级出现问题!"
fi
return $success

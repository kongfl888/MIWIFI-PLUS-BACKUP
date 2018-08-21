success=0
PLUGINHOST="vv2.vicp.net/miwifi"
clear
echo "MIWIFI PLUS更新程序"
echo "反馈请加QQ群1：162049771（已满）；群2：110678294"
sleep 2s

echo "开始下载新的程序包..."
MODEL=$(cat /proc/xiaoqiang/model)
if [ "$MODEL" = "R1D" -o "$MODEL" = "R2D" ];
then
	CPU="arm1"
	MIWIFIPATH="/etc"
elif [ "$MODEL" = "R3D" ];
then
	CPU="arm2"
	MIWIFIPATH="/etc"
elif [ "$MODEL" = "R3" ];
then
	CPU="mipsel1"
	MIWIFIPATH="/etc"
elif [ "$MODEL" = "R1CM" ];
then
	CPU="mipsel1"
	if [ $(df|grep -Ec '\/extdisks\/sd[a-z][0-9]?$') -eq 0 ];
	then
		echo "未找到外置存储设备，退出。"
		return 1
	else
		MIWIFIPATH=$(df|awk '/\/extdisks\/sd[a-z][0-9]?$/{print $6;exit}')
	fi
elif [ "$MODEL" = "R3P" ];
then
	CPU="mipsel2"
	MIWIFIPATH="/etc"
else
	echo "暂不支持您的路由器。"
	return 1
fi


echo "您使用的是$MODEL，为您下载对应安装包..."
rm -rf /tmp/yuneon.tar.gz

wget http://$PLUGINHOST/$CPU/yuneon.tar.gz -O /tmp/yuneon.tar.gz

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
/etc/init.d/adm stop 2>/dev/null
/etc/init.d/kp stop
/etc/init.d/ngrok stop
/etc/init.d/shadowsocks disable
/etc/init.d/adm disable
/etc/init.d/ngrok disable

echo "正在移除服务脚本..."
rm -rf /etc/init.d/adm
rm -rf /etc/init.d/kp
rm -rf /etc/init.d/shadowsocks
rm -rf /etc/init.d/ngrok
rm -rf /etc/init.d/miwifiplus

echo "删除旧文件.."
rm -rf $MIWIFIPATH/bin/ss-local
rm -rf $MIWIFIPATH/bin/dns2socks
rm -rf $MIWIFIPATH/bin/kp/kp

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
mv $MIWIFIPATH/yuneon/ipset/sswhite_list.conf $MIWIFIPATH/yuneon/ipset/ss_user_dst_forward.conf 2>/dev/null
mv $MIWIFIPATH/yuneon/ipset/ssblack_list.conf $MIWIFIPATH/yuneon/ipset/ss_user_dst_drop.conf 2>/dev/null
mv $MIWIFIPATH/yuneon/ipset/usr_dnslist.conf $MIWIFIPATH/yuneon/ipset/ss_user_dns_list.conf 2>/dev/null
sed -i 's/sswhite_list/ss_user_dst_forward/g' $MIWIFIPATH/yuneon/ipset/ss_user_dst_forward.conf 2>/dev/null
sed -i 's/ssblack_list/ss_user_dst_drop/g' $MIWIFIPATH/yuneon/ipset/ss_user_dst_drop.conf 2>/dev/null

$MIWIFIPATH/yuneon/scripts/yuneoninit
[ $? -eq 0 ] || success=1

if [ $success -eq 0 ];
then
	echo "MIWIFI PLUS升级成功！"
else
	echo "升级出现问题!"
fi
return $success

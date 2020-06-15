#!/bin/bash
#执行此脚本必须使用【/bin/bash/ iptables_config.sh】此命令执行，否则输入为空会继续执行脚本！
#运行此脚本，建议最后添加ssh的防火墙规则
service iptables restart
echo "当前开启的程序如下"
echo "############################"
netstat -lunpt | awk '/tcp/{print $1"---"$4"---"$7}'
netstat -lunpt | awk '/udp/{print $1"---"$4"---"$6}'
echo "############################"
  read -p "【请输入以上输出中的程序名】:" name
echo "############################"
if [ -z $name ];then
   echo "【程序名不能为空】"
   kill $$
fi

echo "############################"

netstat -lunpt | grep $name | awk '{print $4}' >> not_port.txt

for i in `cat ./not_port.txt`
 do
   echo ${i##*:} >> ./yes_port.txt
 done
for t in `cat ./yes_port.txt`
 do 
   iptables -I INPUT -p tcp --dport $t -j ACCEPT
 done
echo "############################"
service iptables save >> /dev/null
if [ $? -ne 0 ];then
   echo "[防火墙策略保存失败！]"
else
   echo "[防火墙策略保存成功！]"
fi
echo "############################"
iptables -L | grep "dpt:ssh" >>/dev/null
if [ $? -ne 0 ];then
    echo "远程ssh端口(22)未添加防火墙规则"
else 
    iptables -I INPUT -p icmp -j ACCEPT && service iptables save && chkconfig iptables on && sed -i '$a sleep 10s;service iptables start
' /etc/rc.local && echo "【防火墙策略添加成功！】"|| echo "【防火墙配置失败！】"
fi
rm -rf not_port.txt yes_port.txt 
echo "############################"
echo "[当前防火墙策略如下：]"
echo "############################"
iptables -nL
echo "----------------------------"
service iptables restart

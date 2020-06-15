#!/bin/bash

#获取protocol头信息中的set-cookie字段到文件中

curl http://100.85.252.101:19001/service/system/login -X POST -d "userName=admin&password=E10ADC3949BA59ABBE56E057F20F883E"  --trace-time -i >/tmp/cookie.txt

#使用流式编辑器去除";"字符

sed -i 's/;//g' /tmp/cookie.txt

#匹配出带有"Set-Cookie"字段行的第二个值,定义变量

key=`awk '/Set-Cookie/{print $2}' /tmp/cookie.txt`

#停止DAQ服务
curl http://100.85.252.101:19001/service/system/accessServer/endCmd?id=01927c6ae804412b87d01dcc2b168e6a  -b $key

#检测停止状态
[ $? -eq 0] && echo -e "\033[1;32m DAQ正在关闭! \033[0m" || echo -e "\033[1;31m DAQ关闭失败! \033[0m" && exit 1

sleep 60

#启动DAQ服务
curl http://100.85.252.101:19001/service/system/accessServer/startCmd?id=01927c6ae804412b87d01dcc2b168e6a  -b $key

#检测启动状态
[ $? -eq 0] && echo -e "\033[1;32m DAQ正在启动! \033[0m" || echo -e "\033[1;31m DAQ启动失败! \033[0m" && exit 1
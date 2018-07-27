#!/bin/bash
# function:monitor tcp connect status from zabbix
source /etc/bashrc > /dev/null 2>&1
source /etc/profile > /dev/null 2>&1
jmx_port_discovery () {
jmx_port=($(cat /usr/local/zabbix/bin/java.txt|cut -d "|" -f2))
Tomcat_Name=($(cat /usr/local/zabbix/bin/java.txt|cut -d "|" -f1))
printf '{\n'
printf '\t"data":[\n'
for((i=0;i<${#jmx_port[@]};++i))
{
num=$(echo $((${#jmx_port[@]}-1)))
if [ "$i" != ${num} ];then
printf "\t\t{ \n"
printf "\t\t\t\"{#JMX_PORT}\":\"${jmx_port[$i]}\",\n"
printf "\t\t\t\"{#JAVA_NAME}\":\"${Tomcat_Name[$i]}\"},\n"
else
printf "\t\t{ \n"
printf "\t\t \n"
printf "\t\t\t\"{#JMX_PORT}\":\"${jmx_port[$i]}\",\n"
printf "\t\t\t\"{#JAVA_NAME}\":\"${Tomcat_Name[$i]}\"}]}\n"
fi
}
}
case "$1" in
jmx_port_discovery)
jmx_port_discovery
;;
*)
echo "Usage:$0 {jmx_port_discovery}"
;;
esac

#!/bin/bash

PORT=()
port=(`sed "s/\s//g" /etc/my*.cnf |awk -F "=" '$1=="port"{print $2}' |sort |uniq`)

MySQL_Master () {
    for((i=0;i<${#port[@]};++i));do
	    if `grep  -q $(printf '%04X.00000000*:0000.0A' "${port[i]}") /proc/net/tcp*`;then
		    PORT=(${PORT[@]} ${port[i]})
	    fi
    done
}


MySQL_Slave () {
    for((i=0;i<${#port[@]};++i));do
        if `grep  -q $(printf '%04X.00000000*:0000.0A' "${port[i]}") /proc/net/tcp*`;then
                if [ `bash /usr/local/zabbix/bin/check_mysql.sh ${port[i]} IsSlave` -ne 0 ];then
                    PORT=(${PORT[@]} ${port[i]})
                fi
        fi
    done
}


MySQL () {
                        printf '{\n'
                        printf '\t"data":[\n'
        for((i=0;i<${#PORT[@]};++i));do
                num=$(echo $((${#PORT[@]}-1)))
                {
                if [ "$i" != ${num} ];then
                        printf "\t\t{ \n"
                        printf "\t\t\t\"{#PORT}\":\"${PORT[$i]}\"},\n"
                else
                        printf "\t\t{ \n"
                        printf "\t\t\t\"{#PORT}\":\"${PORT[$i]}\"}\n\t\t]\n}\n"
                fi
                }
done
}

$1
MySQL

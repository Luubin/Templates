#!/bin/bash
discovery() {
MQ_IP=(10.240.10.35 10.240.10.36)
            for g in ${MQ_IP[@]}
            do 
            curl -uadmin:admin http://${g}:4401/admin/queues.jsp >/dev/null 2>&1
            if [ $? -eq 0 ]; then
            i=$g
            fi
            port=($(curl -uadmin:admin http://${i}:4401/admin/queues.jsp 2>/dev/null| grep -A 5 "${QUEUENAME}</a></td>"|awk -F '<' '{print $0}'|sed 's/<\/td>//g'|sed 's/<.*>//g;/^$/d;/--/d'|grep '^[a-Z]'))
            done 
            printf '{\n'
            printf '\t"data":[\n'
               for key in ${!port[@]}
                   do
                       if [[ "${#port[@]}" -gt 1 && "${key}" -ne "$((${#port[@]}-1))" ]];then
                          printf '\t {\n'
                          printf "\t\t\t\"{#QUEUENAME}\":\"${port[${key}]}\"},\n"
                     else [[ "${key}" -eq "((${#port[@]}-1))" ]]
                          printf '\t {\n'
                          printf "\t\t\t\"{#QUEUENAME}\":\"${port[${key}]}\"}\n"
                       fi
               done
                          printf '\t ]\n'
                          printf '}\n'
}

discovery

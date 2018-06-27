#!/bin/bash
partition() {
	port=($(grep -E "(vd[a-z]$|sd[a-z]$|sddlma[a-z]$|xvd[a-z]$|dm-[0-9]$)" /proc/partitions|awk '{print $4}'))
            printf '{\n'
            printf '\t"data":[\n'
               for key in ${!port[@]}
                   do
                       if [[ "${#port[@]}" -gt 1 && "${key}" -ne "$((${#port[@]}-1))" ]];then
                          printf '\t {\n'
                          printf "\t\t\t\"{#PARTITIONNAME}\":\"${port[${key}]}\"},\n"
                     else [[ "${key}" -eq "((${#port[@]}-1))" ]]
                          printf '\t {\n'
                          printf "\t\t\t\"{#PARTITIONNAME}\":\"${port[${key}]}\"}\n"
                       fi
               done
                          printf '\t ]\n'
                          printf '}\n'
}
$1

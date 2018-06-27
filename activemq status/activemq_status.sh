#/bin/sh
QUEUENAME=$1
MQ_COMMAND=$2
MQ_IP=(10.240.10.35 10.240.10.36)
            for g in ${MQ_IP[@]}
            do 
            curl -uadmin:PaaSword http://${g}:4401/admin/queues.jsp >/dev/null 2>&1
            if [ $? -eq 0 ]; then
            i=$g
case $MQ_COMMAND in
         Enqueued)
            curl -uadmin:PaaSword http://${i}:4401/admin/queues.jsp 2>/dev/null| grep -A 5 "${QUEUENAME}</a></td>"|awk -F '<' '{print $2}'|sed 's/td>//g'|grep '^[0-9]'|head -3|tail -1
            ;;
         Dequeued)
           curl -uadmin:PaaSword http://${i}:4401/admin/queues.jsp 2>/dev/null| grep -A 5 "${QUEUENAME}</a></td>"|awk -F '<' '{print $2}'|sed 's/td>//g'|grep '^[0-9]'|head -3|tail -1
            ;;
         Pending)
            curl -uadmin:PaaSword http://${i}:4401/admin/queues.jsp 2>/dev/null| grep -A 5 "${QUEUENAME}</a></td>"|awk -F '<' '{print $2}'|sed 's/td>//g'|grep '^[0-9]'|head -1
            ;;
         Consumers)
            curl -uadmin:PaaSword http://${i}:4401/admin/queues.jsp 2>/dev/null| grep -A 5 "${QUEUENAME}</a></td>"|awk -F '<' '{print $2}'|sed 's/td>//g'|grep '^[0-9]'|head -2|tail -1
            ;;
esac
       fi
 done

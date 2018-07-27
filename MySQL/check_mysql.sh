#!/bin/sh 

MYSQL_PWD=/usr/local/zabbix/bin/.mysqlpassword

#取得INNODB_BUFFER_READ_HITS
#定义：INNODB_BUFFER_READ_HITS，极为重要的一个状态值，反应innodb引擎所需数据在内存中的命中的情况。
#计算公式：
#innodb_buffer_pool_read_requests 是请求次数
#innodb_buffer_pool_reads   从磁盘读数据的次数
#INNODB_BUFFER_READ_HITS=(1-((新innodb_buffer_pool_reads - 老innodb_buffer_pool_reads)/(新innodb_buffer_pool_read_requests - 老innodb_buffer_pool_read_requests)))*100%  (均为当前值)
#报警阀值：小于95%
#报警类型：小于95% 警告
function POOL_HITS(){
    statusFile=/usr/local/zabbix/bin/.zabbix_mysql_"$1".txt
    sql="select VARIABLE_NAME,VARIABLE_VALUE from information_schema.global_status"
    if [ -e ${statusFile} ]; then
        mv -f ${statusFile} ${statusFile}.old
    fi
    mysql --defaults-file=/usr/local/zabbix/bin/.mysqlpassword -P $1 -NB -e "${sql}" > ${statusFile}
    newRead=`cat ${statusFile} | grep -i -w 'innodb_buffer_pool_reads' | awk '{print $NF}'`
    oldRead=`cat ${statusFile}.old | grep -i -w 'innodb_buffer_pool_reads' | awk '{print $NF}'`
    newRequests=`cat ${statusFile} | grep -i -w 'innodb_buffer_pool_read_requests' | awk '{print $NF}'`
    oldRequests=`cat ${statusFile}.old | grep -i -w 'innodb_buffer_pool_read_requests' | awk '{print $NF}'`
    if [ "${newRequests}" = "${oldRequests}" ]; then        #无请求则认为命中为100%
            poolHits=100
    else
            poolHits=`echo "${newRead} ${oldRead} ${newRequests} ${oldRequests}" | awk '{print (1-(($1-$2)/($3-$4)))*100}'`
    fi
    echo ${poolHits}
}

case $2 in 
    Com_Update) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Com_update"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_Select) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Com_select"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_Rollback) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Com_rollback"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Questions) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 status|cut -f4 -d":"|cut -f1 -d"S"` 
        echo $result 
        ;; 
    Com_Insert) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Com_insert"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_Delete) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Com_delete"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_Commit) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Com_commit"|cut -d"|" -f3` 
        echo $result 
        ;; 
    rows_insert)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select VARIABLE_NAME,VARIABLE_VALUE from information_schema.global_status where VARIABLE_NAME='INNODB_ROWS_INSERTED';"|awk '{print $2}'`
        echo $result
        ;;
    rows_delete)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select VARIABLE_NAME,VARIABLE_VALUE from information_schema.global_status where VARIABLE_NAME='INNODB_ROWS_DELETED';"|awk '{print $2}'`
        echo $result
        ;;
    rows_update)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select VARIABLE_NAME,VARIABLE_VALUE from information_schema.global_status where VARIABLE_NAME='INNODB_ROWS_UPDATED';"|awk '{print $2}'`
        echo $result
        ;;
    rows_read)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select VARIABLE_NAME,VARIABLE_VALUE from information_schema.global_status where VARIABLE_NAME='INNODB_ROWS_READ';"|awk '{print $2}'`
        echo $result
        ;;
    slow_query)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select VARIABLE_NAME,VARIABLE_VALUE from information_schema.global_status where VARIABLE_NAME='SLOW_QUERIES';"|awk '{print $2}'`
        echo $result
        ;;
    pool_hits)
       POOL_HITS $1
        ;;
    Bytes_Sent) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Bytes_sent" |cut -d"|" -f3` 
        echo $result 
        ;; 
    Bytes_Received) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Bytes_received" |cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_Begin) 
        result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1 extended-status |grep -w "Com_begin"|cut -d"|" -f3` 
        echo $result 
        ;; 
        MySQL_Alive)
                result=`mysqladmin --defaults-file=${MYSQL_PWD} -P $1  ping | grep -c alive`
        echo $result 
        ;;
    MySQL_Flush)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select count(1) from information_schema.processlist where state='Waiting for table flush';"`
        echo $result 
        ;;
    MySQL_DDL)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select count(1) from information_schema.processlist where state='Waiting for table metadata lock';"`
        echo $result
        ;;
    MySQL_Transaction)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -NB -e "select p.time  from information_schema.processlist p join information_schema.innodb_trx t  on p.id=t.trx_mysql_thread_id where p.command='Sleep' and p.time>1800 and t.trx_state='RUNNING';"|wc -l`
        echo $result
        ;;
#sladdve监控项
    IsSlave)
        result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -e "show slave status\G"|wc -l`
        echo $result
            ;;
    SlaveStatus)
                result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -e "show slave status\G" | grep -E "Slave_IO_Running:|Slave_SQL_Running:"|awk '{print $2}'|grep -c Yes`
            echo $result
                ;;
    SlaveDelay)
                result=`mysql --defaults-file=${MYSQL_PWD} -P $1 -e "show slave status\G" |grep Seconds_Behind_Maste| awk -F: '{print $2}'`
            echo $result
                ;;


    *) 
        echo "Usage:$0 Port [Options]
    Performance:  Com_Update|Com_Select|Com_Rollback|Questions|Com_Insert|Com_Delete|Com_Commit|Bytes_Sent|Bytes_Received|Com_Begin
    SQL:          MySQL_Alive|MySQL_Flush |MySQL_DDL
    Slave:        IsSlave |SlaveStatus |SlaveDelay
    "
    ;; 
esac

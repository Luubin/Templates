#!/bin/bash  
source /etc/profile
 
function active {  
        curl -s "http://127.0.0.1/status" | awk '/Active/ {print $3}'  
} 
 
function reading {  
        curl -s "http://127.0.0.1/status" | awk '/Readin/ {print $2}'  
} 
 
function writing {  
        curl -s "http://127.0.0.1/status" | awk '/Writing/ {print $4}'
} 
 
function waiting {  
        curl -s "http://127.0.0.1/status" | awk '/Waiting/ {print $6}'
} 
 
function accepts {  
        curl -s "http://127.0.0.1/status" | awk NR==3 | awk '{print $1}'
} 
 
function handled {  
        curl -s "http://127.0.0.1/status" | awk NR==3 | awk '{print $2}'
} 
function requests {  
        curl -s "http://127.0.0.1/status" | awk NR==3 | awk '{print $3}' 
} 
 
case "$1" in
active)
      active
      ;;
reading)
      reading
      ;;
writing)
      writing
      ;;
waiting)
      waiting
      ;;
accepts)
      accepts
      ;;
handled)
      handled
      ;;
requests)
      requests
      ;;
*)
     echo "usage: $0 {nginx_site_dicovery}"
           echo "usage: $0 {active [host] |reading [host] |writing [host] |waiting [host] |accepts [host] |handled [host] |requests [host]}"
    esac


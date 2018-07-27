#!/usr/bin/env python
#coding:UTF-8
import sys 
tcp_dict = {}
system = {'00':'ERROR_STATUS','01':'ESTABLISHED','02':'SYN_SENT','03':'SYN_RECV','04':'FIN_WAIT1','05':'FIN_WAIT2','06':'TIME_WAIT','07':'CLOSE','08':'CLOSE_WAIT','09':'LAST_ACK','0A':'LISTEN','0B':'CLOSING'}
def main(x):
    with open('/proc/net/tcp','rb') as file:
        for line in file:
            tcp_status = line.split()[3]
            if tcp_status in system:
                if system[tcp_status] in tcp_dict:
                    tcp_dict[system[tcp_status]] = tcp_dict.get(system[tcp_status],0) + 1 
                else:
                    tcp_dict[system[tcp_status]] = 1
    if x not in tcp_dict:
	print 0
    else:
        print tcp_dict[x]
main(sys.argv[1])

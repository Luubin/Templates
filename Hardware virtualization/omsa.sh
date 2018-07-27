echo
yum -y install srvadmin-all
echo
echo "Dell Server Administrator Install Complete!"
echo
echo "Disable Services Auto Start"
echo
/opt/dell/srvadmin/sbin/srvadmin-services.sh disable
echo
echo "Link the cli to bin directory"
echo
ln -s /opt/dell/srvadmin/sbin/omreport /usr/bin/omreport
ln -s /opt/dell/srvadmin/sbin/omconfig /usr/bin/omconfig
echo 
echo "Disable Web Interface"
echo
echo "/usr/bin/omconfig system webserver action=stop" >> /opt/dell/srvadmin/sbin/srvadmin-services.sh
echo
echo "Starting Dell IPMI Services..."
echo
/opt/dell/srvadmin/sbin/srvadmin-services.sh start
echo
echo "Dell OpenIPMI & Dell OpenManage Install Complete!"
echo
echo "Make Auto Start Monitoring Services"
echo "/opt/dell/srvadmin/sbin/srvadmin-services.sh start" >> /etc/rc.local

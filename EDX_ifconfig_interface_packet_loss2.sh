#!/usr/bin/ksh

#--- Assigning Global Variables ----------------------------------------
script_path=`dirname  "$0"`
logs_directory="${script_path}/Logs"
netstat_log_file="${logs_directory}/netstat.log"
log_file="${logs_directory}/ifconfig_interface_packet_loss.log"
failure_log_file="${logs_directory}/ifconfig_interface_failure.log"
email_subject="TCP packets dropped."
email_recepient="noreply@host.com"
hostname=`hostname`
set -A interfaces bond0 eth0 eth1 eth2 eth3 eth4 eth5 eth6 eth7 lo sit0

#--- Dropped Packet Comapare -------------------------------------------
function dropped_packet_compare {
iface="$1"
string="$2"

DATE=`date "+%m-%d-%Y %H:%M:%S"`

current_iface_count=`/sbin/ifconfig -a $iface | egrep "${string}" | awk '{print $4}' | cut -d":" -f2`
last_iface_count=`cat $log_file | egrep $iface | egrep "${string}" | tail -1 | awk '{print $7}' | cut -d":" -f2`

if [ $current_iface_count -gt $last_iface_count ]; then
 echo "FAILURE: TCP packets dropped for $hostname. Current packet dropped count > than 30 mins ago. ${iface}: $string dropped: $current_iface_count > $last_iface_count" | mailx -s "$email_subject" $email_recepient
 cat $log_file | egrep $iface | egrep "${string}" | tail -1 >>$failure_log_file
 iface_fail_record=`/sbin/ifconfig -a $iface | egrep "${string}" | sed 's/^  *//g'` 
 echo "$DATE $iface $iface_fail_record FAIL" >>$failure_log_file
 echo "$DATE****************************************************" >>$netstat_log_file
 netstat -an | egrep ^tcp >>$netstat_log_file
else
 echo "Do nothing."
fi

iface_record=`/sbin/ifconfig -a $iface | egrep "${string}" | sed 's/^  *//g'`
echo "$DATE $iface $iface_record" >>$log_file
}


#--- main --------------------------------------------------------------
###Received and transmitted packet drop capture

function main
{
RX_string="RX packets:"
TX_string="TX packets:"

for iface in ${interfaces[@]}; do
  dropped_packet_compare $iface "$RX_string"
  dropped_packet_compare $iface "$TX_string"
done
}

main

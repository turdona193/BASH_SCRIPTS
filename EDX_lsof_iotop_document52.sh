#!/bin/ksh
# #!/usr/bin/ksh

#--- Assigning Global Variables ----------------------------------------
date=$(date +%Y%m%d)
script_path=$(dirname  "$0")
logs_directory="${script_path}/Logs"
lsof_log_file="${logs_directory}/lsof.log.$date"
iotop_log_file="${logs_directory}/node1_iotop.log.$date"

#--- LSOF Logging ------------------------------------------------------

echo "***********************************************" >>$lsof_log_file
date >>$lsof_log_file
/usr/sbin/lsof |grep REG |grep documents52 |sort -ur -k7 >>$lsof_log_file

#--- IOTOP Logging -----------------------------------------------------
echo "***********************************************" >>$iotop_log_file
date >>$iotop_log_file
echo "Gisadmin" | sudo -S iotop -bot --iter=2 >>$iotop_log_file

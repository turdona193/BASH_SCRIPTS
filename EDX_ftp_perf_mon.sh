#!/bin/ksh
# #!/usr/bin/ksh

# --- Assign Variables for Processing -----------------------------------------
. EDX_ftp_perf_mon.properties

# --- Check if Process is already running -------------------------------------
ps -aef | egrep -v egrep | awk '$9 ~ /^'${ftp_script}'$/ {print $2}' | while read pid
do
  if [ $pid != $$ ]
  then
    datetime=`date +%Y-%m-%d-%-H:%M:%S`
    echo "${datetime}: Script $script_name already running. Exiting...">>$log_file
    exit 1
  fi
done

# --- ftp_timer ---------------------------------------------------------------
function ftp_timer {

ps=$1
ftp_port=$2
i=$3
j=$4

echo "*************************************************************">>$log_file
let count_ftp=1

while [ $count_ftp -lt 3 ]; do
  START_TIME_FTP=`date +%s`

#cannot indent due to file like command processing
$lftp -e "set cmd:fail-exit yes" ftp://$username:$password@$ps:$ftp_port<<FTP_EOF
set xfer:clobber yes
get FTPTEST_FILE_10MB
exit
FTP_EOF

  if [ $? = 1 ]; then
    datetime=`date +%Y-%m-%d-%-H:%M:%S`
    echo "$datetime FAILURE: Server-NODE$j-Internet-55W-PS$i-Up" \
    " $ps FTP $ftp_port. FTP failed to login or connect." >> $log_file
    exit 1
  else
    END_TIME_FTP=`date +%s`
    ELAPSED_TIME_FTP=`expr $END_TIME_FTP - $START_TIME_FTP`
    if [ $ELAPSED_TIME_FTP -gt $TIME_LIMIT_SECS ]; then
      datetime=`date +%Y-%m-%d-%-H:%M:%S`
      echo "$datetime FAILURE: Server-NODE$j-Internet-55W-PS$i-Up"\
          " $ps FTP $ftp_port. Slow FTP transfer greater than $TIME_LIMIT_SECS" \
          " seconds. FTP of 10 MB file took $ELAPSED_TIME_FTP seconds." >> $log_file
    else
      datetime=`date +%Y-%m-%d-%-H:%M:%S`
      echo "$datetime SUCCESS: Server-NODE$j-Internet-55W-PS$i-Up $ps FTP" \
          " $ftp_port. Normal FTP Transfer equal to or less than $TIME_LIMIT_SECS" \
          " seconds. FTP of 10 MB file took $ELAPSED_TIME_FTP seconds." >> $log_file
    fi
  fi
  let count_ftp=$count_ftp+1
done
}

# --- Execution logic for looping through adapters ----------------------------
function main()
{
let j=1
for ftp_port in ${ftp_ports}; do
  ftp_timer $ps $ftp_port 1 $j
  let j=$j+1
  if [ $j -eq 4 ]; then
    let j=1
  fi
done
}

main

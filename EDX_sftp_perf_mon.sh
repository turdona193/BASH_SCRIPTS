#!/bin/ksh
# #!/usr/bin/ksh

# --- Assign Variables for Processing -----------------------------------------
. EDX_sftp_perf_mon.properties

# --- Check if Process is already running -------------------------------------
ps -aef | egrep -v egrep | awk '$9 ~ /^'${sftp_script}'$/ {print $2}' | while read pid
do
 if [ $pid != $$ ]
 then
   datetime=`date +%Y-%m-%d-%-H:%M:%S`
   echo "${datetime}: Script $script_name already running. Exiting...">>$log_file
   exit 1
 fi
done

# --- SFTP Timer --------------------------------------------------------------
function sftp_timer {

ps=$1
sftp_port=$2
i=$3
j=$4

echo "*************************************************************">>$log_file

let count_sftp=1

while [ $count_sftp -lt 4 ]; do
  START_TIME_SFTP=`date +%s`

#cannot indent due to file like command processing
$lftp -e "set cmd:fail-exit yes" sftp://$username:$password@$ps:$sftp_port<<SFTP_EOF
set xfer:clobber yes
get FTPTEST_FILE_10MB
exit
SFTP_EOF

  if [ $? = 1 ]; then
    datetime=`date +%Y-%m-%d-%-H:%M:%S`
    echo "$datetime FAILURE: Server-NODE$j-Internet-55W-PS$i-Up"\
         " $ps SFTP $sftp_port. SFTP failed to login or connect." >> $log_file
    exit 1
  else
    END_TIME_SFTP=`date +%s`
    ELAPSED_TIME_SFTP=`expr $END_TIME_SFTP - $START_TIME_SFTP`
    if [ $ELAPSED_TIME_SFTP -gt $TIME_LIMIT_SECS ]; then
      datetime=`date +%Y-%m-%d-%-H:%M:%S`
      echo "$datetime FAILURE: Server-NODE$j-Internet-55W-PS$i-Up" \
          " $ps SFTP $sftp_port. Slow SFTP transfer greater than $TIME_LIMIT_SECS" \
          " seconds. SFTP of 10 MB file took $ELAPSED_TIME_SFTP seconds." >> $log_file
    else
      datetime=`date +%Y-%m-%d-%-H:%M:%S`
      echo "$datetime SUCCESS: Server-NODE$j-Internet-55W-PS$i-Up $ps SFTP"\
          " $sftp_port. Normal SFTP Transfer equal to or less than $TIME_LIMIT_SECS" \
          " seconds. SFTP of 10 MB file took $ELAPSED_TIME_SFTP seconds." >> $log_file
    fi
  fi
  let count_sftp=$count_sftp+1
done
}

# --- Execution logic for looping through adapters ----------------------------
function main()
{
let j=1
for sftp_port in ${sftp_ports}; do
  sftp_timer $ps $sftp_port 1 $j
  let j=$j+1
  if [ $j -eq 4 ]; then
    let j=1
  fi
done
}

main

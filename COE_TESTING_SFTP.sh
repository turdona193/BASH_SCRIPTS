#!/bin/bash

#######################################
#  [Nicholas Turdo]
#  Filename:
#    COE_TESTING_SFTP.sh
#  Description:
#    Process designed to take an input properties file and initiate
#    a SFTP connection per line in the properties file.
#  Globals:
#    VERSION
#    USAGE
#    SFTP_FUNC (Required): Determines function during SFTP Session ('put'/'get')
#    HOST_NAME (Required): Specifies host to connect to.
#    PORT      (Required): Specifies listening port at host.
#    USER      (Required): Username for Login.
#    PASSWORD  (Required): Password for Login.
#    FILENAME  (Required): File to interact with during 'SFTP_FUNC'
#    DIRECTORY (Optional): CD to directory during sftp session (defaults to '.')
#
#  Arguments:
#    properitesFile           Required argument, each line represents on
#                             SFTP session consisting of all connection
#                             information.
#  Options:
#    -h, --help               Prints out usage message.
#    -V, --version            Prints out Version Number.
#  Returns:
#    None
#######################################


VERSION=0.0.1
USAGE="
Usage: command [-h|--help] [-v|-version] properitesFile
Options:
    -h, --help               Prints out usage message.
    -v, --version            Prints out Version Number.

Parameter:
    properitesFile           Required argument, each line represents on
                             SFTP session consisting of all connection
                             information.

Properties File Configuration:
<SFTP_FUNC>,<HOST_NAME>,<PORT>,<USER>,<PASSWORD>,<FILENAME>,[DIRECTORY]

    SFTP_FUNC (Required): Determines function during SFTP Session ('put'/'get')
    HOST_NAME (Required): Specifies host to connect to.
    PORT      (Required): Specifies listening port at host.
    USER      (Required): Username for Login.
    PASSWORD  (Required): Password for Login.
    FILENAME  (Required): File to interact with during 'SFTP_FUNC'
    DIRECTORY (Optional): CD to directory during sftp session (defaults to '.')
"

# --- Options processing -------------------------------------------

if [ $# == 0 ] ; then
    echo "${USAGE}"
    exit 1;
fi

for arg in $@; do
  case $i in
    -v|--version)
      echo "${VERSION}"
      exit 0
    ;;
      -h|--help)
      echo "${USAGE}"
    exit 0
    ;;
  esac
done

# --- Lock Process -------------------------------------------------
function lock_process()
{
script_path=$(dirname  "$0")
script_name=$(basename "$0")
script_prefix=${script_name%.sh}
lock_file="${script_path}/Locks/${script_prefix}.lock"

if ( set -o noclobber; echo "$$" > "${lock_file}") 2> /dev/null; then
    echo "Lock Created: ${lock_file} now owned by $(cat ${lock_file})"
else
    echo "Lock Exists: ${lock_file} owned by $(cat ${lock_file})"
    exit 1
fi
trap 'rm -f "${lock_file}"; exit $?' SIGINT SIGTERM EXIT
}

# --- Unlock Process -----------------------------------------------
function release_process()
{
rm -f ${lock_file}
}

# --- SFTP ---------------------------------------------------------
function sftp()
{
start_timer=$(date +%s)

lftp -e "set cmd:fail-exit yes" sftp://${USER}:${PASSWORD}@${HOST_NAME}:${PORT}<<SFTP_END
set xfer:clobber yes
cd ${DIRECTORY}
${SFTP_FUNC} ${FILENAME}
exit
SFTP_END

SFTP_ExitCode=$?
end_timer=$(date +%s)
duration=$(( ${end_timer} - ${start_timer}))
datetime=$(date +%Y-%m-%d-%-H:%M:%S)

if [[ $SFTP_ExitCode != 0 ]]; then
    echo "${datetime}:FAILURE:${SFTP_FUNC}:${HOST_NAME}:${PORT}:$DIRECTORY:"\
          "${SFTP_FUNC} of ${FILENAME} failed in ${duration} seconds."
else
    echo "${datetime}:SUCCESS:${SFTP_FUNC}:${HOST_NAME}:${PORT}:$DIRECTORY:"\
         "${SFTP_FUNC} of ${FILENAME} passed in ${duration} seconds."
fi
}

# --- MAIN ---------------------------------------------------------
function main()
{
lock_process
IFS=, >> $1

while read -r SFTP_FUNC HOST_NAME PORT USER PASSWORD FILENAME DIRECTORY; 
do
if [[ ${SFTP_FUNC} != "#*" ]]; then
  if [[ $DIRECTORY = "" ]]; then
    $DIRECTORY = "."
  fi
  sftp
fi
done < $1

release_process
trap 'rm -f "${lock_file}"; exit $?' SIGINT SIGTERM EXIT
}

# --- Initiate Main Function ---------------------------------------
main $@

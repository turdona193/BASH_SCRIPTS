#!/bin/bash

#######################################
#  [Nicholas Turdo]
#  Filename:
#    COE_TESTING_InboundConnectivity.sh
#  Description:
#    Process designed to initiate connections to B2Bi communication
#    adapters. Communication
#  Globals:
#    VERSION
#    USAGE
#    PROPERTYFILE
#    VERBOSE
#    SILENT
#    PS_SERVERS               Specified in Properties File
#    FTP_PORTS                Specified in Properties File
#    FTPS_PORTS               Specified in Properties File
#    SFTP_PORTS               Specified in Properties File
#    HTTP_PORTS               Specified in Properties File
#    HTTPS_PORTS              Specified in Properties File
#    USERNAME                 Specified in Properties File
#    PASSWORD                 Specified in Properties File
#  Arguments:
#    protocol (optional):     Required argument, pass in each protocol that needs to be
#                             tested. If not entered, all protocols should be tested.
#  Options:
#    -h, --help               Prints out usage message.
#    -V, --version            Prints out Version Number.
#    -v, --verbose            Prints Verbose messages from Curl Command.
#    -s, --silent             Prints only pass fail logging lines.
#    -p=*, --propertyFile=*   Pass in optional
#  Returns:
#    None
#######################################

VERSION=0.0.1
USAGE="
Usage: command [-h|--help] [-v|--version] [-V|--verbose] [-s|--silent] [-p=*|--propertyFile=*][PROTOCOLS*]
Options:
    -h, --help                 Prints out usage message.
    -V, --version              Prints out Version Number.
    -v, --verbose              Prints Verbose messages from Curl Command.
    -s, --silent               Prints only pass fail logging lines.
    -p=*, --propertyFile=*     Pass in optional

Argument:
    protocol (optional):       Required argument, pass in each protocol that needs to be
                               tested. If not entered, all protocols should be tested.

Properties File Configuration:
    PS_SERVERS(array of str)   List of Perimeter servers to test against.
    FTP_PORTS:(array of num)   List of FTP ports to test against each PS.
    FTPS_PORTS:(array of num)  List of FTPS ports to test against each PS.
    SFTP_PORTS:(array of num)  List of SFTP ports to test against each PS.
    HTTP_PORTS:(array of num)  List of HTTP ports to test against each PS.
    HTTPS_PORTS:(array of num) List of HTTPS ports to test against each PS.
    USERNAME:(str)             Username for each protocol that requires one (FTP,FTPS,SFTP).
    PASSWORD:(str)             Password for specified user.
"

# --- Options processing -------------------------------------------

for arg in $@; do
  case ${arg} in
    -v|--version)
      echo "${VERSION}"
      exit 0
    ;;
    -h|--help)
      echo "${USAGE}"
      exit 0
    ;;
      -V|--verbose)
      VERBOSE=true
      shift
    ;;
      -s|--silent)
      SILENT=true
      shift
    ;;
      -p=*|--propertyFile=*)
      PROPERTYFILE="${arg#*=}"
      shift
    ;;
  esac
done
PROTOCOLS=$@

# --- Load Variables -----------------------------------------------

if [ -z "${PROPERTYFILE}" ] ; then
    PROPERTYFILE=COE_TESTING_InboundConnectivity.properties
fi

. $PROPERTYFILE

if [ -z "${PROTOCOLS}" ] ; then
    PROTOCOLS="ALL"
fi

if [ "${SILENT}" ] ; then
    s=" -s"
fi

if [ "${VERBOSE}" ] ; then
    v=" -v"
fi

lftp="lftp"
curl="curl${v}${s}"
date="$(date +%Y%m%d)"


# --- FTP ------------------------------------------------------------
function ftp_test()
{
for it_ps in $(seq 0 $(expr ${#PS_SERVERS[@]} - 1 ) ); do
  for it_port in $(seq 0 $(expr ${#FTP_PORTS[@]} - 1 ) ); do
        datetime="$(date +%Y-%m-%d-%-H-%M-%S)"
        ${curl} \
            ftp://$USERNAME:$PASSWORD@${PS_SERVERS[${it_ps}]}:${FTP_PORTS[${it_port}]} >> /dev/null
        if [ $? != 0 ]; then
            echo "${datetime}:FAILURE:FTP:${PS_SERVERS[${it_ps}]}:${FTP_PORTS[${it_port}]}:"\
                 "Server is not responding."
        else
            echo "${datetime}:SUCCESS:FTP:${PS_SERVERS[${it_ps}]}:${FTP_PORTS[${it_port}]}:"\
                 "Server is responding."
        fi
    done
done
}

# --- FTPS -----------------------------------------------------------
function ftps_test()
{
for it_ps in $(seq 0 $(expr ${#PS_SERVERS[@]} - 1 ) )
do
    for it_port in $(seq 0 $(expr ${#FTPS_PORTS[@]} - 1 ) )
    do
        datetime=`date +%Y-%m-%d-%-H-%M-%S`
        ${curl} -k --ftp-ssl-reqd \
            ftp://$USERNAME:$PASSWORD@${PS_SERVERS[${it_ps}]}:${FTPS_PORTS[${it_port}]} >> /dev/null
        if [ $? != 0 ]; then
            echo "${datetime}:FAILURE:FTPS:${PS_SERVERS[${it_ps}]}:${FTPS_PORTS[${it_port}]}:"\
                 "Server is not responding."
        else
            echo "${datetime}:SUCCESS:FTPS:${PS_SERVERS[${it_ps}]}:${FTPS_PORTS[${it_port}]}:"\
                 "Server is responding."
        fi
    done
done
}

# --- SFTP -----------------------------------------------------------
function sftp_test()
{
for it_ps in $(seq 0 $(expr ${#PS_SERVERS[@]} - 1 ) )
do
    for it_port in $(seq 0 $(expr ${#SFTP_PORTS[@]} - 1 ) )
    do
        datetime=`date +%Y-%m-%d-%-H-%M-%S`
${curl} -k sftp://$USERNAME:$PASSWORD@${PS_SERVERS[${it_ps}]}:${SFTP_PORTS[${it_port}]} >> /dev/null

    if [ $? != 0 ]; then
        echo "${datetime}:FAILURE:SFTP:${PS_SERVERS[${it_ps}]}:${SFTP_PORTS[${it_port}]}:"\
             "Server is not responding."
    else
        echo "${datetime}:SUCCESS:SFTP:${PS_SERVERS[${it_ps}]}:${SFTP_PORTS[${it_port}]}:"\
             "Server is responding."
    fi

    done
done
}

# --- HTTP -----------------------------------------------------------
function http_test()
{
for it_ps in $(seq 0 $(expr ${#PS_SERVERS[@]} - 1 ) )
do
    for it_port in $(seq 0 $(expr ${#HTTP_PORTS[@]} - 1 ) )
    do
        datetime=`date +%Y-%m-%d-%-H-%M-%S`
        ${curl} \
            http://${PS_SERVERS[${it_ps}]}:${HTTP_PORTS[${it_port}]}/mailbox >> /dev/null
        if [ $? != 0 ]; then
            echo "${datetime}:FAILURE:HTTP:${PS_SERVERS[${it_ps}]}:${HTTP_PORTS[${it_port}]}:"\
                 "Server is not responding."
        else
            echo "${datetime}:SUCCESS:HTTP:${PS_SERVERS[${it_ps}]}:${HTTP_PORTS[${it_port}]}:"\
                 "Server is responding."
        fi
    done
done
}

# --- HTTPS -----------------------------------------------------------
function https_test()
{
for it_ps in $(seq 0 $(expr ${#PS_SERVERS[@]} - 1 ) ); do
  for it_port in $(seq 0 $(expr ${#HTTPS_PORTS[@]} - 1 ) ); do
    datetime=`date +%Y-%m-%d-%-H-%M-%S`
      ${curl} -k \
        https://${PS_SERVERS[${it_ps}]}:${HTTPS_PORTS[${it_port}]}/mailbox >> /dev/null
      if [ $? != 0 ]; then
        echo "${datetime}:FAILURE:HTTP:${PS_SERVERS[${it_ps}]}:${HTTPS_PORTS[${it_port}]}:"\
             "Server is not responding."
      else
        echo "${datetime}:SUCCESS:HTTP:${PS_SERVERS[${it_ps}]}:${HTTPS_PORTS[${it_port}]}:"\
             "Server is responding."
      fi
  done
done
}

function main()
{
for i in $PROTOCOLS; do
  case $i in
    ALL)
      ftp_test
      ftps_test
      sftp_test
      http_test
      https_test
    ;;
    FTP|ftp)
      ftp_test
    ;;
    FTPS|ftps)
      ftps_test
    ;;
    SFTP|sftp)
      sftp_test
    ;;
    HTTP|http)
      http_test
    ;;
    HTTPS|https)
      https_test
    ;;
  esac
done
}

main

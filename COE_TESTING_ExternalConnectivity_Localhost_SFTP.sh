#!/bin/bash

#######################################
#  [Nicholas Turdo]
#  Filename:
#    COE_TESTING_ExternalConnectivity_Localhost_FTP.properties
#  Description:
#    Specify GLOBAL variables for COE_TESTING_ExternalConnectivity.sh.
#  Globals:
#    PS_SERVERS: (array of str) List of Perimeter servers to test against.
#    FTP_PORTS:  (array of num) List of FTP ports to test against each PS.
#    FTPS_PORTS: (array of num) List of FTPS ports to test against each PS.
#    SFTP_PORTS: (array of num) List of SFTP ports to test against each PS.
#    HTTP_PORTS: (array of num) List of HTTP ports to test against each PS.
#    HTTPS_PORTS:(array of num) List of HTTPS ports to test against each PS.
#    USERNAME:   (str)          Username for each protocol that requires one (FTP,FTPS,SFTP).
#    PASSWORD:   (str)          Password for specified user.
#  Arguments:
#    None
#  Options:
#    None
#  Returns:
#    None
#######################################

#### Test Values
PS_SERVERS=("localhost")
SFTP_PORTS=(31022 31122)
USERNAME="admin"    #Server username, replaced with admin as security precaution.
PASSWORD="password" #Server password, replaced with admin as security precaution.


#######################################
#  Version History:
#    Nicholas Turdo 0.0.1 - 2016-12-20
#      Initial Version of script.
#######################################

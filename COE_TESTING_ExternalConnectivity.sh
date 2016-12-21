#!/bin/sh

COE_TESTING_InboundConnectivity.sh -s -p=COE_TESTING_ExternalConnectivity_Localhost_FTP.properties FTP
COE_TESTING_InboundConnectivity.sh -s -p=COE_TESTING_ExternalConnectivity_Localhost_SFTP.properties SFTP

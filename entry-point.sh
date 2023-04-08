#!/bin/bash

openvpnBase=/usr/local/openvpn_as
openvpnScripts=${openvpnBase}/scripts
openvpnEtc=${openvpnBase}/etc
configDb=${openvpnEtc}/db/config.db
initFile=${openvpnBase}/openvpnas.init

if [ ! -f ${initFile} ]
then
  initLog=${openvpnBase}/init.log 
  echo "################################################################"
  echo "#                                                              #"
  echo "#              !! Re-Initializing configuration !!             #"
  echo "#                                                              #"
  echo "#          This can take several minutes, please wait...       #"
  echo "#                                                              #"
  echo "################################################################"
  echo "Log can be found at ${initLog}"

  # The init file exists so it's OK for force the init
  ${openvpnBase}/bin/ovpn-init --no_start --batch --no_private --force --local_auth >${initLog} 2>&1
  
  echo "################################################################"
  echo "#                                                              #"
  echo "#              !! Re-Initialization Complete !!                #"
  echo "#                                                              #"
  echo "################################################################"

  # Get the temp password from the log
  tempPassword=$(grep "pass =" ${initLog} | sed -E 's/.*"(.*?)".*/\1/')

  echo "################################################################"
  echo "#               *Temporary Credentials*                        #" 
  echo "################################################################"
  echo "User: openvpn"
  echo "Password: ${tempPassword}"

  # Create the init file so we know this has been initialized
  touch ${initFile}
fi


echo "################################################################"
echo "#             Starting OpenVPN Access Server                   #" 
echo "################################################################"
exec ${openvpnScripts}/openvpnas "$@"

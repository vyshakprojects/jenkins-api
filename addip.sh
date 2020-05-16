#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JENKINS_URL="http://192.168.10.20:8080"
JOB_PATH=test2/job/master

PRODUCT=$1
if [ -z "${PRODUCT}" ]; then
  echo "ERROR: Please provide the PRODUCT name "
  exit 1
fi

CRED_FILE=${SCRIPT_DIR}/my_creds.sh
if [[ -f ${CRED_FILE} ]] ; then
  if ! source ${CRED_FILE} > /dev/null 2>&1 ; then
    echo "Please check your jenkins credentials in ${CRED_FILE}"
    exit 2
  fi
else
  echo "ERROR: file not found ${CRED_FILE}"
  exit 3
fi

# Get current public IP address
echo "Getting your public IP..."
my_ip=$(curl -s https://api.ipify.org);
parameters="&IP=${my_ip}&PRODUCT=${PRODUCT}"
curl -X POST "${JENKINS_URL}/job/${JOB_PATH}/buildWithParameters?delay=0sec${parameters}" --user ${JENKINS_USER_NAME}:${JENKINS_TOKEN} 
# STATUS=`curl -X POST "${JENKINS_URL}/job/${JOB_PATH}/buildWithParameters?delay=0sec${parameters}" --user ${JENKINS_USER_NAME}:${JENKINS_TOKEN} -s -o /dev/null -w "%{http_code}"`
# if [ $STATUS -eq 201 ]; then
#    echo ">>>Request Successful"
# else
#    echo ">>>Request Failed"
#    exit 1
# fi

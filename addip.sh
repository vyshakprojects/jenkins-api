#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JENKINS_URL="http://192.168.10.20:8080"
JOB_PATH=test2/job/master

USAGE="$0  product_name
       eg: $0 engati
           $0 leadmi
           $0 automi"

PRODUCTS=("engati" "leadmi" "automi")
PRODUCT=$1

trigger() {
  # Get current public IP address
  echo "Getting your public IP..."
  my_ip=$(curl -s https://api.ipify.org);
  parameters="&IP=${my_ip}&PRODUCT=${PRODUCT}"

  STATUS=`curl -X POST "${JENKINS_URL}/job/${JOB_PATH}/buildWithParameters?delay=0sec${parameters}" --user ${JENKINS_USER_NAME}:${JENKINS_TOKEN} -s -o /dev/null -w "%{http_code}"`
  if [ $STATUS -eq 201 ]; then
     echo ">>>Request Successful"
     exit 0
  else
     echo ">>>Request Failed"
     echo ">>>${USAGE}"
     exit 1
  fi
}

if [ -z "${PRODUCT}" ]; then
  echo "ERROR: Please enter PRODUCT name"
  echo ">>>${USAGE}"
  exit 1
fi

JENKINS_CRED_FILE=${SCRIPT_DIR}/jenkins_creds.sh
if [[ -f ${JENKINS_CRED_FILE} ]] ; then
  if ! source ${JENKINS_CRED_FILE} > /dev/null 2>&1 ; then
    echo "Please check your jenkins credentials in ${JENKINS_CRED_FILE}"
    exit 2
  fi
else
  echo "ERROR: file not found ${JENKINS_CRED_FILE}"
  exit 3
fi

for PRODUCT_NAME in "${PRODUCTS[@]}"
do
   if [ "${PRODUCT}" == "${PRODUCT_NAME}" ]; then
     trigger
   fi
done

echo "ERROR: Please enter a valid PRODUCT name"
echo ">>>${USAGE}"
exit 1

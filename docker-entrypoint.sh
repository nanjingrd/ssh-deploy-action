#!/bin/sh
set -ex

echo "#################################run in target host  #################################"
export uuid=$(uuidgen |sed 's/-//g')
#export COMMAND=$(echo "{ ${COMMAND}  } > 2>&1 | tee /tmp/remote-${uuid}.txt" | envsubst)
#echo "${COMMAND}"
echo "${COMMAND}" | envsubst >> /tmp/remotescript-${uuid}.sh
chmod +x /tmp/remotescript-${uuid}.sh
cat /tmp/remotescript-${uuid}.sh

sleep 1

echo "${ID_RSA_P}" | base64 -d > ./ssh_id_rsa
chmod 400 ./ssh_id_rsa


sleep 3
ssh  -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${JUMP_USER}@${JUMP_HOST} tail "-f /dev/null"

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i ./ssh_id_rsa -F /dev/null /tmp/remotescript-${uuid}.sh daqian@127.0.0.1:/tmp/github-aciton-${uuid}.sh
ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "chmod +x /tmp/github-aciton-${uuid}.sh" || true


ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "/tmp/github-aciton-${uuid}.sh  2>&1 | tee /tmp/remote-${uuid}.log" 

export returnCode=`ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null daqian@127.0.0.1 "echo $?"`

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i ./ssh_id_rsa -F /dev/null daqian@127.0.0.1:/tmp/remote-${uuid}.log /tmp/remote-${uuid}.log

ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "rm -rf /tmp/remote-${uuid}.log" || true
ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "rm -rf /tmp/github-aciton-${uuid}.sh" || true

cat /tmp/remote-${uuid}.log

export runlog=`cat /tmp/remote-${uuid}.log`

echo "::set-output name=runlog::$runlog"
echo "::set-output name=returnCode::$returnCode"

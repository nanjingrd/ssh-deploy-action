#!/bin/sh
set -ex

echo "#################################run in target host  #################################"
export uuid=$(uuidgen |sed 's/-//g')
#export COMMAND=$(echo "{ ${COMMAND}  } > 2>&1 | tee /tmp/remote-${uuid}.txt" | envsubst)
#echo "${COMMAND}"
echo "${COMMAND}" | envsubst >> /tmp/${uuid}_remotescript.sh
echo 'echo $? > '/tmp/${uuid}_remotescript_returncode.txt >> /tmp/${uuid}_remotescript.sh
chmod +x /tmp/${uuid}_remotescript.sh
cat /tmp/${uuid}_remotescript.sh

sleep 1

echo "${ID_RSA_P}" | base64 -d > ./ssh_id_rsa
chmod 400 ./ssh_id_rsa


sleep 3
ssh  -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${JUMP_USER}@${JUMP_HOST} tail "-f /dev/null"

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i ./ssh_id_rsa -F /dev/null /tmp/${uuid}_remotescript.sh daqian@127.0.0.1:/tmp/${uuid}-github-aciton.sh
ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "chmod +x /tmp/${uuid}-github-aciton.sh" || true


ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "/tmp/${uuid}-github-aciton.sh  2>&1 | tee /tmp/${uuid}-github-aciton.log" 

export returnCode=`ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null daqian@127.0.0.1 "cat /tmp/${uuid}_remotescript_returncode.txt"`

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i ./ssh_id_rsa -F /dev/null daqian@127.0.0.1:$/tmp/{uuid}-github-aciton.log /tmp/${uuid}-github-aciton.log

#ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "rm -rf /tmp/${uuid}*" || true

cat /tmp/${uuid}-github-aciton.log

export runlog=`cat /tmp/${uuid}-github-aciton.log`

echo "::set-output name=runlog::$runlog"
echo "::set-output name=returnCode::$returnCode"

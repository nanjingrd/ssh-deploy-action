#!/bin/sh
set -ex

echo "#################################run in target host  #################################"
export uuid=$(uuidgen |sed 's/-//g')
export COMMAND=$(echo "{ ${COMMAND}  } > 2>&1 | tee /tmp/remote-${uuid}.txt" | envsubst)
echo "${COMMAND}"

echo "${ID_RSA_P}" | base64 -d > ./ssh_id_rsa
chmod 400 ./ssh_id_rsa

sleep 3

ssh  -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${JUMP_USER}@${JUMP_HOST} tail "-f /dev/null"


ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "${COMMAND}" || true

ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "/tmp/remote-${uuid}.txt" | tee /tmp/local-log.txt

cat /tmp/local-log.txt

export runlog=`cat /tmp/local-log.txt`

echo "::set-output name=runlog::$runlog"

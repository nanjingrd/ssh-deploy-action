#!/bin/sh
set -x


export COMMAND=$(echo "${COMMAND}" | envsubst)
echo "${COMMAND}"

echo "${ID_RSA_P}" | base64 -d > ./ssh_id_rsa
chmod 400 ./ssh_id_rsa

sleep 3

ssh  -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${JUMP_USER}@${JUMP_HOST} tail "-f /dev/null"


ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "${COMMAND}" || true



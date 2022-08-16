#!/bin/sh
set -e

mkdir -p ~/.ssh/
mkdir -p /tmp/github_action
export uuid=$(uuidgen |sed 's/-//g')
#export COMMAND=$(echo "{ ${COMMAND}  } > 2>&1 | tee /tmp/remote-${uuid}.txt" | envsubst)
#echo "${COMMAND}"
echo "${COMMAND}" | envsubst >> /tmp/github_action/${uuid}_remotescript.sh
echo 'echo 0 > '/tmp/github_action/${uuid}_remotescript_returncode.txt >> /tmp/github_action/${uuid}_remotescript.sh
chmod +x /tmp/github_action/${uuid}_remotescript.sh
#cat /tmp/github_action/${uuid}_remotescript.sh

sleep 1

echo "${ID_RSA_P}" | base64 -d > /tmp/git_action_ssh_id_rsa
chmod 400 /tmp/git_action_ssh_id_rsa


sleep 3
ssh  -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${JUMP_USER}@${JUMP_HOST} tail "-f /dev/null"

ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "mkdir -p /tmp/github_action/"

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i /tmp/git_action_ssh_id_rsa -F /dev/null /tmp/github_action/${uuid}_remotescript.sh daqian@127.0.0.1:/tmp/github_action/${uuid}-github-aciton.sh

ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "chmod +x /tmp/github_action/${uuid}-github-aciton.sh" || true

export COMMAND="set -o pipefail; /tmp/github_action/${uuid}-github-aciton.sh  2>&1 | tee /tmp/github_action/${uuid}-github-aciton.log || echo \$? > /tmp/github_action/${uuid}_remotescript_returncode.txt "

echo "##########run in target host ##########"
ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "${COMMAND}" 

export returnCode=`ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null daqian@127.0.0.1 "cat /tmp/github_action/${uuid}_remotescript_returncode.txt"`

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i /tmp/git_action_ssh_id_rsa -F /dev/null daqian@127.0.0.1:/tmp/github_action/${uuid}-github-aciton.log /tmp/github_action/${uuid}-github-aciton.log

ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "rm -rf /tmp/github_action/${uuid}*" || true

echo "----run log start----"
cat /tmp/github_action/${uuid}-github-aciton.log
echo "----run log end----"

export runlog=`cat /tmp/github_action/${uuid}-github-aciton.log`

echo "::set-output name=runlog::$runlog"
echo "::set-output name=returnCode::$returnCode"

#!/bin/sh
set -ex

#export COMMAND=$(echo "{ ${COMMAND}  } > 2>&1 | tee /tmp/remote-${uuid}.txt" | envsubst)
#echo "${COMMAND}"
echo "${STAGE_COMMAND}" | envsubst >> /tmp/github_action/${stage}_remotescript.sh
echo 'echo 0 > '/tmp/github_action/${uuid}/${stage}_remotescript_returncode.txt >> /tmp/github_action/${stage}_remotescript.sh
chmod +x /tmp/github_action/${stage}_remotescript.sh
#cat /tmp/github_action/${uuid}/${stage}_remotescript.sh

sleep 2

ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "mkdir -p /tmp/github_action/${uuid}"

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i /tmp/git_action_ssh_id_rsa -F /dev/null /tmp/github_action/${stage}_remotescript.sh ${TARGET_USER}@127.0.0.1:/tmp/github_action/${uuid}/${stage}-github-aciton.sh

ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "chmod +x /tmp/github_action/${uuid}/${stage}-github-aciton.sh" || true

export COMMAND="set -o pipefail; /tmp/github_action/${uuid}/${stage}-github-aciton.sh  2>&1 | tee /tmp/github_action/${uuid}/${stage}-github-aciton.log || echo \$? > /tmp/github_action/${uuid}/${stage}_remotescript_returncode.txt "

echo "##########run in target host stage: ${stage}  ##########"
ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "${COMMAND}" 

export returnCode=`ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "cat /tmp/github_action/${uuid}/${stage}_remotescript_returncode.txt"`

echo $returnCode > /tmp/github_action/${stage}-github-aciton-code.txt

scp -P 2222 -o 'StrictHostKeyChecking=no' -o 'IdentitiesOnly=yes' -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1:/tmp/github_action/${uuid}/${stage}-github-aciton.log /tmp/github_action/${stage}-github-aciton.log






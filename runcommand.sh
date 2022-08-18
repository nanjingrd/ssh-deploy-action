#!/bin/sh
set -ex

#export COMMAND=$(echo "{ ${COMMAND}  } > 2>&1 | tee /tmp/remote-${uuid}.txt" | envsubst)
#echo "${COMMAND}"
echo "${STAGE_COMMAND}" | envsubst >> /tmp/github_action/${stage}_remotescript.sh
echo 'echo 0 > '/tmp/github_action/${uuid}/${stage}_remotescript_returncode.txt >> /tmp/github_action/${stage}_remotescript.sh
chmod +x /tmp/github_action/${stage}_remotescript.sh
#cat /tmp/github_action/${uuid}/${stage}_remotescript.sh

sleep 2

ssh  -p 2222 ${ssh_param} ${TARGET_USER}@127.0.0.1 "mkdir -p /tmp/github_action/${uuid}"

scp -P 2222 ${ssh_param} /tmp/github_action/${stage}_remotescript.sh ${TARGET_USER}@127.0.0.1:/tmp/github_action/${uuid}/${stage}-github-aciton.sh

ssh  -p 2222 ${ssh_param} ${TARGET_USER}@127.0.0.1 "chmod +x /tmp/github_action/${uuid}/${stage}-github-aciton.sh" || true

export COMMAND="set -o pipefail; /tmp/github_action/${uuid}/${stage}-github-aciton.sh  2>&1 | tee /tmp/github_action/${uuid}/${stage}-github-aciton.log || echo \$? > /tmp/github_action/${uuid}/${stage}_remotescript_returncode.txt "

echo "##########Run in target host stage: ${stage}  start ##########"
ssh  -p 2222 ${ssh_param} ${TARGET_USER}@127.0.0.1 "${COMMAND}" 
echo "##########Run in target host stage: ${stage}  end ##########"

export returnCode=`ssh  -p 2222 ${ssh_param} ${TARGET_USER}@127.0.0.1 "cat /tmp/github_action/${uuid}/${stage}_remotescript_returncode.txt"`

echo $returnCode > /tmp/github_action/${stage}-github-aciton-code.txt

scp -P 2222 ${ssh_param} ${TARGET_USER}@127.0.0.1:/tmp/github_action/${uuid}/${stage}-github-aciton.log /tmp/github_action/${stage}-github-aciton.log






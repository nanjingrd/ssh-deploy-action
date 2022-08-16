#!/bin/sh

export uuid=$(uuidgen |sed 's/-//g')
echo "uuid is "${uuid}

mkdir -p /root/.ssh
mkdir -p ~/root/.ssh
touch /root/.ssh/known_hosts

mkdir -p /tmp/github_action

echo "${ID_RSA_P}" | base64 -d > /tmp/git_action_ssh_id_rsa
chmod 400 /tmp/git_action_ssh_id_rsa

ssh  -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${JUMP_USER}@${JUMP_HOST} tail "-f /dev/null"
sleep 2

chmod +x /runcommand.sh

echo "------main stage------"
export stage=main
export STAGE_COMMAND="${COMMAND}"
/runcommand.sh || true
echo ">>>>>>main log start>>>>>>"
cat /tmp/github_action/${stage}-github-aciton.log
echo ">>>>>>main log end>>>>>>"
echo ""
echo ""
echo ""
echo "------post stage------"
export stage=post
export STAGE_COMMAND="${POSTCOMMAND}"
/runcommand.sh || true
echo ">>>>>>post log start>>>>>>"
cat /tmp/github_action/${stage}-github-aciton.log
echo ">>>>>>post log end>>>>>>"


export returnCode=`cat /tmp/github_action/main-github-aciton-code.txt`
export runlog=`cat /tmp/github_action/main-github-aciton.log`

#ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/git_action_ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 "rm -rf /tmp/github_action/${uuid}/*" || true

echo "::set-output name=runlog::$runlog"
echo "::set-output name=returnCode::$returnCode"
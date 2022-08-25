#!/bin/sh

mkdir -p /root/.ssh
mkdir -p ~/root/.ssh
touch /root/.ssh/known_hosts

if [ -z $TARGET_HOST ];then
	export TARGET_HOST=22
fi


if [ -z $TARGET_PORT ];then
	export TARGET_PORT=22
fi

if [ -z $TARGET_USER ];then
	export TARGET_USER=22
fi


###################

if [ -z $JUMP_HOST ];then
	export JUMP_HOST=22
fi

if [ -z $JUMP_PORT ];then
	export JUMP_PORT=22
fi


if [ -z $JUMP_USER ];then
	export JUMP_USER=22
fi

if [ -z $ACTION_DEBUG ];then
	echo " "
else
    echo "TARGET_HOST = $TARGET_HOST"
    echo "TARGET_PORT = $TARGET_PORT"
    echo "TARGET_USER = $TARGET_USER"

    echo "JUMP_HOST = $JUMP_HOST"
    echo "JUMP_PORT = $JUMP_PORT"
    echo "JUMP_USER = $JUMP_USER"
fi

########################

mkdir -p /tmp/github_action

echo "${TARGET_KEY}" | base64 -d > /tmp/target_key
echo "${JUMP_KEY}" | base64 -d > /tmp/jump_ssh_key
chmod 400 /tmp/target_key
chmod 400 /tmp/jump_ssh_key

ssh  -p ${JUMP_PORT} -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/jump_ssh_key -F /dev/null  -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${JUMP_USER}@${JUMP_HOST} tail "-f /dev/null"
export ssh_param=" -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i /tmp/target_key -F /dev/null "

#todo
#need keep ping to keep channel open  or using autossh
export uuid=$RANDOM
export startTime=`ssh  -p 2222 ${ssh_param}  ${TARGET_USER}@127.0.0.1   date +"%m-%d-%y_%H-%M-%S"  `
export uuid=${startTime}_${uuid}
echo "uuid is "${uuid}

sleep 2

chmod +x /runcommand.sh

echo "------main stage------"
export stage=main
export STAGE_COMMAND="${COMMAND}"
/runcommand.sh || true
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>main log start<<<<<<<<<<<<<<<<<<<<<<<<<<"
cat /tmp/github_action/${stage}-github-aciton.log
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>main log end<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo ""
echo ""
echo ""
echo "------post stage------"
export stage=post
export STAGE_COMMAND="${POSTCOMMAND}"
/runcommand.sh || true
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>post log start<<<<<<<<<<<<<<<<<<<<<<<<<<"
cat /tmp/github_action/${stage}-github-aciton.log
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>post log end<<<<<<<<<<<<<<<<<<<<<<<<<<"


export return_code=`cat /tmp/github_action/main-github-aciton-code.txt`
if [[ "${return_code}" -ne 0 ]]; then export ln="18"; else  export ln="6"; fi 
export run_log=`tail -n  $ln /tmp/github_action/main-github-aciton.log` 

run_log="${run_log//'%'/'%25'}"
run_log="${run_log//$'\n'/'%0A'}"
run_log="${run_log//$'\r'/'%0D'}"

#ssh  ${ssh_param}  ${TARGET_USER}@127.0.0.1 "rm -rf /tmp/github_action/${uuid}/*" || true

if [[ "${return_code}" -ne 0 ]]; then export succeed="false"; else  export  succeed="true"; fi 
if [[ "${return_code}" -ne 0 ]]; then export message="$git_source sync to $git_remote  Failed"; else  export  message="$git_source sync to $git_remote successed"; fi

echo "::set-output name=succeed::$succeed"
echo "::set-output name=message::$message"
echo "::set-output name=return_code::$return_code"
echo "::set-output name=run_log::$run_log"

exit $return_code
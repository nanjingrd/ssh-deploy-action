#!/bin/sh
set -x

execute_ssh(){
  echo "Execute Over SSH: $@"
  ssh -q -t -i "$HOME/.ssh/id_rsa" \
      -o UserKnownHostsFile=/dev/null \
      -p $INPUT_REMOTE_DOCKER_PORT \
      -o StrictHostKeyChecking=no "$INPUT_REMOTE_DOCKER_HOST" "$@"
}

# if [ -z "$INPUT_REMOTE_DOCKER_PORT" ]; then
#   INPUT_REMOTE_DOCKER_PORT=22
# fi

# if [ -z "$INPUT_REMOTE_DOCKER_HOST" ]; then
#     echo "Input remote_docker_host is required!"
#     exit 1
# fi

# if [ -z "$INPUT_SSH_PUBLIC_KEY" ]; then
#     echo "Input ssh_public_key is required!"
#     exit 1
# fi

# if [ -z "$INPUT_SSH_PRIVATE_KEY" ]; then
#     echo "Input ssh_private_key is required!"
#     exit 1
# fi

# if [ -z "$INPUT_ARGS" ]; then
#   echo "Input input_args is required!"
#   exit 1
# fi

# if [ -z "$INPUT_DEPLOY_PATH" ]; then
#   INPUT_DEPLOY_PATH=~/docker-deployment
# fi

# if [ -z "$INPUT_STACK_FILE_NAME" ]; then
#   INPUT_STACK_FILE_NAME=docker-compose.yaml
# fi

# if [ -z "$INPUT_KEEP_FILES" ]; then
#   INPUT_KEEP_FILES=4
# else
#   INPUT_KEEP_FILES=$((INPUT_KEEP_FILES+1))
# fi

# STACK_FILE=${INPUT_STACK_FILE_NAME}
# DEPLOYMENT_COMMAND_OPTIONS=""


# if [ "$INPUT_COPY_STACK_FILE" == "true" ]; then
#   STACK_FILE="$INPUT_DEPLOY_PATH/$STACK_FILE"
# else
#   DEPLOYMENT_COMMAND_OPTIONS=" --log-level debug --host ssh://$INPUT_REMOTE_DOCKER_HOST:$INPUT_REMOTE_DOCKER_PORT"
# fi

# case $INPUT_DEPLOYMENT_MODE in

#   docker-swarm)
#     DEPLOYMENT_COMMAND="docker $DEPLOYMENT_COMMAND_OPTIONS stack deploy --compose-file $STACK_FILE"
#   ;;

#   *)
#     INPUT_DEPLOYMENT_MODE="docker-compose"
#     DEPLOYMENT_COMMAND="docker-compose $DEPLOYMENT_COMMAND_OPTIONS -f $STACK_FILE"
#   ;;
# esac

echo date
echo "${ssh_private_key}" | base64 -d > ./ssh_id_rsa
chmod 400 ./ssh_id_rsa
echo "CI_PROJECT_NAME=""${CI_PROJECT_NAME}"
echo "CI_COMMIT_SHORT_SHA=""${CI_COMMIT_SHORT_SHA}"
echo "CI_COMMIT_REF_NAME=""${CI_COMMIT_REF_NAME}"
ssh  -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null -f  -L 0.0.0.0:2222:${TARGET_HOST}:${TARGET_PORT} ${REMOTE_USER}@${REMOTE_HOST} tail "-f /dev/null"
echo ${COMMAND}
ssh  -p 2222 -o  StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./ssh_id_rsa -F /dev/null ${TARGET_USER}@127.0.0.1 ${COMMAND} || true



source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i localhost, $VNF_TASKS/ping/main.yml | sudo tee $LOGS/ping_ansible_log.log

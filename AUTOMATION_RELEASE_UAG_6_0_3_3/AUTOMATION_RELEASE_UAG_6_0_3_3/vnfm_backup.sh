source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i localhost, $HT_TASKS/vnfm_backup.yml | sudo tee $LOGS/vnfm_backup.log

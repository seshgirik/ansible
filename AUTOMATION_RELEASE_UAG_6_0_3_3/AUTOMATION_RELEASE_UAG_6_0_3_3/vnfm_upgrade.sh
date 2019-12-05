source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i localhost, $HT_TASKS/vnfm_upgrade_main.yml | sudo tee $LOGS/vnfm_upgrade.log

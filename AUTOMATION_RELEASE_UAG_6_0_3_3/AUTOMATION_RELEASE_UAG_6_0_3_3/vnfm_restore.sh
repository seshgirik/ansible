source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i $HT_INV $HT_TASKS/vnfm_restore.yml | sudo tee $LOGS/vnfm_restore.log

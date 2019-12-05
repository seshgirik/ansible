source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i $HT_INV $HT_TASKS/crdl_main.yml | sudo tee $LOGS/crdl.log

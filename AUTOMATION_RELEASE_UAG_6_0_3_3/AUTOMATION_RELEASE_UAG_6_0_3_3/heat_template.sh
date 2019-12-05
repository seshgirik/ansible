source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i $HT_INV $HT_TASKS/main.yml | sudo tee $LOGS/heat_template.log

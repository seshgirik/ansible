source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i $VNF_INV $VNF_TASKS/deploy_new_nsd.yml | sudo tee $LOGS/deploy_new_nsd.log

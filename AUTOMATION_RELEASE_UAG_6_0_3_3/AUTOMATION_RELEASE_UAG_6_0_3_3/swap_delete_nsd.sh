source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i $VNF_INV $VNF_TASKS/swap_delete_nsd.yml | sudo tee $LOGS/delete_deployment.log

source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i $VNF_INV $VNF_TASKS/swap_deploy_nsd.yml | sudo tee $LOGS/deploy_1st_nsd.log

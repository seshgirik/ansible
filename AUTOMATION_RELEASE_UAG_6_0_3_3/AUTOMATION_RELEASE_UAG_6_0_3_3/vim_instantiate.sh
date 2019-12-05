source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i $VNF_INV $VNF_TASKS/main_1.yml | sudo tee $LOGS/vnf_instantiate.log

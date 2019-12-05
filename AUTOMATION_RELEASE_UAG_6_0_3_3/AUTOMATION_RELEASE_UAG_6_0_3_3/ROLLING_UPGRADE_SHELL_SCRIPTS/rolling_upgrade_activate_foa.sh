source ../COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i ../$VNF_INV ../$VNF_TASKS/rolling_upgrade_activate_foa.yml | sudo tee ../$LOGS/vnfd_rolling_upgrade_actiave_foa.log

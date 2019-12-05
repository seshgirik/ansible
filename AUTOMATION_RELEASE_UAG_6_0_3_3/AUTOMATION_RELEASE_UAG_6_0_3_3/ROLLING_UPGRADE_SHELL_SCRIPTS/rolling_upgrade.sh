source ../COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i ../$VNF_INV ../$VNF_TASKS/rolling_upgrade_pre_prod.yml | sudo tee ../$LOGS/vnfd_rolling_upgrade.log

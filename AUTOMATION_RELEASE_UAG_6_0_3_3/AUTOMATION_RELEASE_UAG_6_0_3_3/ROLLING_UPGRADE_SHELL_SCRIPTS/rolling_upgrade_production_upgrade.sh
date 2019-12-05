source ../COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i ../$VNF_INV ../$VNF_TASKS/rolling_upgrade_production_upgrade.yml | sudo tee ../$LOGS/vnfd_rolling_upgrade_production_upgrade.log

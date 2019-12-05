source ./COMMON_SOURCE/common.sh
$ANSIBLE_CMD -i localhost, $HT_TASKS/CMS_DB_UPGRADE/CMS_DB_Upgrade_Main.yml | sudo tee $LOGS/cms_upgrade.log

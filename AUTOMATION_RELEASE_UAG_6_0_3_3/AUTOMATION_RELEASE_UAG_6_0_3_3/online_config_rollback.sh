source ./COMMON_SOURCE/common.sh
# inv_ip=`cat $VNF_VARS/online_config.yml | grep CMS_IP_ADDR | cut -d":" -f2 | cut -d'"' -f2`
# printf "[cms]\n$inv_ip" >  $VNF_INV
$ANSIBLE_CMD -i $VNF_INV $VNF_TASKS/Online_Config_Rollback.yml | sudo tee $LOGS/online_config_rollback.log

source ./COMMON_SOURCE/common.sh
source ./COMMON_SOURCE/online_config_requirements.sh
# inv_ip=`cat $VNF_VARS/online_config.yml | grep CMS_IP_ADDR | cut -d":" -f2 | cut -d'"' -f2`
# printf "[cms]\n$inv_ip" >  $VNF_INV
$ANSIBLE_CMD -i $VNF_INV $VNF_TASKS/Online_Config.yml | sudo tee $LOGS/online_config.log

source ./COMMON_SOURCE/common.sh
source ./COMMON_SOURCE/os_install_requirements.sh
become_pass=`grep WRPASS $OS_VARS/config.yml | cut -d":" -f2 | awk '{$1=$1};1'`
sudo $ANSIBLE_CMD -i $OS_INV $OS_TASKS/main.yml --extra-vars="ansible_become_pass=$become_pass" | sudo tee $LOGS/dell_install_os.log

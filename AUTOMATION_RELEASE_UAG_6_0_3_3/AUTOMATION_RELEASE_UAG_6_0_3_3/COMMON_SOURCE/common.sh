PKG_OK=$(dpkg-query -W --showformat='${Status}\n' openssh-server|grep "install ok installed")
echo Checking for openssh-server: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "No openssh-server found. Setting up openssh-server"
  sudo apt-get --force-yes --yes install openssh-server
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' python-pip|grep "install ok installed")
echo Checking for python-pip: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "python-pip not found. Installing python-pip"
  sudo apt-get --force-yes --yes install python-pip
fi
echo "Checking for lxml"
lxml_present=$(pip freeze | grep lxml)
if [ "" == "$lxml_present" ]; then
  echo "lxml not found. Installing lxml"
  sudo apt-get install libxml2-dev libxslt1-dev python-dev
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ansible|grep "install ok installed")
echo Checking for ansible: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "Ansible not found. Installing ansible"
  sudo dpkg -i ./COMMON_SOURCE/ansible.deb
fi

echo "Setting up passwordless login for localhost"
if [ -e ~/.ssh/id_rsa.pub ]
then
    echo "ssh public key exists"
else
    echo "ssh public key does not exist"
    ssh-keygen
fi
ssh-copy-id localhost -o StrictHostKeyChecking=no

OS_FILES="./ANSIBLE/files/dell_os_installation"
HT_FILES="./ANSIBLE/files/heat_templates"
VNF_FILES="./ANSIBLE/files/vnf_instantiation/Deployment_Folder/VNFM_DEPLOYABLE"

OS_VARS="./ANSIBLE/vars/dell_os_installation"
HT_VARS="./ANSIBLE/vars/heat_templates"
VNF_VARS="./ANSIBLE/vars/vnf_instantiation"

OS_INV="./ANSIBLE/inventory/dell_os_installation/inventory.txt"
HT_INV="./ANSIBLE/inventory/heat_templates/inventory.txt"
VNF_INV="./ANSIBLE/inventory/vnf_instantiation/inventory.txt"

OS_TASKS="./ANSIBLE/tasks/dell_os_installation"
HT_TASKS="./ANSIBLE/tasks/heat_templates"
VNF_TASKS="./ANSIBLE/tasks/vnf_instantiation"

LOGS="./LOGS"
ANSIBLE_CMD="ansible-playbook -vvv"

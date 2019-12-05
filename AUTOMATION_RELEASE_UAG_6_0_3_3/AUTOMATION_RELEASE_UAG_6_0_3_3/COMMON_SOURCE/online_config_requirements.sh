PKG_OK=$(dpkg-query -W --showformat='${Status}\n' python-pip|grep "install ok installed")
echo Checking for python-pip: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "python-pip not found. Installing python-pip"
  sudo apt-get --force-yes --yes install python-pip
fi
echo "Checking for openpyxl"
vdtool_present=$(pip freeze | grep openpyxl)
if [ "" == "$vdtool_present" ]; then
  echo "openpyxl not found. Installing openpyxl"
  sudo pip install openpyxl==2.5.3
fi

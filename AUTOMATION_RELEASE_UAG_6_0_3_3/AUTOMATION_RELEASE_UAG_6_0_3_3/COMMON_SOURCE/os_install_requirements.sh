PKG_OK=$(dpkg-query -W --showformat='${Status}\n' python-pip|grep "install ok installed")
echo Checking for python-pip: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "python-pip not found. Installing python-pip"
  sudo apt-get --force-yes --yes install python-pip
fi
echo "Checking for vncdotool"
vdtool_present=$(pip freeze vncdotool | grep vncdotool)
if [ "" == "$vdtool_present" ]; then
  echo "vncdotool not found. Installing vncdotool"
  sudo pip install vncdotool==0.10.0
fi

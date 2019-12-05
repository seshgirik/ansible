#!/bin/bash
timestamp=`date +%Y%m%d%H%M%S`
exec > /root/`basename $0`.${timestamp}.log 2>&1
set -x
vmtype=$1
nodename=$2
baseip=$3
fabricip=$4

nodefqdn="${nodename}.mavenir1.com"

shelf=`echo $nodename | awk -F"-" '{print $1}'`
slot=`echo $nodename | awk -F"-" '{print $2}'`

if [ $slot = "9" ];then
	nodename2="0-10"
elif [ $slot = "10" ];then
	nodename2="0-9"
else	
	nodename2=""
fi

node2fqdn="${nodename2}.mavenir1.com"

### Updating /etc/shelf.cfg 

sed -i "s/shelf .*/shelf $shelf/g" /etc/shelf.cfg
sed -i "s/slot .*/slot $slot/g" /etc/shelf.cfg

if [ $slot = "9" ] || [ $slot = "10" ];then
	### Updating /etc/ha.d/ha.cf and /etc/ha.d/haresources
	sed -i "s/ucast bond0 .*/ucast bond0 $node2fqdn/g" /etc/ha.d/ha.cf
	#sed -i "s/.*.mavenir1.com/$nodefqdn/g" /etc/ha.d/haresources

	### Updating /etc/dhcp/dhcpd.conf

	sed -i "s/    server-name .*/    server-name                    \"$nodefqdn\";/g" /etc/dhcp/dhcpd.conf

    sed -i 's|^TOOLS_RM=.*|TOOLS_RM=\"script\"|g'  /usr/IMS/exports/blade.cfg
    #sed -i 's|^SI=.*|SI=\"0-13,0-14\"|g'  /usr/IMS/exports/blade.cfg
    #sed -i 's|^MP=.*|MP=\"0-23,0-24\"|g'  /usr/IMS/exports/blade.cfg
    

	### Updating zone files -> following line has ISSUSE
	#grep -rl "0-9" /var/named | xargs sed -i "s|0-9|$nodename|g"
    sed -i '/USERCTL=.*/a MTU=1496' /etc/sysconfig/network-scripts/ifcfg-eth0
    sed -i '/USERCTL=.*/a MTU=1496' /etc/sysconfig/network-scripts/ifcfg-eth1
    sed -i '/USERCTL=.*/a MTU=1496' /etc/sysconfig/network-scripts/ifcfg-bond0
    sed -i '/USERCTL=.*/a MTU=1496' /etc/sysconfig/network-scripts/ifcfg-bond1
    mybonds="bond1.1 bond1.2 bond1.3 bond1.4 bond1.8"
    for i in $mybonds
    do
        ifdown $i
        rm -f /etc/sysconfig/network-scripts/ifcfg-$i 
    done

    if [ $slot = "10" ];then
        # master and slave should have different server-ids
        sed -i "s/^server-id.*/server-id = 2/" /etc/my.cnf
    fi

else

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << "REOF"
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
USERCTL=no
MTU=1496
REOF
cat > /etc/sysconfig/network-scripts/ifcfg-eth1 << "REOF"
DEVICE=eth1
BOOTPROTO=none
ONBOOT=yes
MASTER=bond1
SLAVE=yes
USERCTL=no
MTU=1496
REOF
cat > /etc/sysconfig/network-scripts/ifcfg-bond0 << "REOF"
DEVICE=bond0
IPADDR=172.16.33.29
NETMASK=255.255.255.0
NETWORK=172.16.33.0
BROADCAST=172.16.33.255
ONBOOT=yes
BOOTPROTO=static
USERCTL=no
MTU=1496
#BONDING_OPTS="miimon=100, mode=1"
REOF
cat > /etc/sysconfig/network-scripts/ifcfg-bond1 << "REOF"
DEVICE=bond1
IPADDR=172.16.73.29
NETMASK=255.255.255.0
NETWORK=172.16.73.0
BROADCAST=172.16.73.255
ONBOOT=yes
BOOTPROTO=static
USERCTL=no
MTU=1496
#BONDING_OPTS="miimon=100, mode=1"
REOF

cat > /etc/mavenir/ramrc << "REOF"
POSITION=0-1
HOSTIP=172.16.33.29
HAIP=172.16.33.3
PRODUCT=IMS
REOF

fi

### Updating /etc/sysconfig/network
sed -i "s/HOSTNAME=.*/HOSTNAME=$nodefqdn/g" /etc/sysconfig/network

### Updating Hostname
/usr/bin/hostnamectl set-hostname  $nodefqdn

case $nodename in

        "0-9")  echo "By default AMD is ADM-A"
                rm -f /etc/sysconfig/network-scripts/ifcfg-eth4 
                ;;
        "0-10") 
                sed -i "s|IPADDR=.*|IPADDR=$baseip|g" /etc/sysconfig/network-scripts/ifcfg-bond0
                sed -i "s|IPADDR=.*|IPADDR=$fabricip|g" /etc/sysconfig/network-scripts/ifcfg-bond1
                service network restart
                ;;
          *)
	            sed -i "s/VMNAME=.*/VMNAME=$nodename/g" /etc/mavenir/postdeploy.cfg
	            sed -i "s/VMTYPE=.*/VMTYPE=$vmtype/g" /etc/mavenir/postdeploy.cfg
                sed -i "s|POSITION=.*|POSITION=$nodename|g" /etc/mavenir/ramrc
                sed -i "s|HOSTIP=.*|HOSTIP=$baseip|g" /etc/mavenir/ramrc
                sed -i "s|IPADDR=.*|IPADDR=$baseip|g" /etc/sysconfig/network-scripts/ifcfg-bond0
                sed -i "s|IPADDR=.*|IPADDR=$fabricip|g" /etc/sysconfig/network-scripts/ifcfg-bond1
                ifup eth1
                ifdown eth2
                service network restart
 	      		if ! grep -q "/RAM_setup\.sh" /etc/rc.d/rc.local
                then
                     cat >> /etc/rc.d/rc.local << "REOF"
if ! grep -i ramlinux /proc/cmdline >/dev/null; then
    /etc/mavenir/RAM_setup.sh
fi
REOF
                fi

                /etc/mavenir/RAM_setup.sh
               
		;;

esac



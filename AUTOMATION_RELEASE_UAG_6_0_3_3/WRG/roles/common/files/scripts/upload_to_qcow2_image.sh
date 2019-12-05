#!/bin/bash
#set -x
timestamp=`date +%Y%m%d%H%M%S`
#exec > /tmp/`basename $0`.${timestamp}.log 2>&1

typeset -i args=$#
if [ $args -lt 2 -o $args -gt 3 ]; 
then
  echo "usage: $0 <qcow2_image_file> <patch_file> <destination_path>"
  exit 1
fi

qcow2_image_location=$1
patch_filename=$2

if [ ! -z $3 ];
then
  destination_path=$3
else
  destination_path="/home/"
fi

if [[ $destination_path == *"/usr/IMS"* ]];then

    destination_path=${destination_path/usr/data}
fi

mount_path="/tmp/qcow2_mount_path"
/usr/bin/mkdir -p $mount_path

/usr/bin/guestmount --ro -o nonempty -a $qcow2_image_location -i $mount_path

patch_filename_md5sum=$(md5sum $patch_filename | awk '{print $1}' | tr -d ' ')
patch_file_basename=$(basename $patch_filename)
file_in_qcow2_image_md5sum=$(md5sum "$mount_path/$destination_path/$patch_file_basename" | awk '{print $1}' | tr -d ' ')

if [ "$patch_filename_md5sum" = "$file_in_qcow2_image_md5sum" ]
then
   return_value=2
else
   /usr/bin/guestunmount $mount_path
   /usr/bin/guestmount -o nonempty -a $qcow2_image_location -i $mount_path
   if [ `basename $patch_filename` = "blade.cfg" ];then
       /usr/bin/cp -f $mount_path/$destination_path/blade.cfg $mount_path/$destination_path/blade.cfg.backup
   fi
   /usr/bin/cp $patch_filename $mount_path/$destination_path
   return_value=$?
   if [ $return_value == 2 ]
   then
       return_value=3
   fi
 
fi

/usr/bin/guestunmount $mount_path
#/usr/bin/rm -rf $mount_path
exit $return_value


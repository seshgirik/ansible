#!/bin/bash
set -x

timestamp=`date +%Y%m%d%H%M%S`
#exec > /tmp/`basename $0`.${timestamp}.log 2>&1

host_temp_location=$1
credentials_rc=$2
image_filenanme=$3
#vnf_image_name=$4

function is_image_exist_in_glance()
{
   image=$glance_image_name
#   if /usr/bin/glance image-list | grep $glance_image_name > /dev/null
   if /usr/bin/openstack image list | grep $glance_image_name > /dev/null
   then
       #image_details=$(echo `/usr/bin/glance image-list | grep $glance_image_name`) 
       image_details=$(echo `/usr/bin/openstack image list | grep $glance_image_name`) 
       glance_image_id=$(echo $image_details | awk -F"|" '{print $2}' | head -1 | tr -d '[:space:]')
       #glance_image_checksum=`/usr/bin/glance image-show $glance_image_id | grep checksum | awk -F"|" '{print $3}' | tr -d '[:space:]'`
       glance_image_checksum=`/usr/bin/openstack image show  $glance_image_id -c checksum  -f value`
       qcow2_file_checksum=`/usr/bin/md5sum $host_temp_location/$image_filenanme | awk '{print $1}' | tr -d '[:space:]'`
       if [ $glance_image_checksum == $qcow2_file_checksum ]
       then 
           return 0
       fi
   fi
   return 1
}



glance_image_name=$(echo $image_filenanme | sed 's/\.qcow2$//')
source $host_temp_location/$credentials_rc
is_image_exist_in_glance 
return_value=$?
if  [ $return_value == 1 ]
then
#   /usr/bin/glance image-create             \
#           --name $glance_image_name     \
#           --disk-format=qcow2           \
#           --container-format=bare       \
#           --visibility=private          \
#           --protected=False             \
#           --file $host_temp_location/$image_filenanme

    /usr/bin/openstack image create \
            --disk-format qcow2     \
            --container-format bare \
            --private \
            --unprotected \
            --file $host_temp_location/$image_filenanme \
            $glance_image_name

   retval=$?
   if [ $retval == 2 ]
   then
       exit 3
   fi
else
   exit 2
fi


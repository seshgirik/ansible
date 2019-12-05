#!/bin/bash
#set -x

timestamp=`date +%Y%m%d%H%M%S`
#exec > /var/log/`basename $0`.${timestamp}.log 2>&1

template_location=$1
template_filenanme=$2
template_env_filename=$3
credentials_rc=$4
#vnfm_public_net_id=$5
#vnfm_ip_address=$6
image_filename=$5

image_parameter_name=`grep image_name $template_location/$template_env_filename | grep -v ^[[:space:]]*# | awk -F":" '{print $1}'`
#glance_image_name=`grep image_name $template_location/$template_env_filename | grep -v ^# | awk -F":" '{print $2}'`
if [ ! -z "$image_parameter_name" ]
then
	glance_image_name=$(echo $image_filename | sed 's/\.qcow2$//')
	sed -i -e "s/\($image_parameter_name\).*/\1\: $glance_image_name/" $template_location/$template_env_filename
fi

stack_name=$(echo $template_env_filename | sed 's/\.env$/_stack/')
source $template_location/$credentials_rc


#stack_state=`heat stack-list | grep "$stack_name" | awk -F"|" '{print $4}' | tr -d '[[:space:]]'`
stack_state=`/usr/bin/openstack stack show $stack_name -c stack_status -f value`
if [ "$stack_state" = "CREATE_COMPLETE" ];then
    exit 2
elif [ "$stack_state" = "CREATE_FAILED" ];then
    echo "ERROR: cleanup previous stack failures"
    exit 1
fi

sleep 2

#/usr/bin/heat stack-create       \
#          --template-file $template_location/$template_filenanme  \
#          --environment-file $template_location/$template_env_filename  \
#          $stack_name 

/usr/bin/openstack stack create  \
           -t $template_location/$template_filenanme \
           -e $template_location/$template_env_filename \
           -c stack_status \
           -f yaml    \
           --wait --timeout 60 \
            $stack_name

if [ $? -ne 0 ];then
        echo "ERROR: Stack creation failed. Check log file /var/log/heat/heat-engine.log"
        exit 1
fi

stack_state=`/usr/bin/openstack stack show $stack_name -c stack_status -f value`
if [ "$stack_state" = "CREATE_COMPLETE" ];then
    exit 0
else
    echo "ERROR: Stack creation failed. Check log file /var/log/heat/heat-engine.log"
    exit 1
fi


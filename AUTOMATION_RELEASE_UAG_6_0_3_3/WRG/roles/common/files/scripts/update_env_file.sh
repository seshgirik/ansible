#!/bin/bash
#set -x

timestamp=`date +%Y%m%d%H%M%S`
#exec > /var/log/`basename $0`.${timestamp}.log 2>&1

template_location=$1
template_env_filename=$2
common_env_filename=$3

$template_location/update_env.py $template_location/$template_env_filename $template_location/$common_env_filename

if [ $? -ne 0 ];then
        echo "ERROR: Internal Error" 
        exit 1
fi



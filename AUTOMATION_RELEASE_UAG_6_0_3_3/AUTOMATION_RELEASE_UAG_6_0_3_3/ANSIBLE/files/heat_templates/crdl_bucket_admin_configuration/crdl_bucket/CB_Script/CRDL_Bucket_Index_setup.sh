#! /bin/sh
#set -xv
#########################################################
#########################################################
#ScriptName=CRDL_Bucket_Index_setup.sh                  #
#Version=1.0											#
#########################################################
#########################################################

scriptPath=`dirname $0`
[ $scriptPath = "." ] && scriptPath=`pwd`
echo $PATH|grep -v $scriptPath > /dev/null && export PATH=$PATH:$scriptPath
COUCBASE_VERSION=`/opt/couchbase/bin/couchbase-server --version | awk '{print $3}' | grep "^5" | wc -l`

createBucket ()
{
logBucket "Creating Bucket $CRDL_BUCKET_NAME"
if [ $CRDL_TOTAL_NODES -gt 1 ]; then

        logBucket "$CRDL_BUCKET_NAME bucket will be created with replication enabled & number of replica copy is 1"
        bucket_crete=`curl -u $CRDL_USER_NAME:$CRDL_USER_PASSWD -v -X POST http://${TRAFFIC[0]}:8091/pools/default/buckets -d "flushEnabled=0&threadsNumber=3&replicaIndex=0&replicaNumber=1&evictionPolicy=valueOnly&ramQuotaMB=$CRDL_BUCKET_RAMQUOTA&bucketType=couchbase&name=$CRDL_BUCKET_NAME&authType=sasl&saslPassword=$CRDL_USER_PASSWD&conflictResolutionType=lww" | grep "\"errors\"" | wc -l`
        [ `echo $bucket_crete` -ne 0 ] && logBucket "Bucket creation failed. Please check. Exitting!!" && exit
    else
        logBucket "$CRDL_BUCKET_NAME bucket will be created with replication disabled as its a single node cluster"
        bucket_crete=`curl -u $CRDL_USER_NAME:$CRDL_USER_PASSWD -v -X POST http://${TRAFFIC[0]}:8091/pools/default/buckets -d "flushEnabled=0&threadsNumber=3&replicaIndex=0&replicaNumber=0&evictionPolicy=valueOnly&ramQuotaMB=$CRDL_BUCKET_RAMQUOTA&bucketType=couchbase&name=$CRDL_BUCKET_NAME&authType=sasl&saslPassword=$CRDL_USER_PASSWD&conflictResolutionType=lww" | grep "\"errors\"" | wc -l`
        [ `echo $bucket_crete` -ne 0 ] && logBucket "Bucket creation failed. Please check. Exitting!!" && exit
fi;
sleep 15

logBucket "Creating Indexes for the bucket $CRDL_BUCKET_NAME"
if [ $DNS_STATUS -ne 0 ]; then
	if [ $COUCBASE_VERSION -eq 0 ]; then
        logBucket "Indexes for couchbase 4.6 will be created"
        if [ $CRDL_TOTAL_NODES -gt 2 ]; then
            sed -i "s/node1_IP/CRDL.${TRAFFIC[0]}.mav/g" $idx_file1
            sed -i "s/node2_IP/CRDL.${TRAFFIC[1]}.mav/g" $idx_file1
            sed -i "s/node3_IP/CRDL.${TRAFFIC[2]}.mav/g" $idx_file1
            /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1 >> $Logfile
            sed -i "s/CRDL.${TRAFFIC[0]}.mav/node1_IP/g" $idx_file1
            sed -i "s/CRDL.${TRAFFIC[1]}.mav/node2_IP/g" $idx_file1
            sed -i "s/CRDL.${TRAFFIC[2]}.mav/node3_IP/g" $idx_file1
            logBucket "Index has been created.Please verify the same in $Logfile"
		fi;
		if [ $CRDL_TOTAL_NODES -eq 2 ];then
			declare idx_file1_2_node="`echo $idx_file1`_2_node"
			cp $idx_file1 $idx_file1_2_node
			sed -i '2,3d' $idx_file1_2_node
			sed -i '/dup/d' $idx_file1_2_node
            sed -i "s/node1_IP/CRDL.${TRAFFIC[0]}.mav/g" $idx_file1_2_node
            sed -i "s/node2_IP/CRDL.${TRAFFIC[0]}.mav/g" $idx_file1_2_node
            sed -i "s/node3_IP/CRDL.${TRAFFIC[0]}.mav/g" $idx_file1_2_node
            /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1_2_node >> $Logfile
			sed -i 's/idx/idx_dup/g' $idx_file1_2_node
			sed -i 's/PK/PK_dup/g' $idx_file1_2_node
			sed -i "s/CRDL.${TRAFFIC[0]}.mav/CRDL.${TRAFFIC[1]}.mav/g" $idx_file1_2_node
			/opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1_2_node >> $Logfile
			rm -rf $idx_file1_2_node
		fi;
        if [ $CRDL_TOTAL_NODES -eq 1 ]; then
            /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1 >> $Logfile
            logBucket "Index has been created.Please verify the same in $Logfile"
        fi;
	fi;
else
	if [ $COUCBASE_VERSION -eq 0 ]; then
        logBucket "Indexes for couchbase 4.6 will be created"
        if [ $CRDL_TOTAL_NODES -gt 2 ]; then
            sed -i "s/node1_IP/${TRAFFIC[0]}/g" $idx_file1
            sed -i "s/node2_IP/${TRAFFIC[1]}/g" $idx_file1
            sed -i "s/node3_IP/${TRAFFIC[2]}/g" $idx_file1
            /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1 >> $Logfile
            sed -i "s/${TRAFFIC[0]}/node1_IP/g" $idx_file1
            sed -i "s/${TRAFFIC[1]}/node2_IP/g" $idx_file1
            sed -i "s/${TRAFFIC[2]}/node3_IP/g" $idx_file1
            logBucket "Index has been created.Please verify the same in $Logfile"
        fi;
        if [ $CRDL_TOTAL_NODES -eq 2 ];then
            declare idx_file1_2_node="`echo $idx_file1`_2_node"
            cp $idx_file1 $idx_file1_2_node
            sed -i '2,3d' $idx_file1_2_node
            sed -i '/dup/d' $idx_file1_2_node
            sed -i "s/node1_IP/${TRAFFIC[0]}/g" $idx_file1_2_node
            sed -i "s/node2_IP/${TRAFFIC[0]}/g" $idx_file1_2_node
            sed -i "s/node3_IP/${TRAFFIC[0]}/g" $idx_file1_2_node
            /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1_2_node >> $Logfile
            sed -i 's/idx/idx_dup/g' $idx_file1_2_node
            sed -i 's/PK/PK_dup/g' $idx_file1_2_node
            sed -i "s/${TRAFFIC[0]}/${TRAFFIC[1]}/g" $idx_file1_2_node
            /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1_2_node >> $Logfile
            rm -rf $idx_file1_2_node
        fi;
        if [ $CRDL_TOTAL_NODES -eq 1 ]; then
            /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1 >> $Logfile
            logBucket "Index has been created.Please verify the same in $Logfile"
        fi;
    fi;

fi;
if [ $COUCBASE_VERSION -eq 1 ];then
        logBucket "Indexes for couchbase 5.0 will be created"
        if [ $CRDL_TOTAL_NODES -gt 1 ]; then
            logBucket "Index replication is enabled as its a multi node cluster"
            curl -u  $CRDL_USER_NAME:$CRDL_USER_PASSWD http://${TRAFFIC[0]}:9102/settings -d "{\"indexer.settings.num_replica\": 1}"
            /opt/couchbase/bin/cbq -e couchbase://${TRAFFIC[0]} -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1 >> $Logfile
            logBucket "Index has been created.Please verify the same in $Logfile"
        else
            logBucket "Index replication is not possible in 1 node cluster so disabling it"
            curl -u  $CRDL_USER_NAME:$CRDL_USER_PASSWD http://${TRAFFIC[0]}:9102/settings -d "{\"indexer.settings.num_replica\": 0}"
            [ `echo $?` -ne 0 ] && logBucket "Disabling index replication failed. Exitting!!" && exit
            /opt/couchbase/bin/cbq -e couchbase://${TRAFFIC[0]} -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $idx_file1 >> $Logfile
            logBucket "Index has been created.Please verify the same in $Logfile"
        fi;
fi;

if [ $COUCBASE_VERSION -eq 1 ];then
        logBucket "Couchbase version 5.x requires an exclusive user for connectivity"
        logBucket "Creating user $CRDL_BUCKET_NAME for the bucket $CRDL_BUCKET_NAME"
        /opt/couchbase/bin/couchbase-cli user-manage -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -c ${TRAFFIC[0]}:8091 --set --rbac-username=$CRDL_BUCKET_NAME --rbac-password=$CRDL_USER_PASSWD --auth-domain=local --roles bucket_admin[$CRDL_BUCKET_NAME],data_reader[$CRDL_BUCKET_NAME],data_writer[$CRDL_BUCKET_NAME],data_dcp_reader[$CRDL_BUCKET_NAME],query_delete[$CRDL_BUCKET_NAME],query_insert[$CRDL_BUCKET_NAME],query_select[$CRDL_BUCKET_NAME],query_update[$CRDL_BUCKET_NAME]
        user_create=`echo $?`
        if [ $user_create -eq 0 ]; then
            logBucket "User $CRDL_BUCKET_NAME has been created for bucket $CRDL_BUCKET_NAME"
        else
            logBucket "User creation failed for bucket $CRDL_BUCKET_NAME. Please check. Exitting!!" && exit
        fi;
fi;

if [ -f $CRDL_INIT_DATA ];then
        logBucket "Sourcing the default data file $CRDL_INIT_DATA to bucket $CRDL_BUCKET_NAME"
        /opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -f $CRDL_INIT_DATA >> $Logfile
        logBucket "Default data for the bucket $CRDL_BUCKET_NAME has been loaded. Please verify the same in $Logfile"
fi;

logBucket "Customizing the bucket compaction for the bucket $CRDL_BUCKET_NAME"

curl -u $CRDL_USER_NAME:$CRDL_USER_PASSWD -X POST -d "autoCompactionDefined=true&parallelDBAndViewCompaction=false&databaseFragmentationThreshold[percentage]=50&viewFragmentationThreshold[percentage]=50" http://${TRAFFIC[0]}:8091/pools/default/buckets/$CRDL_BUCKET_NAME
sleep 5
auotCompactCheck=`curl -u $CRDL_USER_NAME:$CRDL_USER_PASSWD -X GET http://${TRAFFIC[0]}:8091/pools/default/buckets/$CRDL_BUCKET_NAME | grep "\"autoCompactionSettings\":false" | wc -l`

if [ $auotCompactCheck -eq 0 ]; then
		logBucket "Customizing the bucket compaction for the bucket $CRDL_BUCKET_NAME was successful"
	else
		logBucket "Customizing the bucket compaction for the bucket $CRDL_BUCKET_NAME failed"
fi;
}

checkBucket ()
{
bucketCount=`/opt/couchbase/bin/couchbase-cli bucket-list -c ${OAM[0]}:8091 -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD | grep $CRDL_BUCKET_NAME | wc -l`
if [ $bucketCount -eq 1 ]; then
		CRDL_BUCKET_AVAIL="yes"
	else
		CRDL_BUCKET_AVAIL="no"
fi;
}

########MAIN########

if [ ! -f $scriptPath/../CB_SQL/couchbase_cluster.cfg ];then
        echo "Configuration file couchbase_cluster.cfg missing in $scriptPath/../CB_SQL/"
        echo "Copy the configuration file couchbase_cluster.cfg to $scriptPath/../CB_SQL/ and run the script. Exitting!!!"
        exit
    else
        source $scriptPath/../CB_SQL/couchbase_cluster.cfg
        bucketLogFile
		logBucket "Sourcing Configuration file $scriptPath/../CB_SQL/couchbase_cluster.cfg"
fi;

logBucket "Checking if OAM and TRAFFIC IPs are configured correctly"
TOTAL_OAM_IP=0
for OAM_IP in $CRDL_NODE_OAM_IP_LIST
do
    TOTAL_OAM_IP=`echo $(( TOTAL_OAM_IP+1 ))`
done

TOTAL_TRAFFIC_IP=0
for TRAFFIC_IP in $CRDL_NODE_DBTRAFFIC_IP_LIST
do
    TOTAL_TRAFFIC_IP=`echo $(( TOTAL_TRAFFIC_IP+1 ))`
done

if [ "$TOTAL_OAM_IP" -eq "$TOTAL_TRAFFIC_IP" ]
    then
        CRDL_TOTAL_NODES=`echo $TOTAL_OAM_IP`
    else
        logBucket "Total no of IP configured in CRDL_NODE_OAM_IP_LIST and CRDL_NODE_DBTRAFFIC_IP_LIST are not equal. Exitting!!!" && \
        exit
fi
OAM=($CRDL_NODE_OAM_IP_LIST)
TRAFFIC=($CRDL_NODE_DBTRAFFIC_IP_LIST)
NO_OF_PROD=0
for PROD in $PRODUCT
do
NO_OF_PROD=`echo $((NO_OF_PROD+1))`
done
NO_OF_WEIGHT=0
TOT_WEIGHT=0
for WEIGHT in $CRDL_PRODUCT_RAM_WEIGHT
do
NO_OF_WEIGHT=`echo $((NO_OF_WEIGHT+1))`
TOT_WEIGHT=`echo $((TOT_WEIGHT+WEIGHT))`
done

[ $NO_OF_PROD -gt $NO_OF_WEIGHT ] && logBucket "Please define the weightage of all the PRODUCT in CRDL_PRODUCT_RAM_WEIGHT" && exit
[ $NO_OF_PROD -lt $NO_OF_WEIGHT ] && logBucket "Please check if PRODUCT and CRDL_PRODUCT_RAM_WEIGHT are configured properly in config file" && exit
[ $TOT_WEIGHT -gt 80 ] && logBucket "Sum of the bucket weightages should not be greater than 80%" && exit

i=1
for PROD in $PRODUCT
do
crdl_BucketName

logBucket "Setting up bucket $CRDL_BUCKET_NAME for $PROD"
BUCKET_RAM_WEIGHTAGE=`echo "$CRDL_PRODUCT_RAM_WEIGHT" | cut -f$i -d ' '`
BUCKET_SIZE_PERCENTILE=$((CRDL_CLUSTER_RAMSIZE/100))
CRDL_BUCKET_RAMQUOTA_DEC=$((BUCKET_SIZE_PERCENTILE*BUCKET_RAM_WEIGHTAGE))
CRDL_BUCKET_RAMQUOTA=`echo ${CRDL_BUCKET_RAMQUOTA_DEC%.*}`
logBucket "RAM quota for bucket $CRDL_BUCKET_NAME is $CRDL_BUCKET_RAMQUOTA MB"

if [ $COUCBASE_VERSION -eq 0 ]; then
	logBucket "Checking if CRDL index file for couchbase 4.6 exist in $scriptPath/../CB_SQL/"
	if [ $CRDL_TOTAL_NODES -gt 1 ]; then
		idx_file1="$scriptPath/../CB_SQL/`echo $PROD`_`echo $CRDL_BUCKET_NAME`_couchbase_4_6_3_index.sql"
		[ ! -f $idx_file1 ] && \
		logBucket "CRDL index file $idx_file1 does not exist. Please create it and re-run. Exitting !!" && \
		exit
	else
		idx_file1="$scriptPath/../CB_SQL/`echo $PROD`_`echo $CRDL_BUCKET_NAME`_couchbase_4_6_3_single_node_index.sql"
		[ ! -f $idx_file1 ] && \
        logBucket "CRDL index file $idx_file1 does not exist. Please create it and re-run. Exitting !!" && \
        exit
	fi;
fi;

if [ $COUCBASE_VERSION -eq 1 ];then
    logBucket "Checking if CRDL index file for couchbase 5.0 exist in $scriptPath/../CB_SQL/"
	idx_file1="$scriptPath/../CB_SQL/`echo $PROD`_`echo $CRDL_BUCKET_NAME`_couchbase_5_0_index.sql"
    [ ! -f $idx_file1 ] && \
	logBucket "CRDL index file $idx_file1 does not exist. Please create it and re-run. Exitting !!" && \
    exit
fi;

logBucket "Checking if CRDL init data file exist"
CRDL_INIT_DATA="$scriptPath/../CB_SQL/`echo $PROD`_`echo $CRDL_BUCKET_NAME`_init_data.sql"
if [ ! -f $CRDL_INIT_DATA ]; then
	    logBucket "CRDL Init data file $CRDL_INIT_DATA does not exist. No default data will be loaded to bucket $CRDL_BUCKET_NAME."
	else
		logBucket "CRDL Init data file $CRDL_INIT_DATA will be loaded as default data to bucket $CRDL_BUCKET_NAME."
fi;

checkBucket

if [ $CRDL_BUCKET_AVAIL == "yes" ]; then
		logBucket "Bucket $CRDL_BUCKET_NAME is already present modifying the RAM quota of the bucket as per the new weightage defined"
		/opt/couchbase/bin/couchbase-cli bucket-edit --bucket=$CRDL_BUCKET_NAME -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -c ${OAM[0]}:8091 --bucket-ramsize=$CRDL_BUCKET_RAMQUOTA
		bucketMod=`echo $?`
		[ $bucketMod -eq 0 ] && logBucket "Bucket $CRDL_BUCKET_NAME RAM quota has been modified to $CRDL_BUCKET_RAMQUOTA MB"
		[ $bucketMod -ne 0 ] && logBucket "Bucket $CRDL_BUCKET_NAME RAM quota modification as per the new weightage failed. Please check. Exitting!!!" && exit
	else
		createBucket
fi;
i=`echo $((i+1))`
done
logBucket "*****************Bucket, Index & Default data setup has been completed. Please verify the same******************"

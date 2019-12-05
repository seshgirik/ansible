#! /bin/sh
#set -xv
#########################################################
#########################################################
#ScriptName=CRDL_Cluster_setup.sh		                #
#Version=1.0                                            #
#########################################################
#########################################################
CRDL_SSH_USER="root"
CRDL_SSH_USER_PASSWD="mavenir"
SSHPASS_RPM_PACKAGE="sshpass-1.06-2.el7.x86_64.rpm"
scriptPath=`dirname $0`
[ $scriptPath = "." ] && scriptPath=`pwd`
echo $PATH|grep -v $scriptPath > /dev/null && export PATH=$PATH:$scriptPath

if [ ! -f $scriptPath/../CB_SQL/couchbase_cluster.cfg ];then
		echo "Configuration file couchbase_cluster.cfg missing in $scriptPath/../CB_SQL/"
		echo "Copy the configuration file couchbase_cluster.cfg to $scriptPath/../CB_SQL/ and run the script. Exitting!!!"
		exit
	else
		source $scriptPath/../CB_SQL/couchbase_cluster.cfg
		clusterLogFile
		logCluster "Sourcing Configuration file $scriptPath/../CB_SQL/couchbase_cluster.cfg"
fi;

if [ ! -f $scriptPath/../CB_SQL/$SSHPASS_RPM_PACKAGE ];then
		logCluster "$scriptPath/../CB_SQL/$SSHPASS_RPM_PACKAGE is missing. Exitting!!" && exit
	else
		rpm -Uvh $scriptPath/../CB_SQL/$SSHPASS_RPM_PACKAGE --force
		[ `echo $?` -ne 0 ] && \
		logCluster "$SSHPASS_RPM_PACKAGE installation failed please check. Exitting!!!" && exit
fi;

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
        logCluster "Total no of IP configured in CRDL_NODE_OAM_IP_LIST and CRDL_NODE_DBTRAFFIC_IP_LIST are not equal. Exitting!!!" && \
        exit
fi

logCluster "Starting the cluster configuration of $CRDL_TOTAL_NODES nodes"

logCluster "Checking if Adminstrator credentials are setup"

OAM=($CRDL_NODE_OAM_IP_LIST)
TRAFFIC=($CRDL_NODE_DBTRAFFIC_IP_LIST)
i=0
while [ $i -lt $CRDL_TOTAL_NODES ]; do
    admin_creds_status=`/opt/couchbase/bin/cbq -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -e ${TRAFFIC[$i]}:8091 -s "select * from system:keyspaces;" | grep -i "connection failure" | wc -l`
    if [ $admin_creds_status -eq 1 ]; then
            curl -v -X POST http://${TRAFFIC[$i]}:8091/settings/web -d'password=mavenir&username=Administrator&port=SAME'
            logCluster "Administrator Credential setup is done for ${TRAFFIC[$i]}"
        else
            logCluster "Administrator Credential setup seems to be done already for ${TRAFFIC[$i]}"
    fi;
    let i++
done
sleep 15

logCluster "Assigning DB traffic IP to each node as its hostname"

if [ $DNS_STATUS -eq 0 ]; then
	i=0
	while [ $i -lt $CRDL_TOTAL_NODES ]; do
		logCluster "Node ${OAM[$i]} is renamed with traffic IP ${TRAFFIC[$i]}"
		curl  -u $CRDL_USER_NAME:$CRDL_USER_PASSWD -v -X POST http://${OAM[$i]}:8091/node/controller/rename -d "hostname=${TRAFFIC[$i]}"
		let i++
	done
	sleep 15

else
	i=0
	while [ $i -lt $CRDL_TOTAL_NODES ]; do
		IP_Entry=`cat /etc/hosts | grep "CRDL.${TRAFFIC[$i]}.mav" | wc -l`
		[ $IP_Entry -eq 0 ] && echo "${TRAFFIC[$i]} CRDL.${TRAFFIC[$i]}.mav" >> /etc/hosts
		let i++
	done

	i=1
	while [ $i -lt $CRDL_TOTAL_NODES ]; do
		sshpass -p "$CRDL_SSH_USER_PASSWD" scp /etc/hosts $CRDL_SSH_USER@${OAM[$i]}:/etc/hosts
		let i++
	done

	i=0
	while [ $i -lt $CRDL_TOTAL_NODES ]; do
		logCluster "Node ${OAM[$i]} is renamed with traffic IP CRDL.${TRAFFIC[$i]}.mav"
		curl  -u $CRDL_USER_NAME:$CRDL_USER_PASSWD -v -X POST http://${OAM[$i]}:8091/node/controller/rename -d "hostname=CRDL.${TRAFFIC[$i]}.mav"
		let i++
	done

	sleep 15
fi;

logCluster "Setting up the cluster memory"
i=0
/opt/couchbase/bin/couchbase-cli cluster-edit -c ${OAM[$i]}:8091 --user=$CRDL_USER_NAME --password=$CRDL_USER_PASSWD --cluster-ramsize=$CRDL_CLUSTER_RAMSIZE --cluster-index-ramsize=$CRDL_CLUSTER_INDEX_RAMSIZE
clust_mem=`echo $?`
if [ $clust_mem -eq 0 ];then
		logCluster "Cluster memory setup was successful"
	else
		logCluster "Cluster memory setup failed. Exiting!!!"
		exit
fi;

sleep 15

logCluster "Customizing auto-compaction settings"
/opt/couchbase/bin/couchbase-cli setting-compaction -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD -c ${OAM[$i]}:8091 --compaction-db-percentage=50 --compaction-view-percentage=50
compactSet=`echo $?`
if [ $compactSet -eq 0 ];then
		logCluster "Auto-compaction customization was successful"
	else
		logCluster "Auto-compaction customization failed"
fi;

sleep 15

if [ $DNS_STATUS -eq 0 ]; then

	if [ $CRDL_TOTAL_NODES -gt 1 ]; then
			logCluster "Creating the multi node cluster by adding the other nodes to the first node"
			i=1; j=1;
			while [ $i -lt $CRDL_TOTAL_NODES ]; do
				Addnode=`curl -u $CRDL_USER_NAME:$CRDL_USER_PASSWD ${TRAFFIC[0]}:8091/controller/addNode -d "hostname=${TRAFFIC[$j]}&user=$CRDL_USER_NAME&password=$CRDL_USER_PASSWD&services=kv,n1ql,index" | grep "\"otpNode\"\:" | wc -l`
				[ $Addnode -ne 1 ] && logCluster "Adding Node ${TRAFFIC[$j]} failed. Exitting!!!" && exit
				sleep 15
				let i++
				let j++
			done
	fi;
else
	if [ $CRDL_TOTAL_NODES -gt 1 ]; then
			logCluster "Creating the multi node cluster by adding the other nodes to the first node"
			i=1; j=1;
			while [ $i -lt $CRDL_TOTAL_NODES ]; do
				Addnode=`curl -u $CRDL_USER_NAME:$CRDL_USER_PASSWD ${TRAFFIC[0]}:8091/controller/addNode -d "hostname=CRDL.${TRAFFIC[$j]}.mav&user=$CRDL_USER_NAME&password=$CRDL_USER_PASSWD&services=kv,n1ql,index" | grep "\"otpNode\"\:" | wc -l`
				[ $Addnode -ne 1 ] && logCluster "Adding Node ${TRAFFIC[$j]} failed. Exitting!!!" && exit
				sleep 15
				let i++
				let j++
			done
	fi;
fi;

if [ $CRDL_TOTAL_NODES -gt 1 ]; then
		logCluster "Rebalancing cluster to make all the nodes as active nodes in the cluster"
		/opt/couchbase/bin/couchbase-cli rebalance -c ${TRAFFIC[0]}:8091 -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD
		reBalance=`echo $?`
		[ $reBalance -eq 0 ] && logCluster "Rebalance was successful"
		[ $reBalance -ne 0 ] && logCluster "Rebalance was not successful. Exitting!!!" && exit
fi;

sleep 15

logCluster "Check if cluster is healthy & all nodes are present"
/opt/couchbase/bin/couchbase-cli server-list -c ${TRAFFIC[0]}:8091 -u $CRDL_USER_NAME -p $CRDL_USER_PASSWD
sleep 15

logCluster "************************Cluster setup has been completed successfully.******************************"

#! /bin/bash
#set -vx

dirName=`dirname $0`

if [ -f ${dirName}/crdlMon.cfg ]
then
    echo "Sourcing ${dirName}/crdlMon.cfg"
    source ${dirName}/crdlMon.cfg
else
    echo "${dirName}/crdlMon.cfg is missing. Exiting the script"
    exit;
fi

[ "$AdminStatus" == "STANDBY" ] && exit

nodeStateRecordFile="/tmp/crdlNodeState.log"
nodeFailoverRecordFile="/tmp/crdlNodeFailover.log"

createLogFile;

if [ X"$allNodeIPList" != "X" ]; then
    for node in $allNodeIPList
    do
	isNodeUp=`checkNodeUp $node $crdlPort $crdlBucket $crdlUser $crdlPswd`
	echo "node=$node, isNodeUp=$isNodeUp"
        if [ $isNodeUp -eq 0 ]; then
	   downNode=$node
	else
	   upNode=$node
	fi

	if [ -f $nodeStateRecordFile ]; then
	   isAnyNodeDown=`grep "Down node" $nodeStateRecordFile | wc -l`
	   if [ $isAnyNodeDown -eq 1 ]; then
	      prevDownNodeIP=`grep "Down node" $nodeStateRecordFile | awk -F '=' '{print $NF}'`
	      if [ "$prevDownNodeIP" == "$upNode" -a "$upNode" == "$node" ]; then
		 echo "Previous Down Node has become up. Running rebalance with delta recovery. raiseRebalanceWithRecovery $allNodeIPListDelimited $crdlPort $prevDownNodeIP $crdlUser $crdlPswd"
		 raiseRebalanceWithRecovery $allNodeIPListDelimited $crdlPort $prevDownNodeIP $crdlUser $crdlPswd
		 rm -f $nodeStateRecordFile $nodeFailoverRecordFile
	      fi
	   fi
	fi

        if [ X"$downNode" != X -a X"$upNode" != X ]; then
	   typeset -i isFailoverDoneAlready=0
	   [ -f $nodeFailoverRecordFile ] && isFailoverDoneAlready=`grep "Failover Done" $nodeFailoverRecordFile | wc -l`
	   if [ $isFailoverDoneAlready -eq 0 ]; then
	      #echo "Down node=$downNode. Running raiseFailover $upNode $crdlPort $downNode $crdlUser $crdlPswd"
	      raiseFailover $upNode $crdlPort $downNode $crdlUser $crdlPswd
	      echo "Failover Done once" > $nodeFailoverRecordFile
	      echo "Down node=$downNode" > $nodeStateRecordFile
	      exit
	   fi
        fi
    done
fi


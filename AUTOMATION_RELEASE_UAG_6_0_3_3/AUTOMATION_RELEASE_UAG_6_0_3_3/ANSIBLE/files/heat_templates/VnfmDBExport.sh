#/bin/bash

_mylocation=`dirname $0`
_myverfile="${_mylocation}/script_version.txt"
_myversion=`cat ${_myverfile}`
_myversion="$_myversion"
_mysh=bash
_mypython=python

clear
function abort_upgrade(){

		[ "X$1" != "X" ] && echo "ERROR:$1"
        echo "ERROR:*** aborting $0*** ";
		_x_cleanup=""
		for i in $MAKE_FOLDER_LIST
		do
			[ -f $i ] && rm -rf $i && _x_cleanup="$_x_cleanup $i"
			[ -d $i ] && rm -rf $i && _x_cleanup="$_x_cleanup $i"
		done
		[ "X${_x_cleanup}" != "X" ] && echo "Cleanup completed - $_x_cleanup"
        exit 1
}
function exit_upgrade(){
		[ "X$1" != "X" ] && echo "INFO: $1"
        echo "*** exiting $0*** ";
		_x_cleanup=""
		for i in $MAKE_FOLDER_LIST
		do
			[ -f $i ] && rm -rf $i && _x_cleanup="$_x_cleanup $i"
			[ -d $i ] && rm -rf $i && _x_cleanup="$_x_cleanup $i"
		done
		[ "X${_x_cleanup}" != "X" ] && echo "Cleanup completed - $_x_cleanup"
        exit 0
}

clear
if [ ! -r ${_myverfile} ]
then
        abort_process "Missing Version File : $_myverfile"
fi

if [ "X$CATALINA_HOME" == "X" ]
then
	abort_upgrade "CATALINA_HOME=$CATALINA_HOME not set.Exiting"
fi
echo
echo "***** Starting export for VNFM Release using CATALINA_HOME=$CATALINA_HOME [$_myversion]"
echo

function on_die () {
        abort_upgrade "*** Detected ctrl-c or TERM aborting $0*** ";
}

function user_input_generic()
{
	_f_prompt=$1
	while true
	do

		echo -n "$_f_prompt (YES/NO)?"
		read _flag
		_flag=$(echo $_flag | tr 'a-z' 'A-Z')
		if [ "$_flag" != "YES" ] && [ "$_flag" != "NO" ]
		then
			echo "Kindly provide either "YES" or "NO""
			continue
		else
			_user_input_generic_op=$_flag
			break
		fi
	done
}

DATABASE_NAME='VnfmDB'
BASE_DIR=/opt/Install/VnfmDBUpgrade/
CONFD_UPGRADE_BASE_DIR=$BASE_DIR/ConfdData/
CONFIG_PROPERTIES=$CATALINA_HOME/config.properties
DATABASE_FILE=$CATALINA_HOME/webapps/cdpl/WEB-INF/database.properties
VERSION_FILE=$CATALINA_HOME/webapps/cdpl/WEB-INF/classes/VersionConfig.xml
MAKE_FOLDER_LIST=""
VERSION_UPG_FILE=$BASE_DIR/vnfm_upg_version.txt
#
#Confd config parameter
#
CONFD_UPGRADE_BASE_DIR=$BASE_DIR/ConfdData/
NETCONF_PYTHON_FILE_PATH=$CONFD_UPGRADE_BASE_DIR/scripts/NetconfModify.py
GET_XML_FILE_PATH=$CONFD_UPGRADE_BASE_DIR/NetconfGETReqList/GET/



function check_distro_files() {
	!([  -d $BASE_DIR ]) && abort_upgrade "$BASE_DIR missing."
	!([  -r $CONFIG_PROPERTIES ]) && abort_upgrade "$CONFIG_PROPERTIES missing."
	!([  -r $DATABASE_FILE ]) && abort_upgrade "$DATABASE_FILE missing."
	!([  -r $VERSION_FILE ]) && abort_upgrade "$VERSION_FILE missing."
}

function get_vnfm_version(){
	# Expected Format
	# <?xml version="1.0" encoding="UTF-8"?><Configuration><Version>VNFM_Release_4.9.1.0_Test2</Version></Configuration>

	current_rel_version=`python $CONFD_UPGRADE_BASE_DIR/scripts/version.py $VERSION_FILE | awk '{print $3}'`
	current_rel_version_dot=`python $CONFD_UPGRADE_BASE_DIR/scripts/version.py $VERSION_FILE | awk '{print $2}'`

	if [ "X$current_rel_version" == "Xnull" ]
	then
		abort_upgrade "*** Invalid version <$current_rel_version> in $VERSION_FILE [`python $CONFD_UPGRADE_BASE_DIR/scripts/version.py $VERSION_FILE`]"
	fi
#	echo "INFO:***** Found $VERSION_FILE *****"
#	cat $VERSION_FILE
#	echo "*************************"
}

check_distro_files
echo "INFO: Found VNFM at $CATALINA_HOME"
echo "INFO: Using VNFM version file at $VERSION_FILE"

echo
get_vnfm_version
echo "INFO: Starting export for VNFM Release : $current_rel_version_dot "

_buc_name_config=`awk -v mycurrver=$current_rel_version_dot '$1==mycurrver {print $7;}' $VERSION_UPG_FILE`

function set_db_cred(){
	#mariadb db credentials
    MARIADB_USER=`cat $DATABASE_FILE | dos2unix | grep user | awk -F "=" '{print $2;}'`
	MARIADB_PASSWORD=`cat $DATABASE_FILE | dos2unix |grep password | awk -F "=" '{print $2;}'`

	DB_TYPE=`awk -F "=" '/^[ ]*dbtype/{print $2;}' $CONFIG_PROPERTIES | dos2unix`
	IS_CONFD=`awk -F "=" '/^[ ]*ConfdSupported/{print $2;}' $CONFIG_PROPERTIES | dos2unix`
	CONFD_IP=`awk -F "=" '/^[ ]*ConfdIpaddress/{print $2;}' $CONFIG_PROPERTIES | dos2unix`
	PROTOCOL_TYPE=`awk -F "=" '/^[ ]*protocolType/{print $2;}' $CONFIG_PROPERTIES | dos2unix`

	if [ $DB_TYPE == 1 ]
	then
		#cassendra DB credentials
		STAT_DB_NAME="Cassandra"
		CASSANDRA_KEYSPACE=`awk -F "=" '/^[ ]*cassandraKeyspace/{print $2;}' $CONFIG_PROPERTIES | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | dos2unix`
		CASSANDRA_SMM_KEYSPACE=`awk -F "=" '/^[ ]*cassandraSmmKeyspace/{print $2;}' $CONFIG_PROPERTIES | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | dos2unix`
		CASSENDRA_IP=`awk -F "=" '/^[ ]*cassandraIp/{print $2;}' $CONFIG_PROPERTIES | dos2unix`
	else
		#CouchBase DB credentials
		STAT_DB_NAME="Couchbase"
		COUCHDB_HOSTNAME=`awk -F "=" '/^[ ]*couchbaseServerIP/{print $2;}' $CONFIG_PROPERTIES | dos2unix`
		COUCHDB_USERNAME=admin
		COUCHDB_PASSWORD_MM=`awk -F "=" '/^[ ]*password_mm/{print $2;}' $CONFIG_PROPERTIES | dos2unix`
		COUCHDB_PASSWORD_SMM=`awk -F "=" '/^[ ]*password_smm/{print $2;}' $CONFIG_PROPERTIES | dos2unix`

		if [ "$_buc_name_config" -eq 1 ]
		then
			CB_SMM_BUCKET=`awk -F "=" '/^[ ]*cbServer_SMM_BucketName/{print $2;}' $CONFIG_PROPERTIES | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | dos2unix`
			CB_MM_BUCKET=`awk -F "=" '/^[ ]*cbServer_MM_BucketName/{print $2;}' $CONFIG_PROPERTIES |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | dos2unix`
		else
			CB_SMM_BUCKET="Monitoring_Manager"
			CB_MM_BUCKET="Smm"
		fi
	fi
}

set_db_cred

function checkMaintenceModeStatus(){
    cnpl_IP=`awk -F "=" '/^[ ]*cnplIpv4/{print $2;}' $CONFIG_PROPERTIES | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | dos2unix`
	url=$cnpl_IP/cnpl/api/v1.0/getMaintenanceDetail?param=maintenMode
    echo "INFO: Checking maintenance mode ..."
	while true
	do
		_maintenance_cmd_output=`python $CONFD_UPGRADE_BASE_DIR/scripts/checkMaintenanceMode.py $MARIADB_USER $MARIADB_PASSWORD $DATABASE_NAME`
		_maintenance_mode_status=`echo $_maintenance_cmd_output | awk '{print $1}'`
		_message=`echo $_maintenance_cmd_output | awk '{$1="";print;}'`

#	echo "DEBUG: Maintenance mode details: $_maintenance_cmd_output"

		if [ "$_maintenance_mode_status" == "Error" ]
		then
			echo "WARNING: Maintenance mode not supported, proceeding with export.."
			MAINTENANCE_MODE_SUPPORT=0
			break
		elif [ "$_maintenance_mode_status" == "False" ]
		then
			echo "INFO: VNFM NOT in maintenance mode, export not recommended"
			user_input_generic "Do you still want to proceed with export "
			if [ "$_user_input_generic_op" == "YES" ] ; then
				MAINTENANCE_MODE_SUPPORT=0
				break
			else
				exit_upgrade "Please retry import after enabling maintenance mode"
			fi
		elif [ "$_maintenance_mode_status" == "Pending" ]
		then
			echo "INFO: VNFM maintenance is in pending mode"
			sleep 5s
		else
			echo "INFO: VNFM is in maintenance mode"
			MAINTENANCE_MODE_SUPPORT=1
			break
		fi
	done
}

function kill_catalina() {
	_pid=`ps -ef | grep catalina | grep -v grep | awk '{print $2}'`
	if [ "X$_pid" == "X" ]
	then
		echo " Catalina Not ACTIVE: no active pid found $_pid"
	else
		kill -0 $_pid
		if [ $? -eq 0 ]
		then
			echo "Trying to stop Catalina : active pid found $_pid, terminated Catalina (kill -9)"
			kill -9 $_pid
		else
			echo "Trying to stop Catalina : no active pid found $_pid"
		fi
	fi
}
function check_vnfm_status(){

	checkMaintenceModeStatus

	confd_pid=`ps -ef | grep confd | grep -v grep | awk '{print $2}'`
	if [ "X$confd_pid" == "X" ]
	then
		abort_upgrade '*** Confd Not ACTIVE: start VNFM (confd) prior to export ***'
	else
		echo "INFO:*** Confd ACTIVE (pid=$confd_pid) 				***"
	fi

	_process="catalina"
	_process_pid=`ps -ef | grep $_process | grep -v grep | awk '{print $2}'`
	if [ "X$_process_pid" == "X" ]
	then
		echo "WARNING:*** $_process is not ACTIVE: proceeding ahead with export ***"
	else
		echo "WARNING:*** $_process is ACTIVE (pid=$_process_pid) ***"
		if [ $MAINTENANCE_MODE_SUPPORT -eq 0 ]
		then
			#user_input_generic "To continue export catalina should be terminated please confirm "
      _user_input_generic_op="YES"
			if [ $_user_input_generic_op == "YES" ]
			then
				kill_catalina
			else
				abort_upgrade "catalina termination failed"
			fi
		fi
	fi

}

check_vnfm_status

function set_dump_folder(){
    echo
	EXE_TIME=`date +%Y%m%d-%H%M%S`
	DUMP_FOLDER=/tmp/vnfm_db_backup_$current_rel_version/vnfm_db_backup_$current_rel_version_$EXE_TIME/
	DUMP_TARGZ_FILE=/tmp/vnfm_db_backup_$current_rel_version/vnfm_db_backup_$current_rel_version_$EXE_TIME.tgz
  user_dump_folder="/tmp"
	#read -p "Enter path for dump folder (default: $DUMP_FOLDER ): " -i "" -e user_dump_folder

	if [ "X$user_dump_folder" == "X" ]
	then
		echo "No input detected, using default path $DUMP_FOLDER"
	elif [ ! -d $user_dump_folder ]
	then
		abort_upgrade " Invalid dump folder path '$user_dump_folder' does not exist, provide valid path"
	else
		DUMP_FOLDER=$user_dump_folder/vnfm_db_backup_$current_rel_version/vnfm_db_backup_$current_rel_version_$EXE_TIME/
		DUMP_TARGZ_FILE=$user_dump_folder/vnfm_db_backup_$current_rel_version/vnfm_db_backup_$current_rel_version_$EXE_TIME.tgz
	fi
	MAKE_FOLDER_LIST="$MAKE_FOLDER_LIST $DUMP_FOLDER"
}
set_dump_folder

# flags
CASSANDRA_OR_COUCH=0
KILL_CATALINA=1
VERSION=$DUMP_FOLDER/"version.txt"
PYTHON_POLICY_PATH=$CATALINA_HOME/policyfiles

#
# Non-VNFM configuration file backup
#

BACKUP_CFG_FILE="$CATALINA_HOME/conf/server.xml $CATALINA_HOME/bin/catalina.sh $CATALINA_HOME/bin/setenv.sh"
DUMP_BACKUP_CFG_PATH=$DUMP_FOLDER/backupcfg
MAKE_FOLDER_LIST="$MAKE_FOLDER_LIST $DUMP_BACKUP_CFG_PATH"

function backup_cfg_file(){
	for i in $BACKUP_CFG_FILE
	do
		if [ -f $i ]
		then
			cp $i $DUMP_BACKUP_CFG_PATH
		else
			echo "WARNING:***$i does not exists.***"
		fi
	done
}


#
#Confd config parameter
#
SET_XML_FILE_PATH=$DUMP_FOLDER/SET/
MAKE_FOLDER_LIST="$MAKE_FOLDER_LIST $SET_XML_FILE_PATH"
CONFD_UPGRADE_BASE_DIR=$BASE_DIR/ConfdData/
NETCONF_PYTHON_FILE_PATH=$CONFD_UPGRADE_BASE_DIR/scripts/NetconfModify.py
GET_XML_FILE_PATH=$CONFD_UPGRADE_BASE_DIR/NetconfGETReqList/GET/

#
#MariaDB Config Parameter
#
MARIADB_UPGRADE_BASE_DIR=$BASE_DIR/MariadbData/
SQL_FILE_FOLDER=$MARIADB_UPGRADE_BASE_DIR/upgd_schema/
SQL_MIGRATION_FILE_PATH=$MARIADB_UPGRADE_BASE_DIR/upgd_scripts/MySqlDataInsertion.py
LOWER_RELEASE_DUMP_FILE=$DUMP_FOLDER/lower_release_dump.sql
LOWER_RELEASE_SCHEMA_FILE=$DUMP_FOLDER/lower_release_schema.sql
LOWER_RELEASE_DATA_FILE=$DUMP_FOLDER/lower_release_data.sql
OAUTH_LOWER_RELEASE_DUMP=$DUMP_FOLDER/oauth_lower_release_dump.sql


#
#Cassendra Config parameter
#
CASSENDRA_DIR=$DUMP_FOLDER/cassendra_dump/
MONITOR_DATA_DUMP=$CASSENDRA_DIR/monitor_data.txt
RESOURCE_STATS_DUMP=$CASSENDRA_DIR/resource_stats.txt
MONITOR_METRIX_DUMP=$CASSENDRA_DIR/monitor_metrix.txt

#
#CouchBasedDB config parameter
#
COUCHDB_BIN=/opt/couchbase/bin/
COUCHDB_DUMP_FOLDER=$DUMP_FOLDER/couchdb_dump/

echo  "DB dump process started for ($current_rel_version_dot)"

function setup_dir(){
	mkdir -p  $MAKE_FOLDER_LIST
#	$DUMP_FOLDER $SET_XML_FILE_PATH $DUMP_BACKUP_CFG_PATH
}
setup_dir
echo $current_rel_version_dot > $VERSION




function is_command_successfully_exe(){
	_exit_code=$?
 	if [ ${_exit_code} -ne 0 ];then
  		abort_upgrade "*** <$1> Previous command terminated with exit=${_exit_code} . Terminating dump process !"
	fi
		echo $1": Completed"

}



function user_input(){
flag=""
#echo_msg="Do you want to take export for $STAT_DB_NAME DB , enter YES/NO :"

if [ $1 -eq $KILL_CATALINA ]
then
	echo_msg="Do you want to kill catalina, enter YES/NO :"
fi

while true
do

	echo -n $echo_msg
  #  read flag
  flag="YES"
	flag=$(echo $flag | tr 'a-z' 'A-Z')
	if [ "$flag" != "YES" ] && [ "$flag" != "NO" ]
	then
        echo "Kindly provide either "YES" or "NO""
        continue
	elif [ $1 -eq $KILL_CATALINA ] && [ "$flag" == "YES" ]
	then
		kill_catalina
		break
	else
		abort_export_process $1
	fi
done
}

function abort_export_process(){
	if [ $1 -eq $KILL_CATALINA ]
	then
		echo "Aborting export process."
		exit 1
	else
		break
	fi


}

## [ $MAINTENANCE_MODE_SUPPORT -eq 0 ] && user_input $KILL_CATALINA

echo
echo "MariaDB Export:  Initiated"
mysqldump -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME > $LOWER_RELEASE_DUMP_FILE
is_command_successfully_exe "MariaDB Schema and Data export"

mysqldump -u $MARIADB_USER -p$MARIADB_PASSWORD --no-data $DATABASE_NAME > $LOWER_RELEASE_SCHEMA_FILE
is_command_successfully_exe "MariaDB DDL export"

mysqldump -u $MARIADB_USER -p$MARIADB_PASSWORD --no-create-info --complete-insert $DATABASE_NAME > $LOWER_RELEASE_DATA_FILE
is_command_successfully_exe "MariaDB DATA export"

echo
if [ $IS_CONFD == true ];then
	echo "Confd Export: Initiated"
	python $NETCONF_PYTHON_FILE_PATH GET $GET_XML_FILE_PATH $SET_XML_FILE_PATH --host $CONFD_IP
	is_command_successfully_exe "Confd Export"
fi
echo
#user_input $CASSANDRA_OR_COUCH
##!CASSANDRA_BACKUP##!


function cassandra_query_to_check(){
    cqlsh $CASSENDRA_IP -e "use system;"
 	if [ $? -ne 0 ];then
  		echo "WARNING:*** Not able to connect with cassandra"
	else

	result=`cqlsh $CASSENDRA_IP -e "use system; SELECT columnfamily_name FROM schema_columnfamilies WHERE keyspace_name='$1' and columnfamily_name='$2';"`
	val=$(echo $result | grep -c $2)
	if [ $val -eq 0 ]
	then
		echo -e "\n***WARNING $2 table is not present ***"
	else
		if [ $3 -eq 0 ]
		then
			monitor_data_table=1
		elif [ $3 -eq 1 ]
		then
			resource_stats_table=1
		elif [ $3 -eq 1 ]
		then
			monitoring_metrix_table=1
		fi
	fi
	fi
}
function check_cassandra_table(){

	monitor_data_table=0
	resource_stats_table=0
	monitoring_metrix_table=0
	if [ "$1" == "$STAT_DB_NAME" ]
	then
		cassandra_query_to_check "$CASSANDRA_KEYSPACE" "monitor_data" 0
		cassandra_query_to_check "$CASSANDRA_SMM_KEYSPACE" "resource_statistics" 1
		cassandra_query_to_check "$CASSANDRA_SMM_KEYSPACE" "monitoring_metrics" 2
	fi

}
function copy_python_policy(){

	if [ -d $PYTHON_POLICY_PATH ]
	then
		cp -r $PYTHON_POLICY_PATH $DUMP_FOLDER
		is_command_successfully_exe "Copy Policy files"
	else
	   echo "No Policy folder $PYTHON_POLICY_PATH exists"
    fi
}

function is_couchbase_distributed(){
	is_couchbase_conn_rem=0
	if [ "$PROTOCOL_TYPE" == "IPv4" ]
	then

		_ifcofig_cmd=`ifconfig | grep 'inet addr:'$COUCHDB_HOSTNAME`
	else
		_ifcofig_cmd=`ifconfig | grep 'inet6 addr:'$COUCHDB_HOSTNAME`
	fi

	if [ "X$_ifcofig_cmd" == "X" ]
	then
		is_couchbase_conn_rem=1
	fi
}



function is_couchbase_bucket_present(){


	is_smm_bucket_present=0
	is_mm_bucket_present=0
	while true
	do

		echo -n "Please provide admin username of $STAT_DB_NAME server:"
		read admin_username

		if [ "X$admin_username" == "X" ]
		then
			echo "Kindly provide either username"
			continue
		else
			break
		fi
	done
	while true
	do

		echo -n "Please provide admin password of $STAT_DB_NAME server:"
		read  -s admin_password

		if [ "X$admin_password" == "X" ]
		then
			echo "Kindly provide either password"
			continue
		else
			break
		fi
	done

	if [ "$1" == "$STAT_DB_NAME" ]
	then
	    cd $COUCHDB_BIN
		output=`./couchbase-cli bucket-list  -c $COUCHDB_HOSTNAME -u $admin_username -p $admin_password`
		_code=$?
		if [ $_code -eq 0 ]
		then
			is_smm_bucket_present=$(echo $output | grep -c $CB_SMM_BUCKET)
			is_mm_bucket_present=$(echo $output | grep -c $CB_MM_BUCKET)

			if [ $is_smm_bucket_present -eq 0 ] && [ $is_mm_bucket_present -eq 0 ]
			then
				echo -e "\n *** WARNING $CB_SMM_BUCKET and $CB_MM_BUCKET buckets are not present ***"
			elif [ $is_smm_bucket_present -eq 0 ]
			then
				echo -e "\n *** WARNING $CB_SMM_BUCKET bucket is not present ***"
			elif [ $is_mm_bucket_present -eq 0 ]
			then
				echo -e "\n *** WARNING $CB_MM_BUCKET bucket is not present ***"
			fi
		else
			echo -e "\n***you have provided wrong username, password or hostname. Please check***"
		fi
	fi

}

if [[ $flag == YES ]]
then
	echo
		if [ $DB_TYPE -eq 1 ]; then
			echo "$STAT_DB_NAME export from $CASSENDRA_IP : Initiated"
			trap 'on_die' TERM INT

			check_cassandra_table "$STAT_DB_NAME"

			mkdir -p $CASSENDRA_DIR
			is_command_successfully_exe "$STAT_DB_NAME dump folder"

			if [ $monitor_data_table -eq 1 ];then

				cqlsh $CASSENDRA_IP -e "copy $CASSANDRA_KEYSPACE.monitor_data TO '$MONITOR_DATA_DUMP';"
				#is_command_successfully_exe "$STAT_DB_NAME Dump - Monitor Data"
			fi

			if [ $resource_stats_table -eq 1 ];then
				cqlsh $CASSENDRA_IP -e "copy $CASSANDRA_SMM_KEYSPACE.resource_statistics TO '$RESOURCE_STATS_DUMP';"
				#is_command_successfully_exe "$STAT_DB_NAME Dump - Resource Stats"
			fi

			if [ $monitoring_metrix_table -eq 1 ];then
				cqlsh $CASSENDRA_IP -e "copy $CASSANDRA_SMM_KEYSPACE.monitoring_metrics TO'$MONITOR_METRIX_DUMP';"
				#is_command_successfully_exe "$STAT_DB_NAME Dump - Monitor Metrix"
			fi
			trap  - TERM INT


		fi

		if [ $DB_TYPE -eq 2 ]
		then
		    is_couchbase_distributed
			if [[ $is_couchbase_conn_rem -eq 1 ]]
			then
				echo "*******************************************************************"
				echo "INFO:Couchbase running on different machine. Hostname-$COUCHDB_HOSTNAME"
				echo "We are skiping export of Couchbase"
				echo "*******************************************************************"

			elif [ ! -d $COUCHDB_BIN ]
			then
			    echo "***********************************"
				echo "WARNING:Couchbase utilities absent."
				echo "We are skiping export of Couchbase"
				echo "**********************************"

			else
				is_couchbase_bucket_present "$STAT_DB_NAME"

				if [ $is_smm_bucket_present -eq 1 ] || [ $is_mm_bucket_present -eq 1 ]
				then

					mkdir -p $COUCHDB_DUMP_FOLDER
					is_command_successfully_exe "$STAT_DB_NAME Dump folder "
					echo "$STAT_DB_NAME export from http://$COUCHDB_HOSTNAME : Initiated"
				fi

				if [ $is_smm_bucket_present -eq 1 ]
				then
					${COUCHDB_BIN}/cbbackup http://$COUCHDB_HOSTNAME -b $CB_SMM_BUCKET -u $admin_username -p $admin_password $COUCHDB_DUMP_FOLDER
					cmd_output=$?
					if  [ $cmd_output -eq 0 ]
					then
						is_command_successfully_exe "$STAT_DB_NAME Dump $CB_SMM_BUCKET"
					else
						echo  -e "\nNot able to Export data, You have provided wrong username, password or hostname. Please check"
					fi
				fi
				if [  $is_mm_bucket_present -eq 1 ]
				then
					${COUCHDB_BIN}/cbbackup http://$COUCHDB_HOSTNAME -b $CB_MM_BUCKET -u $admin_username -p $admin_password $COUCHDB_DUMP_FOLDER
					cmd_mm_output=$?
					if  [ $cmd_mm_output -eq 0 ]
					then
						is_command_successfully_exe "$STAT_DB_NAME Dump $CB_MM_BUCKET"

					else
						echo  -e "\nNot able to Export data, You have provided wrong username, password or hostname. Please check"
					fi
				fi
			fi
		fi
else
		echo "$STAT_DB_NAME export : Skipped"
fi

echo
echo "Copying Python policy"
copy_python_policy
echo
backup_cfg_file
echo
echo "Copying Config.properties"
cp $CONFIG_PROPERTIES $DUMP_FOLDER
is_command_successfully_exe "Copied config.properties to $DUMP_FOLDER"

echo
_pwd=`pwd`
echo "Creating dump tar file $DUMP_TARGZ_FILE"

cd $DUMP_FOLDER/..
tar -zcvf $DUMP_TARGZ_FILE `basename $DUMP_FOLDER`
cd $_pwd

echo
echo  "!!!! SUCCESS !!! Data dump for $current_rel_version_dot available at  $DUMP_TARGZ_FILE : Completed"

#!/bin/bash
#
#
_mylocation=`dirname $0`
_myverfile="${_mylocation}/script_version.txt"
_myversion=`cat ${_myverfile}`
_myversion="$_myversion"
_mysh=bash
_mypython=python

#
# check package dependency
#

function abort_process(){

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

function exit_process(){
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

function on_die () {
        echo
		echo "************************************************"
        echo "****ERROR:*** Detected ctrl-c or TERM        *** ";
		echo "************************************************"
        abort_process
}
trap 'on_die' TERM INT
clear
echo "********************************"
echo "***  Starting Import Process *** [$_myversion] "
echo "********************************"
if [ ! -r ${_myverfile} ]
then
        abort_process "Missing Version File : $_myverfile"
fi

function  is_python_dependency_avail(){
	pip_show_output=`pip show $1`
	if [ "X$pip_show_output" == "X" ]; then
		echo "Python package $1 not installed. Please install by using Readme.txt"
	    exit 1
	 fi

}

function abort_import_process(){
	if [ $1 -eq $MARIADB_FLAG ] || [ $1 -eq $KILL_CATALINA ]
	then
		echo "You have select 'No' option, but 'yes' required for this operation to continue Import process."
		exit 1
	else
		break
	fi


}
#is_python_dependency_avail jproperties
#is_python_dependency_avail pytz
#is_python_dependency_avail python-dateutil
#is_python_dependency_avail couchbase

#
# All precondition
#
_myname=`basename $0`
if [ "$1" == "" ]
then
	echo "ERROR:*** Please provide dump folder path. $_myname <dumpfolder_path>"
       exit 1
fi

if [ "X$CONFD_RUN_DIR" == "X" ]
then
    echo "ERROR:*** Please set CONFD_RUN_DIR path in bash file."
    exit 1
fi

if [ ! -d $1 ]; then
	echo "ERROR:*** Dump directory '$1' does not exist.*******************"
   	exit 1
fi

if [ "X$CATALINA_HOME" == "X" ]
then
	echo "ERROR:*** CATALINA_HOME=$CATALINA_HOME not set. exiting..."
	exit 1
fi

function check_vnfm_status(){
	confd_pid=`ps -ef | grep confd | grep -v grep | awk '{print $2}'`
	if [ "X$confd_pid" == "X" ]
	then
		echo "Error:*** Confd Not ACTIVE: Start VNFM prior to import ***"
		exit 1
	else
		echo "Info:*** Confd ACTIVE (pid=$confd_pid) 				***"
	fi

	_process="catalina"
	_process_pid=`ps -ef | grep $_process | grep -v grep | awk '{print $2}'`
	if [ "X$_process_pid" == "X" ]
	then
		echo "Warning:*** $_process is not ACTIVE: proceeding ahead with import ***"
	else
		echo "Warning:*** $_process is ACTIVE (pid=$_process_pid): $_process will be TERMINATED during Export ***"
	fi
}

check_vnfm_status

EXE_TIME=`date +%Y%m%d-%H%M%S`
#
#All configration
#
MARIABDB='0'
CASSENDRA='1'
COUCHDB='2'
BASE_DIR=/opt/Install/VnfmDBUpgrade/
VERSION_UPG_FILE=$BASE_DIR/vnfm_upg_version.txt
DUMP_FOLDER_DIR=`dirname $1`
DUMP_FOLDER=`cd $DUMP_FOLDER_DIR; pwd;`/`basename $1`
CONFIG_PROPERTIES=$CATALINA_HOME/config.properties
SRC_CONFIG_PROPERTIES=$DUMP_FOLDER/config.properties
DATABASE_FILE=$CATALINA_HOME/webapps/cdpl/WEB-INF/database.properties
DUMP_LIST_FILE=$BASE_DIR/dump_folder_list.txt

#
# Non-VNFM configuration file backup
#

BACKUP_CFG_FILE="$CATALINA_HOME/conf/server.xml $CATALINA_HOME/bin/catalina.sh $CATALINA_HOME/bin/setenv.sh"
DUMP_BACKUP_CFG_PATH=$DUMP_FOLDER/backupcfg

function backup_cfg_file(){
	for i in $BACKUP_CFG_FILE
	do
		cp $i $DUMP_BACKUP_CFG_PATH
	done
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

function restore_cfg_file(){
	for i in $BACKUP_CFG_FILE
	do
		_dumpfile=$DUMP_BACKUP_CFG_PATH/`basename $i`
		if [ -f $_dumpfile ]
		then
					#user_input_generic "Replace $i with $_dumpfile"
          _user_input_generic_op="YES"
					if [ "$_user_input_generic_op" == "YES" ]
					then
						cp -f $_dumpfile $i
					else
						echo "SKIPPING: replacement of $i with $_dumpfile"
					fi
		else
			echo "WARNING:***No $_dumpfile found. ***"
		fi

	done
}


#
# confd config parameter
#
SET_XML_FILE_PATH=$DUMP_FOLDER/SET/
CONFD_UPGRADE_BASE_DIR=$BASE_DIR/ConfdData/
NETCONF_PYTHON_FILE_PATH=$CONFD_UPGRADE_BASE_DIR/scripts/NetconfModify.py
DATA_MIGRATOR_PYTHON_FILE_PATH=$CONFD_UPGRADE_BASE_DIR/scripts/ConfdUpdateDataMigrator.py
SET_RESULT_FILE_PATH=$DUMP_FOLDER/SET-RESULT/
MARIADB_FLAG=0
CASSANDRA_OR_COUCH_FLAG=1
KILL_CATALINA=2
PYTHON_POLICY_PATH=$DUMP_FOLDER/policyfiles
EXISTING_POLICY_FOLDER=$CATALINA/policyfiles/
VERSION_FILE=$CATALINA_HOME/webapps/cdpl/WEB-INF/classes/VersionConfig.xml



# Expected Format
# <?xml version="1.0" encoding="UTF-8"?><Configuration><Version>VNFM_Release_4.9.1.0_Test2</Version></Configuration>
if [ ! -d $BASE_DIR ]
then
	echo "Base Directory ->$BASE_DIR does not exist."
	exit 1
fi

current_rel_version=`python $CONFD_UPGRADE_BASE_DIR/scripts/version.py $VERSION_FILE | awk '{print $3}'`
current_rel_version_dot=`python $CONFD_UPGRADE_BASE_DIR/scripts/version.py $VERSION_FILE | awk '{print $2}'`
echo "Found $VERSION_FILE"
cat  $VERSION_FILE

if [ "X$current_rel_version" == "Xnull" ]
then
	echo "ERROR:*** Invalid version <$current_rel_version> in $VERSION_FILE [`python $CONFD_UPGRADE_BASE_DIR/scripts/version.py $VERSION_FILE`]. exiting..."
	exit 1
fi

#
# check compatibility of migration data with current release
#
GET_CONFIG_VALUE=$CONFD_UPGRADE_BASE_DIR/scripts/getValueConfig.py
function check_config_param(){
    !([  -r $SRC_CONFIG_PROPERTIES ]) && echo "SKIPPING: config.properties verification as $SRC_CONFIG_PROPERTIES missing" && return
    !([  -r $CONFIG_PROPERTIES ]) && echo "SKIPPING: config.properties verification as $CONFIG_PROPERTIES missing" && return

	cmd_output=`python $GET_CONFIG_VALUE $CONFIG_PROPERTIES $SRC_CONFIG_PROPERTIES $1 | awk '{print $1}'`
	current_config_val=`python $GET_CONFIG_VALUE $CONFIG_PROPERTIES $DUMP_FOLDER/config.properties $1 | awk '{print $2}'`
	base_config_val=`python $GET_CONFIG_VALUE $CONFIG_PROPERTIES $DUMP_FOLDER/config.properties $1 | awk '{print $3}'`
	if [ "$cmd_output" == "False" ]
	then
		echo "***Difference: Key '$1' Value-> $base_config_val found in $DUMP_FOLDER/config.properties is differ from value -> $current_config_val found in $CONFIG_PROPERTIES "
		if [ "$1" == "protocolType" ]; then
			exit 1
		fi
	fi

}
function config_allowed_param()
{
	echo "Checking config.properties params: Initiated"
	check_config_param protocolType

	if [ "$current_config_val" == "IPv4" ]
	then
		check_config_param vnflcmIpv4
		check_config_param vimplIpv4
		check_config_param cnplIpv4
		check_config_param vnfdmIpv4
		check_config_param vnfcdplIpv4
		check_config_param vnfsmmIpv4
		check_config_param vnfmmIpv4
		check_config_param vnfpmIpv4
		check_config_param vnfcmsIpv4
	else
		check_config_param vnflcmIpv6
		check_config_param vimplIpv6
		check_config_param cnplIpv6
		check_config_param vnfdmIpv6
		check_config_param vnfcdplIpv6
		check_config_param vnfsmmIpv6
		check_config_param vnfmmIpv6
		check_config_param vnfpmIpv6
		check_config_param vnfcmsIpv6

	fi
	check_config_param ConfdIpaddress
	check_config_param cmsURL
	check_config_param ConfdPort
	check_config_param cassandraIp

	echo "Checking config.properties params: Completed!!!"
}
config_allowed_param



#
#MariaDB Config Parameter
#
MARIADB_UPGRADE_BASE_DIR=$BASE_DIR/MariadbData/
SQL_FILE_FOLDER=$MARIADB_UPGRADE_BASE_DIR/upgd_schema/
SQL_MIGRATION_FILE_PATH=$MARIADB_UPGRADE_BASE_DIR/upgd_scripts/MySqlDataInsertion.py
LOWER_RELEASE_DUMP_FILE=$DUMP_FOLDER/lower_release_dump.sql
OAUTH_LOWER_RELEASE_DUMP=$DUMP_FOLDER/oauth_lower_release_dump.sql
CURRENT_RELEASE_DUMP=$DUMP_FOLDER/current_release_dump_$EXE_TIME.sql
DATABASE_NAME="VnfmDB"
FETCH_TIME_STAMP_FILE=$MARIADB_UPGRADE_BASE_DIR/upgd_scripts/fetchTimeStamp.py
SQL_TIME_STAMP_QUERY_FILE=$DUMP_FOLDER/time_stamp_query.sql
SQL_QUERY_FILE=$MARIADB_UPGRADE_BASE_DIR/upgd_schema/sql_queries/
MYSQL_CURSOR_QUERIES=$MARIADB_UPGRADE_BASE_DIR/upgd_scripts/MysqlQueries.py
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


function is_command_successfully_exe(){
	if [ $? -ne 0 ];then
			echo
 			echo "ERROR:*** $2: Error!!!"
            if [ "$1" == "MariaDB" ]
      		then
				echo "Error during import of ${1}, Cleanup of $1 Initiated"
				mysqladmin -u $MARIADB_USER -p$MARIADB_PASSWORD  -f DROP $DATABASE_NAME
                mysqladmin -u $MARIADB_USER -p$MARIADB_PASSWORD  CREATE $DATABASE_NAME
                if [ -f "$CURRENT_RELEASE_DUMP" ];
				then
					echo "Recovery of $1 from $CURRENT_RELEASE_DUMP Initiated"
					mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME < $CURRENT_RELEASE_DUMP
					echo "Recovery of $1 from $CURRENT_RELEASE_DUMP Completed"
					rm $CURRENT_RELEASE_DUMP
					echo "Deleted: Current release dump file"
				fi
				exit 1
			fi

			echo "Warning: during import of ${1}, Cleanup of $1 Initiated"
			echo "$3"


 	fi
    echo "$2: Completed!!!"
	echo

}

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
		CB_SMM_BUCKET=`awk -F "=" '/^[ ]*cbServer_SMM_BucketName/{print $2;}' $CONFIG_PROPERTIES | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | dos2unix`
		CB_MM_BUCKET=`awk -F "=" '/^[ ]*cbServer_MM_BucketName/{print $2;}' $CONFIG_PROPERTIES |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | dos2unix`
	fi

}

function kill_catalina() {
        _pid=`ps -ef | grep catalina | grep -v grep | awk '{print $2}'`
		echo
        if [ "X$_pid" == "X" ]
        then
                echo " Catalina Not ACTIVE: no active pid found $_pid"
        else
                kill -0 $_pid
                if [ $? -eq 0 ]
                then
                        echo "Trying to stop Catalina : active pid found $_pid, sending kill -9"
                        kill -9 $_pid
                else
                        echo "Trying to stop Catalina : no active pid found $_pid"
                fi
        fi
}


set_db_cred

function vnfm_get_clusterstatus(){
    echo
	echo "Checking VNFM DB Cluster State: Initiated"
	_mdb_cluster_mode=`mysql -u$MARIADB_USER -p$MARIADB_PASSWORD -e "show variables like 'wsrep_on'"|grep wsrep_on|cut -f 2`
	_mdb_cluster_size=`mysql -u$MARIADB_USER -p$MARIADB_PASSWORD -e "show status like 'wsrep_cluster_size'"|grep wsrep_cluster_size|cut -f 2`

	echo "VNFM DB Cluster State : ${_mdb_cluster_mode:=NotActive}  ( Current #Nodes =  ${_mdb_cluster_size:=0} ): Completed!!!"

	if [ X${_mdb_cluster_mode} == "XON" ] && [ ${_mdb_cluster_size} -gt 1 ]
	then

        echo "Warning:*** Import is not recommended as VNFM DB cluster mode is enabled and number of nodes in cluster exceed 1"
		echo
		#user_input_generic "Warning:*** Import will impact other VNFM instances in the cluster. Proceed "
    _user_input_generic_op="YES"
		if [ "$_user_input_generic_op" == "NO" ]
		then
			exit_process
		fi
	fi
    echo
}

vnfm_get_clusterstatus

mkdir -p $SET_RESULT_FILE_PATH

base_rel_version_with_dot=`cat $DUMP_FOLDER/version.txt`
base_rel_version=${base_rel_version_with_dot//.}

function is_diff_file_exists(){
	_base_schema_rel_count=`awk -v mycurrver=$base_rel_version_with_dot '$1==mycurrver {print $2;}' $VERSION_UPG_FILE | wc -l `
	_curr_schema_rel_count=`awk -v mycurrver=$current_rel_version_dot '$1==mycurrver {print $2;}' $VERSION_UPG_FILE | wc -l`
	if [ $_base_schema_rel_count -ne 1 ] || [ $_curr_schema_rel_count -ne 1 ]
	then
		echo "ERROR:***There should be only one entry for these release $base_rel_version_with_dot and $current_rel_version_dot in vnfm_upg_version.txt. please check vnfm_upg_version.txt file"
		exit 1
	fi
	_curr_schema_rel=`awk -v mycurrver=$current_rel_version_dot '$1==mycurrver {print $2;}' $VERSION_UPG_FILE`
	_base_schema_rel=`awk -v mycurrver=$base_rel_version_with_dot '$1==mycurrver {print $2;}' $VERSION_UPG_FILE`
	_base_schema_rel=${_base_schema_rel//.}
	_curr_schema_rel=${_curr_schema_rel//.}
	FLAG_SKIP_TSUPG=`awk -v mycurrver=$current_rel_version_dot '$1==mycurrver {print $5;}' $VERSION_UPG_FILE`
	_skip_update_mig_table=`awk -v mycurrver=$current_rel_version_dot '$1==mycurrver {print $6;}' $VERSION_UPG_FILE`


	SQL_FILE=$_base_schema_rel"_"$_curr_schema_rel".sql"
	SQL_FILE_PATH=$SQL_FILE_FOLDER/$SQL_FILE
	if [ "X$_base_schema_rel" == "X" ] || [ "X$_curr_schema_rel" == "X" ]
	then
	    if [ [ ! -f "$SQL_FILE_PATH" ] || [ ! -f "$SQL_FILE_PATH"*.sh ] ] && [ "$_base_schema_rel" != "$_curr_schema_rel" ]
		then
			echo "ERROR:Upgrading dump from Release ($base_rel_version_with_dot) to Current release ($current_rel_version_dot) Not supported"
			exit 1
		fi
	fi

	if [ "$_base_schema_rel" == "$_curr_schema_rel" ]
	then
		DUMPVER_MATCHES_VNFMREL=1
		unset SQL_FILE SQL_FILE_PATH
	else
		DUMPVER_MATCHES_VNFMREL=0
	fi
	echo "Importing dump from Release ($base_rel_version_with_dot) to Current release ($current_rel_version_dot) $SQL_FILE_PATH"
}

is_diff_file_exists

function user_input(){
flag=""
var=$2
echo
echo_msg="Do you want to flush $var and import $var Dump , enter YES/NO  :"
if [ $1 -eq $KILL_CATALINA ]
then
	echo_msg="To proceed with import, catalina should be stopped, Proceed YES/NO :"
fi

while true
do

	echo -n $echo_msg
    #read flag
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
	elif [ "$flag" == "NO" ] && [ $1 -eq $KILL_CATALINA ]
	then
		exit_process
	else
		break
	fi
done
}


user_input $KILL_CATALINA
user_input $MARIADB_FLAG "MariaDB"

echo
if [ "$flag" == "YES" ]
then
	_msg="Taking current release dump"
	echo $_msg
	RESULT=`mysqlshow --user=$MARIADB_USER --password=$MARIADB_PASSWORD $DATABASE_NAME | grep -v Wildcard | grep -o $DATABASE_NAME`
	if [ "$RESULT" == "$DATABASE_NAME" ]; then
		mysqldump -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME > $CURRENT_RELEASE_DUMP
		is_command_successfully_exe "MariaDBNoRecovery" "MariaDB Database Current Release Dump"

		mysqladmin -u $MARIADB_USER -p$MARIADB_PASSWORD  -f DROP $DATABASE_NAME
		is_command_successfully_exe "MariaDB" "MariaDB Drop Database"

	fi

	mysqladmin -u $MARIADB_USER -p$MARIADB_PASSWORD  CREATE $DATABASE_NAME
	is_command_successfully_exe "MariaDB" "MariaDB Database creation"

	echo "MariaDB Migration Process : importing $LOWER_RELEASE_DUMP_FILE"


	mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME < $LOWER_RELEASE_DUMP_FILE
	is_command_successfully_exe "MariaDB" "MariaDB Import Lower Release"

	if [ $DUMPVER_MATCHES_VNFMREL -eq 0 ]; then
		rm -rf $DUMP_FOLDER/$SQL_FILE
		touch $DUMP_FOLDER/$SQL_FILE


		_pyfile=${SQL_FILE_PATH}.py
		if [ -r ${_pyfile} ]
		then
			echo "INFO: Found $_pyfile , collecting output"
			${_mypython} ${_pyfile} $MARIADB_USER $MARIADB_PASSWORD $DATABASE_NAME $DUMP_FOLDER/$SQL_FILE $base_rel_version $current_rel_version
			is_command_successfully_exe "MariaDB" "Execution of $_pyfile"
		else
			echo "INFO: Not found $_pyfile , skipping"

		fi
	#
	#LOWER_RELEASE_DUMP_FILE=$1
	#MARIADB_USER=$2
	#MARIADB_PASSWORD=$3
	#DATABASE_NAME=$4
	#SQL_FILE=$5
	#base_rel_version=$6
	#current_rel_version=$7
	#MIGRATE_FILEPATH=$8
	#sql_query_fodler=$9
	#OUTPUT_FILE=$10
	#
	i=0
		_shellfile_list=`ls -1 ${SQL_FILE_PATH}*.sh | sort`
		for _shellfile in $_shellfile_list
		do
			i=`echo "$i+1" | bc`
			_sqlfile=$DUMP_FOLDER/${SQL_FILE}_${i}
			rm -rf $_sqlfile
			touch $_sqlfile

			if [[ $i -eq 1 ]]
			then
				mv -f $DUMP_FOLDER/${SQL_FILE} $_sqlfile
				touch $DUMP_FOLDER/${SQL_FILE}
			fi

			if [ -r $_shellfile ]
			then
				echo "INFO: Found $_shellfile, collecting output"
				${_mysh} $_shellfile $LOWER_RELEASE_DUMP_FILE $MARIADB_USER $MARIADB_PASSWORD $DATABASE_NAME $DUMP_FOLDER/$SQL_FILE $base_rel_version $current_rel_version $SQL_FILE_FOLDER $SQL_QUERY_FILE $_sqlfile >> $_sqlfile
				is_command_successfully_exe "MariaDB" "Execution of $_shellfile"
			fi
			echo "MariaDB Migration Process : importing $_sqlfile using [${_shellfile}]"
			mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME < $_sqlfile
			is_command_successfully_exe "MariaDB" "MariaDB Data Part"
		done

		if [ $DUMPVER_MATCHES_VNFMREL -eq 0 ]; then
			if [ -f $SQL_FILE_PATH ]
			then
				echo "MariaDB Migration Process: importing $SQL_FILE_PATH"
				mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME < $SQL_FILE_PATH
				is_command_successfully_exe "MariaDB" "MariaDB Migration Process : importing $SQL_FILE_PATH"
			fi
		fi

		if [ "$FLAG_SKIP_TSUPG" -eq 0 ]
		then
			DELETE_COMMAND="DELETE FROM VNFM_MIGRATE_TABLE;"
			echo $DELETE_COMMAND >> $DUMP_FOLDER/$SQL_FILE

			INSERT_COMMAND="INSERT INTO VNFM_MIGRATE_TABLE (id, isMigrated, srcRelVersion, tgtRelVersion) values ( 1, 'true_c', '$base_rel_version_with_dot', '$current_rel_version_dot' );";
			echo $INSERT_COMMAND >> $DUMP_FOLDER/$SQL_FILE

			if [ "$_skip_update_mig_table" -eq 1 ]
			then
				UPDATE_COMMAND="UPDATE VNFM_MIGRATE_TABLE set initialUpgradeComplete='false_c';"
				echo $UPDATE_COMMAND >> $DUMP_FOLDER/$SQL_FILE
			fi
		fi
		echo "MariaDB Migration Process : importing $DUMP_FOLDER/$SQL_FILE"
		mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME < $DUMP_FOLDER/$SQL_FILE
		is_command_successfully_exe "MariaDB" "MariaDB Data Part"
	else
	    SQL_FILE=$_base_schema_rel"_"$_curr_schema_rel".sql"
	    vnfm_table_cmd_file=$DUMP_FOLDER/$SQL_FILE
		touch $vnfm_table_cmd_file
		if [ "$FLAG_SKIP_TSUPG" -eq 0 ]
		then
			DELETE_COMMAND="DELETE FROM VNFM_MIGRATE_TABLE;"
			echo $DELETE_COMMAND >> $vnfm_table_cmd_file

			INSERT_COMMAND="INSERT INTO VNFM_MIGRATE_TABLE (id, isMigrated, srcRelVersion, tgtRelVersion) values ( 1, 'true_c', '$base_rel_version_with_dot', '$current_rel_version_dot' );";
			echo $INSERT_COMMAND >> $vnfm_table_cmd_file

			if [ "$_skip_update_mig_table" -eq 1 ]
			then
				UPDATE_COMMAND="UPDATE VNFM_MIGRATE_TABLE set initialUpgradeComplete='false_c';"
				echo $UPDATE_COMMAND >> $vnfm_table_cmd_file
			fi
		fi
		echo "MariaDB Migration Process : importing $DUMP_FOLDER/$SQL_FILE"
		mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME < $vnfm_table_cmd_file
		is_command_successfully_exe "MariaDB" "Insert data into VNFM_MIGRATION_TABLE"
	fi


	echo "Creating a file for timestamp queries"
	if [ "$FLAG_SKIP_TSUPG" -eq 0 ]; then
		rm -rf $SQL_TIME_STAMP_QUERY_FILE
		touch $SQL_TIME_STAMP_QUERY_FILE
		python $FETCH_TIME_STAMP_FILE $SQL_TIME_STAMP_QUERY_FILE  $MARIABDB $MARIADB_USER $MARIADB_PASSWORD $DATABASE_NAME 0
		is_command_successfully_exe "MariaDB" "Time Stamp Sql Queries"
	fi

	if [[ $IS_CONFD -eq true ]]
	then
		echo "cleaning cdb"
		_pwd=`pwd`
		cd $CONFD_RUN_DIR/confd_deployment/
		killall confd
		make clean
		make all
		make start
		cd $_pwd
	fi



fi
echo
if [[ $IS_CONFD -eq true ]];then
	echo "Confd migration Process"
	echo "Going to perform change tag operation on XML files"
	python $DATA_MIGRATOR_PYTHON_FILE_PATH UPDATE $SET_XML_FILE_PATH
	is_command_successfully_exe "Confd" "Change Tags for post xml file"
	python $NETCONF_PYTHON_FILE_PATH POST $SET_XML_FILE_PATH $SET_RESULT_FILE_PATH --host $CONFD_IP

fi

# user_input $CASSANDRA_OR_COUCH_FLAG  $STAT_DB_NAME
##!CASSANDRA_BACKUP##!
function cassandra_query_to_check(){
	echo
	cqlsh $CASSENDRA_IP -e "use system;"
 	if [ $? -ne 0 ];then
  		echo "Warning:*** Not able to connect with $STAT_DB_NAME"

	else
	result=`cqlsh $CASSENDRA_IP -e "use system; SELECT columnfamily_name FROM schema_columnfamilies WHERE keyspace_name='$1' and columnfamily_name='$2';"`
	val=$(echo $result | grep -c $2)
	if [ $val -eq 0 ]
	then
		echo -e "\n***Warning $2 table is not present ***"
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

function copy_python_policy(){

	if [ -d $PYTHON_POLICY_PATH ]
	then
		if [ -d $EXISTING_POLICY_FOLDER ]
		then
		    echo "Deleting old Policy files"
			rm $EXISTING_POLICY_FOLDER/*
			is_command_successfully_exe "Policy" "Deleted old policy file"
		fi

		cp -r $PYTHON_POLICY_PATH $CATALINA_HOME
		is_command_successfully_exe "Policy" "Copy Policy files"
	else
	   echo "No Policy folder $PYTHON_POLICY_PATH exist"
    fi
}
function is_couchbase_bucket_present(){
     echo
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
		read -s admin_password

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
				echo -e "\n *** Warning $CB_SMM_BUCKET and $CB_MM_BUCKET buckets are not present ***"
			elif [ $is_smm_bucket_present -eq 0 ]
			then
				echo -e "\n *** Warning $CB_SMM_BUCKET bucket is not present ***"
			elif [ $is_mm_bucket_present -eq 0 ]
			then
				echo -e "\n *** Warning $CB_SMM_BUCKET bucket is not present ***"
			fi

		else
			echo -e "\n**you have provided wrong username, password or hostname. Please check***"
		fi
	fi
	echo
}

if [ "$flag" == "YES" ]
then
		echo
		if [[ $DB_TYPE -eq 1 ]]
		then
		    echo -e  "\n Flushing $STAT_DB_NAME"
			trap 'on_die' TERM INT
			check_cassandra_table "$STAT_DB_NAME"
			if [ $monitor_data_table -eq 1 ]
			then
				cqlsh $CASSENDRA_IP -e "use $CASSANDRA_KEYSPACE; truncate table monitor_data;"
				is_command_successfully_exe "$STAT_DB_NAME" "$STAT_DB_NAME monitor_data Flush"
			fi

			if [ $resource_stats_table -eq 1 ]
			then
				cqlsh $CASSENDRA_IP -e "use $CASSANDRA_SMM_KEYSPACE; truncate table resource_statistics;"
				is_command_successfully_exe "$STAT_DB_NAME" "$STAT_DB_NAME resource_statistics Flush"
			fi

			if [ $monitoring_metrix_table -eq 1 ]
			then
				cqlsh $CASSENDRA_IP -e "use $CASSANDRA_SMM_KEYSPACE; truncate table monitoring_metrics;"
				is_command_successfully_exe "$STAT_DB_NAME" "$STAT_DB_NAME monitoring_metrics Flush"
			fi

			echo "Importing Casendra dump"
			if [ $monitor_data_table -eq 1 ]; then
				if [ -s $MONITOR_DATA_DUMP ]
				then
					cqlsh $CASSENDRA_IP -e "copy $CASSANDRA_KEYSPACE.monitor_data FROM '$MONITOR_DATA_DUMP';"
					is_command_successfully_exe "$STAT_DB_NAME" "$STAT_DB_NAME monitor_data Import"
				else
					echo "Skipping import of $STAT_DB_NAME - dump $MONITOR_DATA_DUMP is empty or not present"
				fi
			fi
			if [ $resource_stats_table -eq 1 ]; then
				if [ -s $RESOURCE_STATS_DUMP ]
				then
					cqlsh $CASSENDRA_IP -e "copy $CASSANDRA_SMM_KEYSPACE.resource_statistics FROM '$RESOURCE_STATS_DUMP';"
					is_command_successfully_exe "$STAT_DB_NAME" "$STAT_DB_NAME resource_statistics Import"
				else
					echo "Skipping import of $STAT_DB_NAME - dump $RESOURCE_STATS_DUMP is empty or not present"
				fi
			fi

			if [ $monitoring_metrix_table -eq 1 ]; then
				if [ -s $MONITOR_METRIX_DUMP ]
				then
					cqlsh $CASSENDRA_IP -e "copy $CASSANDRA_SMM_KEYSPACE.monitoring_metrics FROM '$MONITOR_METRIX_DUMP';"
					is_command_successfully_exe "$STAT_DB_NAME" "$STAT_DB_NAME monitoring_metric Import"
				else
					echo "Skipping import of $STAT_DB_NAME - dump $MONITOR_METRIX_DUMP is empty or not present"
				fi
			fi
			trap  - TERM INT
		fi


		if [[ $DB_TYPE -eq 2 ]]
		then
			is_couchbase_distributed
			if [[ $is_couchbase_conn_rem -eq 1 ]]
			then
				echo "*******************************************************************"
				echo "INFO:***Couchbase running on different machine. Hostname-$COUCHDB_HOSTNAME"
				echo "We are skiping import of Couchbase"
				echo "*******************************************************************"

			elif [ ! -d $COUCHDB_BIN ]
			then
			    echo "***********************************"
				echo "WWARNING:***Couchbase utilities absent"
				echo "We are skiping import of Couchbase"
				echo "************************************"

			else
				is_couchbase_bucket_present "$STAT_DB_NAME"
				cd $COUCHDB_BIN
				if [ $is_mm_bucket_present -eq 1 ] || [ $is_smm_bucket_present -eq 1 ]
				then
					echo -e "\n Flushing $STAT_DB_NAME"
				fi
				if [ $is_mm_bucket_present -eq 1 ]
				then
					./couchbase-cli bucket-flush --force -c $COUCHDB_HOSTNAME -u $admin_username -p $admin_password  --bucket=$CB_MM_BUCKET
					cmd_mm_flush_output=$?
					if  [ $cmd_mm_flush_output -eq 0 ]
					then
						is_command_successfully_exe "$STAT_DB_NAME" "$CB_MM_BUCKET Bucket Flush"
					else
						echo -e "\n***Got some Error in flusing data! Please check data you have provided(username, password or hostname)"
					fi
				fi
				if [ $is_smm_bucket_present -eq 1 ]
				then
					./couchbase-cli bucket-flush --force -c $COUCHDB_HOSTNAME -u $admin_username -p $admin_password  --bucket=$CB_SMM_BUCKET
					cmd_smm_flush_output=$?
					if  [ $cmd_smm_flush_output -eq 0 ]
					then
						is_command_successfully_exe "$STAT_DB_NAME" "$CB_SMM_BUCKET Bucket Flush"
					else
						echo -e  "\n***Got some Error in flusing data! Please check data you have provided(username, password or hostname)"
					fi
				fi



				if [ -d $COUCHDB_DUMP_FOLDER ]
				then
					if [ $is_mm_bucket_present -eq 1 ] || [ $is_smm_bucket_present -eq 1 ]
					then
						echo "Importing $STAT_DB_NAME Dump"
					fi
					if [ $is_mm_bucket_present -eq 1 ]
					then

						$COUCHDB_BIN/cbrestore  -v -u $admin_username -p $admin_password --bucket-source=$CB_MM_BUCKET $COUCHDB_DUMP_FOLDER http://$COUCHDB_HOSTNAME
						cmd_mm_output=$?
						if  [ $cmd_mm_output -eq 0 ]
						then
							is_command_successfully_exe "$STAT_DB_NAME" "$CB_MM_BUCKET Bucket"
						else
							echo -e "\n ***Not able to import data. You have provided wrong username, password and hostname. Please check***"
						fi
					fi

					if [ $is_smm_bucket_present -eq 1 ]
					then
						$COUCHDB_BIN/cbrestore  -v -u $admin_username -p $admin_password --bucket-source=$CB_SMM_BUCKET $COUCHDB_DUMP_FOLDER http://$COUCHDB_HOSTNAME
						cmd_smm_output=$?
						if  [ $cmd_smm_output -eq 0 ]
						then
							is_command_successfully_exe "$STAT_DB_NAME" "$CB_SMM_BUCKET Bucket"
						else
							echo -e "\n ***Not able to connect. You have provided wrong username, password and hostname. Please check***"
						fi
					fi
				else
					echo "Skipping import of $STAT_DB_NAME - dump not present"
				fi
			fi
		fi
	echo
fi


synchours=1
flag=$synchours
if [ "$FLAG_SKIP_TSUPG" -eq 0 ]; then
	if [[ $DB_TYPE -eq 1 ]]
	then
		python $FETCH_TIME_STAMP_FILE $SQL_TIME_STAMP_QUERY_FILE  $CASSENDRA $CASSENDRA_IP $CASSANDRA_KEYSPACE $CASSANDRA_SMM_KEYSPACE $flag
		is_command_successfully_exe "$STAT_DB_NAME" "$STAT_DB_NAME Timestamp Queries"
	elif [[ $DB_TYPE -eq 2 ]]
	then
		python $FETCH_TIME_STAMP_FILE $SQL_TIME_STAMP_QUERY_FILE  $COUCHDB http://$COUCHDB_HOSTNAME $COUCHDB_USERNAME $COUCHDB_PASSWORD_SMM $flag $CB_SMM_BUCKET
		is_command_successfully_exe "$STAT_DB_NAME" "Bucket $COUCHDB_PASSWORD_SMM Timestamp Queries"

		python $FETCH_TIME_STAMP_FILE $SQL_TIME_STAMP_QUERY_FILE  $COUCHDB http://$COUCHDB_HOSTNAME $COUCHDB_USERNAME $COUCHDB_PASSWORD_MM $flag $CB_MM_BUCKET
		is_command_successfully_exe "$STAT_DB_NAME" "$Bucket  Timestamp Queries"
	fi
	if [ -s $SQL_TIME_STAMP_QUERY_FILE ]
	then
			echo "Importing MigrateTable: importing SQL_TIME_STAMP_QUERY_FILE"
			mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $DATABASE_NAME < $SQL_TIME_STAMP_QUERY_FILE
			is_command_successfully_exe "MariaDB" "Import Time stamp queries"
	fi
fi


echo
echo "Copying Python policy"
copy_python_policy

restore_cfg_file
echo

#
# below function Targeted for 4.9.2.0
#

function cleanup_impexpfiles(){
	echo
	if [ ! -f "$DUMP_LIST_FILE" ]
	then
		touch "$DUMP_LIST_FILE"
	fi

	user_input_generic "Cleanup $DUMP_FOLDER"
	if [ "$_user_input_generic_op" == "YES" ]
	then
		rm -fR $DUMP_FOLDER
	else
		echo $DUMP_FOLDER >> $DUMP_LIST_FILE
	fi
}

echo "!!!!  SUCCESS  !!! Data dump migration (${base_rel_version_with_dot} => ${current_rel_version_dot}) from $DUMP_FOLDER : Completed"
echo "!!!!  **Note** !!! VNFM was stopped during upgrade. Please start using (cd $CATALINA_HOME/bin ; ./catalina.sh start ) "
echo ""
exit 0

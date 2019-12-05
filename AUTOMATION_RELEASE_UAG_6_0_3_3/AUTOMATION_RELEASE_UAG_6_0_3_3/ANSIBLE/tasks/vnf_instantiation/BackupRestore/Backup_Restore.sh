#!/bin/bash

#Backup and Restore
echo "Enter CMS IP : "
read CMS_IP
echo "Enter CMS Login Username : "
read CMS_IP_SYSUSER
echo "Enter CMS Login Password : "
read CMS_IP_SYSPASS
CMS_URL = "https://" + $CMS_IP + ":18080"
printf "[cms]\n$CMS_IP" > ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt
echo -e "Select One of the Below Options either (1) or (2)\n1. Backup\n2. Restore"
read Opt
case $Opt in
	1) #Backup
	echo -e "Select backupType from below Options (1) or (2) or (3)\n1. ON_DEMAND\n2. PERIOD\n3. SCHEDULE"
	read bktype
	case $bktype in
		1) #ON_DEMAND
			echo -e "Select ON_DEMAND Type from below Options (1) or (2)\n1. FULL\n2. INCREMENTAL"
			read odtype
			case $odtype in
				1) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_ON_DEMAND.j2" -e BK_TYPE="FULL";;
				2) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_ON_DEMAND.j2" -e BK_TYPE="INCREMENTAL";;
				*) echo select proper option; exit;;
			esac
		;;
		2) #PERIOD
			read -p "please enter the start time: " Stime
			echo -e "Select PERIOD Type from below Options (1) or (2)\n1. FULL\n2. INCREMENTAL"
			read ptype
			case $ptype in
                                1) #FULL
					echo -e "Select PERIOD Type from below Options (1) or (2)\n1. DAILY\n2. WEEKLY"
					read prtype
					case $prtype in
						1) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_PERIOD.j2" -e BK_TYPE="FULL" -e PERIOD="DAILY" -e STtime=$Stime;;
                                                2) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_PERIOD.j2" -e BK_TYPE="FULL" -e PERIOD="WEEKLY" -e STtime=$Stime;;
                                                *) echo select proper option; exit;;
					esac
				;;
                                2) #INCREMENTAL
                                        echo -e "Select PERIOD Type from below Options (1) or (2)\n1. DAILY\n2. WEEKLY"
                                        read prtype
                                        case $prtype in
                                                1) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_PERIOD.j2" -e BK_TYPE="INCREMENTAL" -e PERIOD="DAILY" -e STtime=$Stime;;
                                                2) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_PERIOD.j2" -e BK_TYPE="INCREMENTAL" -e PERIOD="WEEKLY" -e STtime=$Stime;;
                                                *) echo select proper option; exit;;
                                        esac
				;;
                                *) echo select proper option; exit;;
                        esac
		;;
		3) #SCHEDULE
                        read -p "please enter the start time: : : : : : : : : " Stime
                        echo -e "Select SCHEDULE Type from below Options (1) or (2)\n1. FULL\n2. INCREMENTAL"
                        read stype
                        case $stype in
                                1) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_SCHEDULE.j2" -e BK_TYPE="FULL" -e STtime=$Stime;;
                                2) ansible-playbook -vvv ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Backup.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="BackUp_SCHEDULE.j2" -e BK_TYPE="INCREMENTAL" -e STtime=$Stime;;
                                *) echo select proper option; exit;;
                        esac
		;;
		*) echo select proper option; exit;;
	esac
	;;
	2) #Restore
		echo -e "Select restoreMethod from below Options (1) or (2)\n1. ON_DEMAND\n2. SCHEDULE"
		read rstype
        	case $rstype in
                	1) #ON_DEMAND
				ansible-playbook ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Restore.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="Restore_ON_DEMAND.j2";;
                	2) #SCHEDULE
                        	read -p "please enter the start time: " Stime
				ansible-playbook ANSIBLE/tasks/vnf_instantiation/BackupRestore/tasks/Restore.yml -i ANSIBLE/tasks/vnf_instantiation/BackupRestore/inventory.txt -e CMS_IP=$CMS_IP -e CMS_URL=$CMS_URL -e CMS_IP_SYSPASS=$CMS_IP_SYSPASS -e CMS_IP_SYSUSER=$CMS_IP_SYSUSER -e BK_TEMPLATE="Restore_SCHEDULE.j2" -e STtime=$Stime;;
			*) echo select proper option; exit;;
		esac
	;;
	*) echo select proper option; exit;;
esac

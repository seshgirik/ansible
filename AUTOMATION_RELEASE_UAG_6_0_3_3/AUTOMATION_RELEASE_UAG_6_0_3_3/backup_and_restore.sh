source ./COMMON_SOURCE/common.sh
chmod +x $VNF_TASKS/BackupRestore/Backup_Restore.sh
cdir=`pwd`
sh $VNF_TASKS/BackupRestore/Backup_Restore.sh | sudo tee $cdir/$LOGS/backup_restore.log

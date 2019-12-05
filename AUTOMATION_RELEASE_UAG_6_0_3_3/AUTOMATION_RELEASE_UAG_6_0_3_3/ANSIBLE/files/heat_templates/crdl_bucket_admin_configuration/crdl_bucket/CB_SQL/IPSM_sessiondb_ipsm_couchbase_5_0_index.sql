CREATE PRIMARY INDEX `sessiondb_ipsm_PK` ON `sessiondb_ipsm` USING GSI;
CREATE INDEX sessiondb_ipsm_idx1 ON sessiondb_ipsm(lock_key,bucket_id,site_id) WHERE KTAB= 'PollUserData' USING GSI;
CREATE INDEX sessiondb_ipsm_idx2 ON sessiondb_ipsm(dest_user_id,site_id,sched_msg_id,val_exp_msg_id) WHERE KTAB= 'MTsvcdata' USING GSI;
CREATE INDEX sessiondb_ipsm_idx3 ON sessiondb_ipsm(app_id,site_id) WHERE KTAB= 'ATsvcdata' USING GSI;

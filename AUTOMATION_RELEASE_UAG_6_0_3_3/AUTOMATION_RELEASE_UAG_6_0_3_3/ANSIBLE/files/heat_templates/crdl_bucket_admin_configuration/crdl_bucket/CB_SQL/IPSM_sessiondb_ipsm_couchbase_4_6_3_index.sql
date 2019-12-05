CREATE PRIMARY INDEX `sessiondb_ipsm_PK1` ON `sessiondb_ipsm` USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX `sessiondb_ipsm_PK2` ON `sessiondb_ipsm` USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX `sessiondb_ipsm_PK3` ON `sessiondb_ipsm` USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_ipsm_idx1 ON sessiondb_ipsm(lock_key,bucket_id,site_id) WHERE KTAB= 'PollUserData' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX sessiondb_ipsm_idx2 ON sessiondb_ipsm(dest_user_id,site_id,sched_msg_id,val_exp_msg_id) WHERE KTAB= 'MTsvcdata' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_ipsm_idx3 ON sessiondb_ipsm(app_id,site_id) WHERE KTAB= 'ATsvcdata' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_ipsm_idx_dup1 ON sessiondb_ipsm(lock_key,bucket_id,site_id) WHERE KTAB= 'PollUserData' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_ipsm_idx_dup2 ON sessiondb_ipsm(dest_user_id,site_id,sched_msg_id,val_exp_msg_id) WHERE KTAB= 'MTsvcdata' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_ipsm_idx_dup3 ON sessiondb_ipsm(app_id,site_id) WHERE KTAB= 'ATsvcdata' USING GSI WITH {"nodes":["node1_IP:8091"]};

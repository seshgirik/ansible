CREATE PRIMARY INDEX sessiondb_pgw_PK1 ON sessiondb_pgw USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_pgw_PK2 ON sessiondb_pgw USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_pgw_PK3 ON sessiondb_pgw USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_pgw_idx1 ON sessiondb_pgw(VNFID) WHERE KTAB= 'MPGU' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX sessiondb_pgw_idx2 ON sessiondb_pgw(SESSION_TYPE) WHERE KTAB= 'MPGU' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_pgw_idx3 ON sessiondb_pgw(mpguappinterfaceids) USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_pgw_idx_dup1 ON sessiondb_pgw(VNFID) WHERE KTAB= 'MPGU' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_pgw_idx_dup2 ON sessiondb_pgw(SESSION_TYPE) WHERE KTAB= 'MPGU' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_pgw_idx_dup3 ON sessiondb_pgw(mpguappinterfaceids) USING GSI WITH {"nodes":["node1_IP:8091"]};

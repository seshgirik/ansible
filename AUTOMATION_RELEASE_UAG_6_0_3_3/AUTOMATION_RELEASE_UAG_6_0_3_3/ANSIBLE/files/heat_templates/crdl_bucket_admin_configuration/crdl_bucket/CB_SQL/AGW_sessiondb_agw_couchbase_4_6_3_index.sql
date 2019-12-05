CREATE PRIMARY INDEX sessiondb_agw_PK1 ON sessiondb_agw USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_agw_PK2 ON sessiondb_agw USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_agw_PK3 ON sessiondb_agw USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_agw_idx1 ON sessiondb_agw(BTID) WHERE KTAB='agwNafGbaUser' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX sessiondb_agw_idx2 ON sessiondb_agw(MSISDN) WHERE KTAB='agwNafGbaUser' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_agw_idx3 ON sessiondb_agw(agwappinterfaceids) USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_agw_idx_dup1 ON sessiondb_agw(BTID) WHERE KTAB='agwNafGbaUser' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_agw_idx_dup2 ON sessiondb_agw(MSISDN) WHERE KTAB='agwNafGbaUser' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_agw_idx_dup3 ON sessiondb_agw(agwappinterfaceids) USING GSI WITH {"nodes":["node1_IP:8091"]};

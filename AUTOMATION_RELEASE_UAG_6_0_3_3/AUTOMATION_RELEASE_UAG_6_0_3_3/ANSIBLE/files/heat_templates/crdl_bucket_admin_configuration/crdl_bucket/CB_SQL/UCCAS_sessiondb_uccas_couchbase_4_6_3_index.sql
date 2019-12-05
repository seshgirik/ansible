CREATE PRIMARY INDEX sessiondb_uccas_PK1 ON sessiondb_uccas USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_uccas_PK2 ON sessiondb_uccas USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_uccas_PK3 ON sessiondb_uccas USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_uccas_idx1 ON sessiondb_uccas(TUID) WHERE (KTAB = 'UccMeta')  USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX sessiondb_uccas_idx2 ON sessiondb_uccas(Uccasappinterfaceids) USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_uccas_idx_dup1 ON sessiondb_uccas(TUID) WHERE (KTAB = 'UccMeta')  USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_uccas_idx_dup2 ON sessiondb_uccas(Uccasappinterfaceids) USING GSI WITH {"nodes":["node1_IP:8091"]};

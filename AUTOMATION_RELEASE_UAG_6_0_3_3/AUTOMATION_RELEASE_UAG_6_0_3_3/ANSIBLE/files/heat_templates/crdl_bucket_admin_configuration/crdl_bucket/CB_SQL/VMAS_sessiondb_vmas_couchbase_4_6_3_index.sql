CREATE PRIMARY INDEX sessiondb_vmas_PK1 ON sessiondb_vmas USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_vmas_PK2 ON sessiondb_vmas USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_vmas_PK3 ON sessiondb_vmas USING GSI WITH {"nodes":["node3_IP:8091"]};

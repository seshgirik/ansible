CREATE PRIMARY INDEX sessiondb_vrcs_PK1 ON sessiondb_vrcs USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_vrcs_PK2 ON sessiondb_vrcs USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_vrcs_PK3 ON sessiondb_vrcs USING GSI WITH {"nodes":["node3_IP:8091"]};


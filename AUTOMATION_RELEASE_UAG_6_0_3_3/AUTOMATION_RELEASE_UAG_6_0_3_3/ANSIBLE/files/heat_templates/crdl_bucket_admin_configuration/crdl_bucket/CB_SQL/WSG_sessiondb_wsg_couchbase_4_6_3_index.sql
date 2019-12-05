CREATE PRIMARY INDEX sessiondb_wsg_PK1 ON sessiondb_wsg USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_wsg_PK2 ON sessiondb_wsg USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_wsg_PK3 ON sessiondb_wsg USING GSI WITH {"nodes":["node3_IP:8091"]};

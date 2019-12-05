CREATE PRIMARY INDEX sessiondb_pns_PK1 ON sessiondb_pns USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_pns_PK2 ON sessiondb_pns USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_pns_PK3 ON sessiondb_pns USING GSI WITH {"nodes":["node3_IP:8091"]};

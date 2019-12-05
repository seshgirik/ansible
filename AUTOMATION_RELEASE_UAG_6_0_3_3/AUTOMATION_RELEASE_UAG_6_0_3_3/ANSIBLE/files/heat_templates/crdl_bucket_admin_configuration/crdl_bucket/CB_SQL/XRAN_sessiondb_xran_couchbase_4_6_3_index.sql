CREATE PRIMARY INDEX sessiondb_xran_PK1 ON sessiondb_xran USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_xran_PK2 ON sessiondb_xran USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_xran_PK3 ON sessiondb_xran USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_xran_idx1 ON sessiondb_xran(VNFThreadId) WHERE KTAB= 'CellEcgMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX sessiondb_xran_idx2 ON sessiondb_xran(VNFThreadId) WHERE KTAB= 'UeEcgMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_xran_idx3 ON sessiondb_xran(xranappinterfaceids) USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_xran_idx_dup1 ON sessiondb_xran(VNFThreadId) WHERE KTAB= 'CellEcgMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_xran_idx_dup2 ON sessiondb_xran(VNFThreadId) WHERE KTAB= 'UeEcgMap' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_xran_idx_dup3 ON sessiondb_xran(xranappinterfaceids) USING GSI WITH {"nodes":["node1_IP:8091"]};
-- Module :  X2GW
CREATE INDEX sessiondb_xran_idx4 ON sessiondb_xran(VNFID,ThreadId) WHERE KTAB= 'X2gw_Meta' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX sessiondb_xran_idx5 ON sessiondb_xran(x2gwinterfaceid) USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX sessiondb_xran_idx_dup4 ON sessiondb_xran(VNFID,ThreadId) WHERE KTAB= 'X2gw_Meta' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX sessiondb_xran_idx_dup5 ON sessiondb_xran(x2gwinterfaceid) USING GSI WITH {"nodes":["node1_IP:8091"]};

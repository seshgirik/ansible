CREATE PRIMARY INDEX sessiondb_xran_PK ON sessiondb_xran USING GSI;
CREATE INDEX sessiondb_xran_idx1 ON sessiondb_xran(VNFThreadId) WHERE KTAB= 'CellEcgMap' USING GSI;
CREATE INDEX sessiondb_xran_idx2 ON sessiondb_xran(VNFThreadId) WHERE KTAB= 'UeEcgMap' USING GSI;
CREATE INDEX sessiondb_xran_idx3 ON sessiondb_xran(xranappinterfaceids) USING GSI;
-- Module :  X2GW
CREATE INDEX sessiondb_xran_idx4 ON sessiondb_xran(VNFID,ThreadId) WHERE KTAB= 'X2gw_Meta' USING GSI;
CREATE INDEX sessiondb_xran_idx5 ON sessiondb_xran(x2gwinterfaceid) USING GSI;

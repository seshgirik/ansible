CREATE PRIMARY INDEX sessiondb_pgw_PK ON sessiondb_pgw USING GSI;
CREATE INDEX sessiondb_pgw_idx1 ON sessiondb_pgw(VNFID) WHERE KTAB= 'MPGU' USING GSI;
CREATE INDEX sessiondb_pgw_idx2 ON sessiondb_pgw(SESSION_TYPE) WHERE KTAB= 'MPGU' USING GSI;
CREATE INDEX sessiondb_pgw_idx3 ON sessiondb_pgw(mpguappinterfaceids) USING GSI;

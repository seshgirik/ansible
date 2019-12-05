CREATE PRIMARY INDEX sessiondb_agw_PK ON sessiondb_agw USING GSI;
CREATE INDEX sessiondb_agw_idx1 ON sessiondb_agw(BTID) WHERE KTAB='agwNafGbaUser' USING GSI;
CREATE INDEX sessiondb_agw_idx2 ON sessiondb_agw(MSISDN) WHERE KTAB='agwNafGbaUser' USING GSI;
CREATE INDEX sessiondb_agw_idx3 ON sessiondb_agw(agwappinterfaceids) USING GSI;

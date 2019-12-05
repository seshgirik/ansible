CREATE PRIMARY INDEX sessiondb_uccas_PK ON sessiondb_uccas USING GSI;
CREATE INDEX sessiondb_uccas_idx1 ON sessiondb_uccas(TUID) WHERE (KTAB = 'UccMeta')  USING GSI;
CREATE INDEX sessiondb_uccas_idx2 ON sessiondb_uccas(Uccasappinterfaceids) USING GSI;

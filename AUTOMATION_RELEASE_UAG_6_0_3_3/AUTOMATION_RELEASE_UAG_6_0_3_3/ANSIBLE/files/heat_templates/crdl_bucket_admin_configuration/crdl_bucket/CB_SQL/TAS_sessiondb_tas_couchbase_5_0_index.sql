CREATE PRIMARY INDEX `sessiondb_tas_PK` ON `sessiondb_tas` USING GSI;
CREATE INDEX `sessiondb_tas_idx1` ON `sessiondb_tas`(`msisdn`,`app_oid`) WHERE (`KTAB` = "SccasMeta") USING GSI;
CREATE INDEX `sessiondb_tas_idx2` ON `sessiondb_tas`(`vmid`) WHERE (`KTAB` = "SccasMeta") USING GSI;
CREATE INDEX `sessiondb_tas_idx3` ON `sessiondb_tas`(`msisdn`,`app_oid`) WHERE (`KTAB` = "TasMeta") USING GSI;
CREATE INDEX `sessiondb_tas_idx4` ON `sessiondb_tas`(`vmid`) WHERE (`KTAB` = "TasMeta") USING GSI;
CREATE INDEX `sessiondb_tas_idx5` ON `sessiondb_tas`(`Tasappinterfaceids`) USING GSI;

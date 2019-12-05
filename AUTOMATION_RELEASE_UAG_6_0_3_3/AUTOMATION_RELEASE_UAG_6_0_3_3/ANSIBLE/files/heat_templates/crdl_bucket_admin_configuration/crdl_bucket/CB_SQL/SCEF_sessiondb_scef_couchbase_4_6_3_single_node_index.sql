CREATE PRIMARY INDEX `sessiondb_scef_PK` ON `sessiondb_scef` USING GSI;
CREATE INDEX `sessiondb_scef_idx1` ON `sessiondb_scef`(`VNFID`,`SERVICETYPE`) WHERE (`KTAB` = "MONTE") USING GSI;
CREATE INDEX `sessiondb_scef_idx2` ON `sessiondb_scef`(`SCEFREFID_SERVICE`) WHERE (`KTAB` = "MONTE") USING GSI;
CREATE INDEX `sessiondb_scef_idx3` ON `sessiondb_scef`(`VNFID`,`SERVICETYPE`) WHERE (`KTAB` = "NIDD") USING GSI;
CREATE INDEX `sessiondb_scef_idx4` ON `sessiondb_scef`(`SCSID_EXTID_SERVICE`) WHERE (`KTAB` = "NIDD") USING GSI;
CREATE INDEX `sessiondb_scef_idx5` ON `sessiondb_scef`(`VNFID`,`SERVICETYPE`) WHERE (`KTAB` = "SESSION") USING GSI;
CREATE INDEX `sessiondb_scef_idx6` ON `sessiondb_scef`(`SCSID_EXTID_RTRIGREFNUM`) WHERE (`KTAB` = "SESSION") USING GSI;
CREATE INDEX `sessiondb_scef_idx7` ON `sessiondb_scef`(`scefappinterfaceids`) USING GSI;

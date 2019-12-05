CREATE PRIMARY INDEX `sessionDBVLB_PNS_PK` ON `sessionDBVLB_PNS` USING GSI;
CREATE INDEX `sessionDBVLB_PNS_idx1` ON `sessionDBVLB_PNS`(`VMID`,`Timestamp`,`OP_TYPE`) WHERE ((`KEYFLAG` = "1") and (`KTAB` = "SipData")) USING GSI;
CREATE INDEX `sessionDBVLB_PNS_idx2` ON `sessionDBVLB_PNS`(`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI;
CREATE INDEX `sessionDBVLB_PNS_idx3` ON `sessionDBVLB_PNS`(`VNFID`,`TIMESTAMP`,`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI;
CREATE INDEX `sessionDBVLB_PNS_idx4` ON `sessionDBVLB_PNS`(`vlbappinterfaceids`) USING GSI;

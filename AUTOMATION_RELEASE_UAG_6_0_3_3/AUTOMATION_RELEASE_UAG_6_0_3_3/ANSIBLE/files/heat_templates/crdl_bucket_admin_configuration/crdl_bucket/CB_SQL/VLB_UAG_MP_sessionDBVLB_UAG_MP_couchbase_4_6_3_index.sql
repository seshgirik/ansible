CREATE PRIMARY INDEX `sessionDBVLB_UAG_MP_PK1` ON `sessionDBVLB_UAG_MP` USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX `sessionDBVLB_UAG_MP_PK2` ON `sessionDBVLB_UAG_MP` USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX `sessionDBVLB_UAG_MP_PK3` ON `sessionDBVLB_UAG_MP` USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx1` ON `sessionDBVLB_UAG_MP`(`VMID`,`Timestamp`,`OP_TYPE`) WHERE ((`KEYFLAG` = "1") and (`KTAB` = "SipData")) USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx2` ON `sessionDBVLB_UAG_MP`(`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx3` ON `sessionDBVLB_UAG_MP`(`VNFID`,`TIMESTAMP`,`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx4` ON `sessionDBVLB_UAG_MP`(`vlbappinterfaceids`) USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx_dup1` ON `sessionDBVLB_UAG_MP`(`VMID`,`Timestamp`,`OP_TYPE`) WHERE ((`KEYFLAG` = "1") and (`KTAB` = "SipData")) USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx_dup2` ON `sessionDBVLB_UAG_MP`(`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx_dup3` ON `sessionDBVLB_UAG_MP`(`VNFID`,`TIMESTAMP`,`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `sessionDBVLB_UAG_MP_idx_dup4` ON `sessionDBVLB_UAG_MP`(`vlbappinterfaceids`) USING GSI WITH {"nodes":["node1_IP:8091"]};

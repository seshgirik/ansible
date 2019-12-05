CREATE PRIMARY INDEX `sessionDBVLB_CSCF_PK1` ON `sessionDBVLB_CSCF` USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX `sessionDBVLB_CSCF_PK2` ON `sessionDBVLB_CSCF` USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX `sessionDBVLB_CSCF_PK3` ON `sessionDBVLB_CSCF` USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx1` ON `sessionDBVLB_CSCF`(`VMID`,`Timestamp`,`OP_TYPE`) WHERE ((`KEYFLAG` = "1") and (`KTAB` = "SipData")) USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx2` ON `sessionDBVLB_CSCF`(`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx3` ON `sessionDBVLB_CSCF`(`VNFID`,`TIMESTAMP`,`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx4` ON `sessionDBVLB_CSCF`(`vlbappinterfaceids`) USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx_dup1` ON `sessionDBVLB_CSCF`(`VMID`,`Timestamp`,`OP_TYPE`) WHERE ((`KEYFLAG` = "1") and (`KTAB` = "SipData")) USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx_dup2` ON `sessionDBVLB_CSCF`(`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx_dup3` ON `sessionDBVLB_CSCF`(`VNFID`,`TIMESTAMP`,`APP_OID`) WHERE (`KTAB` = "mNATMap") USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `sessionDBVLB_CSCF_idx_dup4` ON `sessionDBVLB_CSCF`(`vlbappinterfaceids`) USING GSI WITH {"nodes":["node1_IP:8091"]};

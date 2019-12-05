CREATE PRIMARY INDEX SCNfvCouchbase_PK1 ON SCNfvCouchbase USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX SCNfvCouchbase_PK1 ON SCNfvCouchbase USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX SCNfvCouchbase_PK3 ON SCNfvCouchbase USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx1 ON SCNfvCouchbase(VMID) WHERE KTAB= 'ccsVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx2 ON SCNfvCouchbase(VMID) WHERE KTAB= 'MPCVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx3 ON SCNfvCouchbase(VMID) WHERE KTAB= 'MPPVmAppMap' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx4 ON SCNfvCouchbase(VMID) WHERE KTAB= 'atcVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx5 ON SCNfvCouchbase(VMID) WHERE KTAB= 'tcVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx6 ON SCNfvCouchbase(VMID) WHERE KTAB= 'profileVmAppMap' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx7 ON SCNfvCouchbase(VMID) WHERE KTAB = 'pcscfVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx8 ON SCNfvCouchbase(VMID) WHERE KTAB = 'atcfVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx9 ON SCNfvCouchbase(VMID) WHERE KTAB = 'ibcfVmAppMap' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx10 ON SCNfvCouchbase(VMID) WHERE KTAB = 'eatfVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx11 ON SCNfvCouchbase(VMID) WHERE KTAB = 'trfVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx12 ON SCNfvCouchbase(Uagappinterfaceids) USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup1 ON SCNfvCouchbase(VMID) WHERE KTAB= 'ccsVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup2 ON SCNfvCouchbase(VMID) WHERE KTAB= 'MPCVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup3 ON SCNfvCouchbase(VMID) WHERE KTAB= 'MPPVmAppMap' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup4 ON SCNfvCouchbase(VMID) WHERE KTAB= 'atcVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup5 ON SCNfvCouchbase(VMID) WHERE KTAB= 'tcVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup6 ON SCNfvCouchbase(VMID) WHERE KTAB= 'profileVmAppMap' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup7 ON SCNfvCouchbase(VMID) WHERE KTAB = 'pcscfVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup8 ON SCNfvCouchbase(VMID) WHERE KTAB = 'atcfVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup9 ON SCNfvCouchbase(VMID) WHERE KTAB = 'ibcfVmAppMap' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup10 ON SCNfvCouchbase(VMID) WHERE KTAB = 'eatfVmAppMap' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup11 ON SCNfvCouchbase(VMID) WHERE KTAB = 'trfVmAppMap' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX SCNfvCouchbase_idx_dup12 ON SCNfvCouchbase(Uagappinterfaceids) USING GSI WITH {"nodes":["node3_IP:8091"]};

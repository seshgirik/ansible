CREATE PRIMARY INDEX imsNfvCouchbase1_PK1 ON imsNfvCouchbase1 USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX imsNfvCouchbase1_PK2 ON imsNfvCouchbase1 USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX imsNfvCouchbase1_PK3 ON imsNfvCouchbase1 USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX imsNfvCouchbase1_idx1 ON imsNfvCouchbase1(VMID) WHERE (KTAB = "ScscfDev") USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX imsNfvCouchbase1_idx2 ON imsNfvCouchbase1(VMID) WHERE (KTAB = "ScscfSes") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX imsNfvCouchbase1_idx_dup1 ON imsNfvCouchbase1(VMID) WHERE (KTAB = "ScscfDev") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX imsNfvCouchbase1_idx_dup2 ON imsNfvCouchbase1(VMID) WHERE (KTAB = "ScscfSes") USING GSI WITH {"nodes":["node3_IP:8091"]};

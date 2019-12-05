CREATE PRIMARY INDEX MPNfvCouchbase_PK1 ON MPNfvCouchbase USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX MPNfvCouchbase_PK2 ON MPNfvCouchbase USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX MPNfvCouchbase_PK3 ON MPNfvCouchbase USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `MPNfvCouchbase_idx1` ON `MPNfvCouchbase`(`VMID`) WHERE (`KTAB` = "MPPVmAppMap") USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX `MPNfvCouchbase_idx2` ON `MPNfvCouchbase`(`VMID`) WHERE (`KTAB` = "MPCVmAppMap") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `MPNfvCouchbase_idx_dup1` ON `MPNfvCouchbase`(`VMID`) WHERE (`KTAB` = "MPPVmAppMap") USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `MPNfvCouchbase_idx_dup2` ON `MPNfvCouchbase`(`VMID`) WHERE (`KTAB` = "MPCVmAppMap") USING GSI WITH {"nodes":["node1_IP:8091"]};

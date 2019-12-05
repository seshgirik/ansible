CREATE PRIMARY INDEX MPNfvCouchbase_PK ON MPNfvCouchbase USING GSI;
CREATE INDEX `MPNfvCouchbase_idx1` ON `MPNfvCouchbase`(`VMID`) WHERE (`KTAB` = "MPPVmAppMap") USING GSI;
CREATE INDEX `MPNfvCouchbase_idx2` ON `MPNfvCouchbase`(`VMID`) WHERE (`KTAB` = "MPCVmAppMap") USING GSI;


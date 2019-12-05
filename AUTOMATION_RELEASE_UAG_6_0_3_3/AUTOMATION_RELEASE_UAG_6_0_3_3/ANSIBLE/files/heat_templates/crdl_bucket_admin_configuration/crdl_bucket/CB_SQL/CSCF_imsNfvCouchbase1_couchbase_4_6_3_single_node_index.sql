CREATE PRIMARY INDEX imsNfvCouchbase1_PK ON imsNfvCouchbase1 USING GSI;
CREATE INDEX imsNfvCouchbase1_idx1 ON imsNfvCouchbase1(VMID) WHERE (KTAB = "ScscfDev") USING GSI;
CREATE INDEX imsNfvCouchbase1_idx2 ON imsNfvCouchbase1(VMID) WHERE (KTAB = "ScscfSes") USING GSI;

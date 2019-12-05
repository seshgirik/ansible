CREATE PRIMARY INDEX TCNfvCouchbase_PK ON TCNfvCouchbase USING GSI;
CREATE INDEX TCNfvCouchbase_idx1 ON TCNfvCouchbase(vmid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI;
CREATE INDEX TCNfvCouchbase_idx2 ON TCNfvCouchbase(app_oid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI;

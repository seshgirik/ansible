CREATE PRIMARY INDEX TCNfvCouchbase_PK1 ON TCNfvCouchbase USING GSI;
CREATE INDEX TCNfvCouchbase_idx1 ON TCNfvCouchbase(vmid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI;
CREATE INDEX TCNfvCouchbase_idx22 ON TCNfvCouchbase(app_oid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI;

CREATE PRIMARY INDEX TCNfvCouchbase_PK1 ON TCNfvCouchbase USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX TCNfvCouchbase_PK2 ON TCNfvCouchbase USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX TCNfvCouchbase_PK3 ON TCNfvCouchbase USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX TCNfvCouchbase_idx1 ON TCNfvCouchbase(vmid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX TCNfvCouchbase_idx2 ON TCNfvCouchbase(app_oid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX TCNfvCouchbase_dup_idx1 ON TCNfvCouchbase(vmid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX TCNfvCouchbase_dup_idx2 ON TCNfvCouchbase(app_oid) WHERE tcVmid2APPOIDMapping='tcVmid2APPOIDMapping' USING GSI WITH {"nodes":["node1_IP:8091"]};

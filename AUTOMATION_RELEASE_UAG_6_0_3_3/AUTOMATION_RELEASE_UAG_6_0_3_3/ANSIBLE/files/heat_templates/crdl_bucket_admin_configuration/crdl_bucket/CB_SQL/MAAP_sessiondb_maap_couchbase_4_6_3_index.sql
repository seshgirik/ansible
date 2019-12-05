CREATE PRIMARY INDEX sessiondb_maap_PK1 ON sessiondb_maap USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_maap_PK2 ON sessiondb_maap USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE PRIMARY INDEX sessiondb_maap_PK3 ON sessiondb_maap USING GSI WITH {"nodes":["node3_IP:8091"]};
CREATE INDEX `sessiondb_maap_idx1` ON `sessiondb_maap`(`TYPE`) WHERE (`KTAB` = "LOCATIONINFO") USING GSI WITH {"nodes":["node1_IP:8091"]};
CREATE INDEX `sessiondb_maap_idx2` ON `sessiondb_maap`(`dialNumber`) WHERE (`KTAB` = "LOCATIONINFO") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessiondb_maap_idx_dup1` ON `sessiondb_maap`(`TYPE`) WHERE (`KTAB` = "LOCATIONINFO") USING GSI WITH {"nodes":["node2_IP:8091"]};
CREATE INDEX `sessiondb_maap_idx_dup2` ON `sessiondb_maap`(`dialNumber`) WHERE (`KTAB` = "LOCATIONINFO") USING GSI WITH {"nodes":["node3_IP:8091"]};

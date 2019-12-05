CREATE PRIMARY INDEX `sessiondb_maap_PK` ON `sessiondb_maap` USING GSI;
CREATE INDEX `sessiondb_maap_idx1` ON `sessiondb_maap`(`TYPE`) WHERE (`KTAB` = "LOCATIONINFO") USING GSI;
CREATE INDEX `sessiondb_maap_idx2` ON `sessiondb_maap`(`dialNumber`) WHERE (`KTAB` = "LOCATIONINFO") USING GSI;

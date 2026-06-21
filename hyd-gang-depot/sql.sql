CREATE TABLE IF NOT EXISTS `hyd_gang_depots` (
    `depot_id` VARCHAR(50) NOT NULL,
    `pin` VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (`depot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Initial record for the Ballas depot (v2 matches config)
INSERT IGNORE INTO `hyd_gang_depots` (`depot_id`, `pin`) VALUES ('ballas_depot_v2', NULL);

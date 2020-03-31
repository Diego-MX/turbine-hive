
CREATE TABLE lapaz_general(
  id            SERIAL,
  name          CHAR(50),
  tm            CHAR(20),
  start_date    DATE,
  end_date      DATE,
  sdr           CHAR(20),
  model_num     INTEGER,
  serial_num    INTEGER,
  hardware_rev  CHAR(20),
  site_num      INTEGER,
  site_desc     CHAR(50),
  project_code  CHAR(50),
  project_desc  CHAR(50),
  site_loc      CHAR(50),
  site_elev     INTEGER,
  site_lat_chr  CHAR(20),
  site_lon_chr  CHAR(20),
  time_offset   INTEGER,
  PRIMARY KEY(id)
);

CREATE TABLE lapaz_channels(
  id              SERIAL,
  measure_id      INTEGER, 
  channel_type    INTEGER,
  channel_desc    CHAR(50),
  details         CHAR(100),
  serial_num      INTEGER,
  height          INTEGER,
  scale_fct       NUMERIC,
  channel_offset  NUMERIC,
  units           CHAR(20),
  PRIMARY KEY(id),
  FOREIGN KEY(measure_id) REFERENCES lapaz_general(id)
);

CREATE TABLE lapaz_records(
  id          BIGSERIAL,
  channel_id    INTEGER, 
  measure_id INTEGER, 
  record_ts  TIMESTAMP,
  record_avg    NUMERIC,
  record_sd    NUMERIC,
  record_min      NUMERIC,
  record_max      NUMERIC,
  PRIMARY KEY(id),
  FOREIGN KEY(channel_id)    REFERENCES lapaz_channels(id),
  FOREIGN KEY(measure_id) REFERENCES lapaz_general(id)
);



CREATE TABLE rwd_general(
  id            SERIAL,
  description   CHAR(50),
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
  filename      CHAR(50),
  start_date    DATE,
  end_date      DATE,
  tm_file       CHAR(20),
  PRIMARY KEY(id)
);

CREATE TABLE rwd_channels(
  id              SERIAL,
  measure_desc    CHAR(50), 
  channel_type    INTEGER,
  channel_desc    CHAR(50),
  details         CHAR(100),
  serial_num      INTEGER,
  height          NUMERIC,
  scale_fct       NUMERIC,
  channel_offset  NUMERIC,
  units           CHAR(20),
  measure_serial  INTEGER,
  warnings        CHAR(100),
  PRIMARY KEY(id) --, 
  --FOREIGN KEY(measur--e_serial) REFERENCES rwd_general(serial_num)
);

CREATE TABLE rwd_records(
  id              BIGSERIAL,
  channel_serial  CHAR(50), 
  measure_desc    CHAR(50), 
  record_ts       TIMESTAMP,
  record_len      INTEGER, 
  record_avg      NUMERIC,
  record_sd       NUMERIC,
  record_min      NUMERIC,
  record_max      NUMERIC,
  measure_serial  CHAR(50),
  PRIMARY KEY(id) -- ,
  --FOREIGN KEY(channel_serial) REFERENCES rwd_channels(serial_num),
  --FOREIGN KEY(measure_serial) REFERENCES rwd_general(serial_num)
);


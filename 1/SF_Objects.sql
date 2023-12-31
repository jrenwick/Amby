CREATE DATABASE JASON;
CREATE SCHEMA RAW;
CREATE OR REPLACE TABLE NETFLIX (
    SHOW_ID VARCHAR,
    "TYPE" VARCHAR,
    TITLE VARCHAR,
    DIRECTOR VARCHAR,
    "CAST" VARCHAR,
    COUNTRY VARCHAR,
    DATE_ADDED VARCHAR,
    RELEASE_YEAR NUMBER,
    RATING VARCHAR,
    DURATION VARCHAR,
    LISTED_IN VARCHAR,
    DESCRIPTION VARCHAR,
    CONSTRAINT PK_SHOW_ID PRIMARY KEY (SHOW_ID)
);

-- modelling technique - OBT (One Big Table) - good for column storage data warehouses
CREATE OR REPLACE TABLE DIM_SHOW (
    SHOW_ID VARCHAR,
    "TYPE" VARCHAR,
    TITLE VARCHAR,
    DIRECTOR VARCHAR,
    "CAST" VARCHAR,
    COUNTRY VARCHAR,
    DATE_ADDED DATE,
    RELEASE_YEAR NUMBER,
    RATING VARCHAR,
    DURATION VARCHAR,
    LISTED_IN VARCHAR,
    DESCRIPTION VARCHAR,
    CONSTRAINT PK_SHOW_ID PRIMARY KEY (SHOW_ID)
);

-- I dont think we should cluster this table as it is small.
-- I think the clustering should be done by ordering the data on insert.
ALTER TABLE JASON.RAW.DIM_SHOW CLUSTER BY ("TYPE");

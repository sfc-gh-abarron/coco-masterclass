----------------------------------------------------------------------
-- FROSTBYTE SKI SUPPLY INVENTORY - Infrastructure Setup
-- Run as ACCOUNTADMIN (or a role with CREATE DATABASE/WAREHOUSE/ROLE)
----------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;

----------------------------------------------------------------------
-- 1. DATABASE
----------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS FROSTBYTE_SKI_INVENTORY
    COMMENT = 'Frostbyte ski supply inventory project database';

----------------------------------------------------------------------
-- 2. SCHEMAS
----------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS FROSTBYTE_SKI_INVENTORY.RAW
    COMMENT = 'Raw ingestion layer - source data as-is';

CREATE SCHEMA IF NOT EXISTS FROSTBYTE_SKI_INVENTORY.HARMONIZED
    COMMENT = 'Harmonized layer - cleansed and transformed data';

CREATE SCHEMA IF NOT EXISTS FROSTBYTE_SKI_INVENTORY.ANALYTICS
    COMMENT = 'Analytics layer - business-ready consumption models';

----------------------------------------------------------------------
-- 3. WAREHOUSE
----------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS FROSTBYTE_SKI_INVENTORY_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Frostbyte ski supply inventory workloads';

----------------------------------------------------------------------
-- 4. ROLES
----------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS FROSTBYTE_SKI_INVENTORY_ADMIN
    COMMENT = 'Full admin access to the Frostbyte ski inventory project';

CREATE ROLE IF NOT EXISTS FROSTBYTE_SKI_INVENTORY_ENGINEER
    COMMENT = 'Data engineer - read/write access for pipeline development';

CREATE ROLE IF NOT EXISTS FROSTBYTE_SKI_INVENTORY_ANALYST
    COMMENT = 'Analyst - read-only access for reporting and analytics';

----------------------------------------------------------------------
-- 5. ROLE HIERARCHY
----------------------------------------------------------------------
GRANT ROLE FROSTBYTE_SKI_INVENTORY_ANALYST TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;
GRANT ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER TO ROLE FROSTBYTE_SKI_INVENTORY_ADMIN;
GRANT ROLE FROSTBYTE_SKI_INVENTORY_ADMIN TO ROLE SYSADMIN;

----------------------------------------------------------------------
-- 6. GRANTS - DATABASE
----------------------------------------------------------------------
GRANT OWNERSHIP ON DATABASE FROSTBYTE_SKI_INVENTORY
    TO ROLE FROSTBYTE_SKI_INVENTORY_ADMIN
    COPY CURRENT GRANTS;

GRANT USAGE ON DATABASE FROSTBYTE_SKI_INVENTORY
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;

GRANT USAGE ON DATABASE FROSTBYTE_SKI_INVENTORY
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;

----------------------------------------------------------------------
-- 7. GRANTS - SCHEMAS
----------------------------------------------------------------------
-- ADMIN owns all schemas
GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE FROSTBYTE_SKI_INVENTORY
    TO ROLE FROSTBYTE_SKI_INVENTORY_ADMIN
    COPY CURRENT GRANTS;

-- ENGINEER: full usage + create on RAW and HARMONIZED
GRANT USAGE ON SCHEMA FROSTBYTE_SKI_INVENTORY.RAW
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT, CREATE PIPE
    ON SCHEMA FROSTBYTE_SKI_INVENTORY.RAW
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;

GRANT USAGE ON SCHEMA FROSTBYTE_SKI_INVENTORY.HARMONIZED
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE
    ON SCHEMA FROSTBYTE_SKI_INVENTORY.HARMONIZED
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;

GRANT USAGE ON SCHEMA FROSTBYTE_SKI_INVENTORY.ANALYTICS
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA FROSTBYTE_SKI_INVENTORY.ANALYTICS
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;

-- ANALYST: read-only on HARMONIZED and ANALYTICS
GRANT USAGE ON SCHEMA FROSTBYTE_SKI_INVENTORY.HARMONIZED
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA FROSTBYTE_SKI_INVENTORY.HARMONIZED
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA FROSTBYTE_SKI_INVENTORY.HARMONIZED
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;

GRANT USAGE ON SCHEMA FROSTBYTE_SKI_INVENTORY.ANALYTICS
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA FROSTBYTE_SKI_INVENTORY.ANALYTICS
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA FROSTBYTE_SKI_INVENTORY.ANALYTICS
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;

----------------------------------------------------------------------
-- 8. GRANTS - WAREHOUSE
----------------------------------------------------------------------
GRANT OWNERSHIP ON WAREHOUSE FROSTBYTE_SKI_INVENTORY_WH
    TO ROLE FROSTBYTE_SKI_INVENTORY_ADMIN
    COPY CURRENT GRANTS;

GRANT USAGE ON WAREHOUSE FROSTBYTE_SKI_INVENTORY_WH
    TO ROLE FROSTBYTE_SKI_INVENTORY_ENGINEER;

GRANT USAGE ON WAREHOUSE FROSTBYTE_SKI_INVENTORY_WH
    TO ROLE FROSTBYTE_SKI_INVENTORY_ANALYST;

----------------------------------------------------------------------
-- DONE
----------------------------------------------------------------------

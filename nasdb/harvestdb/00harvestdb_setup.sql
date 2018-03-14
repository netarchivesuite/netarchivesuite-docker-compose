\echo Creating tablespace tsindex
CREATE TABLESPACE tsindex
LOCATION '/tsindex';

GRANT ALL ON TABLESPACE tsindex TO PUBLIC;

\echo Creating devel role
CREATE ROLE "devel" LOGIN PASSWORD 'devel123'
NOINHERIT CREATEDB
VALID UNTIL 'infinity';

\echo Creating db harvestdb
CREATE DATABASE "harvestdb"
WITH
TEMPLATE=template0
ENCODING='SQL_ASCII'
OWNER="devel";

\echo Creating db admindb
CREATE DATABASE "admindb"
WITH
TEMPLATE=template0
ENCODING='SQL_ASCII'
OWNER="devel";

\echo Creating role netarchivesuite
CREATE ROLE "netarchivesuite" LOGIN PASSWORD 'netarchivesuitepass'
NOINHERIT CREATEDB
VALID UNTIL 'infinity'
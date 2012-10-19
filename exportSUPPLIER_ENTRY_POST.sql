-- Project Name : BASE1 TO CSV SUPPLIER ENTRY EMP DATA
-- Author       : Sakuma Eiji
-- Modified by  : 
-- Date         : 2008/09/17
-- DBMS         : Oracle 10g
-- 
set linesize 10000
set pagesize 0
set trimspool on
set feedback off
set verify off

spool /home/sag/daf/import_csv/&2


--データを出力
SELECT 
''''||trim(to_char(row_number() over (partition by CORP_ID order by  CORP_ID DESC),'00000000'))||''''||','||''''||
POST||''''
FROM mst_ms.cust_emp@BASE1
WHERE CORP_ID LIKE '4%' and POST IS NOt NULL AND CORP_ID='&1';
spool off;

exit;

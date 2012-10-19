-- Project Name : BASE1 TO CSV SUPPLIER ENTRY DEPT DATA
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
select ''''||substr(cd.cust_dept_id,9,4)||''''||','||''''||
substr(cd.upper_dept_id,9,4)||''''||','||''''||
cd.CUST_DEPT_NAME||''''||','||''''||
1||''''
from cust_dept@BASE1 cd left join m_dept d on substr(cd.cust_dept_id,1,8) = d.corp_cd and substr(cd.cust_dept_id,9,4) = d.dept_cd
where cd.cust_dept_id like '4%' and substr(cd.cust_dept_id,1,8) = '&1';
spool off;

exit;

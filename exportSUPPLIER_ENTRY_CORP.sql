-- Project Name : BASE1 TO CSV SUPPLIER ENTRY CORP DATA
-- Author       : Sakuma Eiji
-- Modified by  : 
-- Date         : 2008/09/17
-- DBMS         : Oracle 10g
-- 
set linesize 10000
set pagesize 0
set trimspool on
set feedback off

spool /home/sag/daf/import_csv/importSupCORP.csv


--繝・・繧ｿ繧貞・蜉・
select ''''||CC.corp_id||''''||','||''''||
null||''''||','||''''||
CC.corp_name||''''||','||''''||
'SUP'||''''||','||''''||
CC.TDB_CORP_CODE||''''||','||''''||
null||''''||','||''''||
0||'''' 
from customer_corp@BASE1 CC left join m_corp C on CC.CORP_ID=C.CORP_CD  
where CC.corp_id >= 40000000 and CC.corp_id <= 49999999 AND C.CORP_CD is null;

spool off;

exit;

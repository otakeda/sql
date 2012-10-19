-- Project Name : DeeCorp post
-- Author       : Sakuma Eiji
-- Modified by  : 
-- Date         : 2007/7/27
-- DBMS         : Oracle 10g
-- 
set linesize 10000
set pagesize 0
set trimspool on
set feedback off
set autoprint off
set heading off
set pagesize 0
set verify off
spool /home/MM/csv/m_title_20000306.csv

--繝・・繧ｿ繧貞・蜉・
SELECT
    '"'||POST_ID||'",'||
    '"'||POST_NAME||'"' as AA
from post
WHERE
    delete_flag='0'
order by post_id;

spool off;

exit;

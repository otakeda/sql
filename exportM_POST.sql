-- Project Name : DeeCorp IF
-- Author       : Eiji Sakuma
-- Modified by  : 
-- Date         : 2008/10/28
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
spool /home/MM/csv/&2

--データを出力
select
  '"' || replace(M_POST.POST_CD, '"', '\"') || '",' ||
  '"' || replace(M_POST.POST_NAME, '"', '\"') || '"'
from
  M_POST
where
  M_POST.CORP_CD = '&1' 
order by M_POST.CORP_CD, M_POST.POST_CD;

spool off;

exit;

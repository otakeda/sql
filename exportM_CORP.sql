-- Project Name : DeeCorp IF
-- Author       : Eiji Sakuma
-- Modified by  : 
-- Date         : 2006/12/11
-- DBMS         : Oracle 10g
-- 
set linesize 10000
set pagesize 0
set trimspool on
set feedback off

spool /home/sag/daf/CORP_LIST.tmp

--繝・・繧ｿ繧貞・蜉・
select distinct 
  M_DEPT.CORP_CD
from
  PORTAL_USER.M_DEPT
    inner join PORTAL_USER.M_CORP on
      M_DEPT.CORP_CD = M_CORP.CORP_CD
where M_CORP.CSV_FLG='1';

spool off;


exit;

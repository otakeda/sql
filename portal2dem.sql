-- Project Name : portal2dem
-- Author       : eiji sakuma
-- Modified by  : 
-- Date         : 2008/02/28
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

spool /home/sag/daf/import_csv/portal2dem.csv


--データを出力
select
  M_EMP.EMP_CD||','||
  M_EMP.EMP_NO||','||
  M_EMP.DEE_USER_ID||','||
  NVL(M_EMP.DEE_PASSWORD,'DUMMY')||','||
  REPLACE(M_DEPT.DEPT_NAME,',','')||','||
  REPLACE(M_DEPT.DEPT_NAME_KANA,',','')||','||
  M_EMP.TEL||','||
  M_EMP.FAX||','||
  REPLACE(M_EMP.EMP_NAME,',','')||','||
  REPLACE(M_EMP.EMP_NAME_KANA,',','')||','||
  M_EMP_DEPT.POST_CD||','||
  M_EMP.EXTENSION||','||
  REPLACE(M_EMP.EMAIL,',','')||','||
  M_CORP.TDB_CORP_CD||','||
  M_DEPT.DEPT_CD||','||
  M_CORP.CORP_CD||','||
  decode(M_EMP_DEPT.DELETE_FLAG, '1', '0', '1')||','||
  M_EMP_DEPT.HEAD_FLG||','||
  decode(DEM.SUBSYSTEM_CD,'DEM',NULL,'DEMa','DEMa')||','||
  '1'
from
    PORTAL_USER.M_EMP_DEPT
    left outer join PORTAL_USER.M_CORP on
      M_EMP_DEPT.CORP_CD = M_CORP.CORP_CD
    left outer join PORTAL_USER.M_SUBSYSTEM_ACCESS DEM on
      DEM.EMP_CD = M_EMP_DEPT.EMP_CD and
      DEM.CORP_CD = M_EMP_DEPT.CORP_CD and
      DEM.DEPT_CD = M_EMP_DEPT.DEPT_CD and 
      DEM.SUBSYSTEM_CD IN ('DEMa')
    INNER join PORTAL_USER.M_DEPT on
      M_EMP_DEPT.CORP_CD = M_DEPT.CORP_CD and
      M_EMP_DEPT.DEPT_CD = M_DEPT.DEPT_CD
    left outer join PORTAL_USER.M_EMP on
      M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD
where
M_CORP.CORP_CD IN (select distinct corp_cd 
from m_subsystem_access
where SUBSYSTEM_CD ='DEM' and access_flg='1' and corp_cd NOT IN ('democorp','baseball','testcorp')) AND M_EMP_DEPT.PRIMARY_FLG='1'  AND M_EMP.EMP_NO is not null  and M_EMP_DEPT.DELETE_FLAG<>'1'  
  AND M_EMP_DEPT.BUY_SUP_DIV = '1'
order by M_EMP.EMP_CD;

exit;

spool off;
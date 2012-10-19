-- Project Name : DeeCorp IF
-- Author       : Hiroshi Maruoka
-- Modified by  : 
-- Date         : 2006/12/11
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

--ヘッダを�E劁E
select
  '"絁E��コーチE,"絁E��名称","階層","上位絁E��コーチE,"管琁E��E��員番号"'
from dual;

--チE�Eタを�E劁E
select
  '"' || replace(M_DEPT.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(M_DEPT.DEPT_NAME, '"', '\"') || '",' ||
  '"' || M_DEPT.TIER || '",' ||
  '"' || replace(M_DEPT.UPPER_DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(M_EMP.EMP_NO, '"', '\"') || '"'
from
  PORTAL_USER.M_DEPT
    left join PORTAL_USER.M_EMP_DEPT on
      M_DEPT.CORP_CD = M_EMP_DEPT.CORP_CD AND
      M_DEPT.DEPT_CD = M_EMP_DEPT.DEPT_CD AND M_DEPT.CORP_CD = '&1' and M_EMP_DEPT.DELETE_FLAG = '0'
    left join PORTAL_USER.M_EMP on
      M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD
where
  M_EMP_DEPT.HEAD_FLG = '1' and
  length(trim(M_DEPT.DEPT_NAME)) is not null and
  M_DEPT.CORP_CD = '&1' and
  M_DEPT.TIER is not null and
  ((M_DEPT.CORP_CD = '&1' and M_DEPT.tier = 0) or M_DEPT.UPPER_DEPT_CD is not null)
order by M_DEPT.CORP_CD, M_DEPT.DEPT_CD, M_EMP.EMP_NO;

spool off;

--エラーを�E劁E
select CHR(13) || '------------------------------------------------------------' from dual;
select
  'The value is not set to an indispensable item. [' ||
  'CORP_CD=' || M_DEPT.CORP_CD || ', ' ||
  'DEPT_CD=' || M_DEPT.DEPT_CD || ', ' ||
  'UPPER_DEPT_CD=' || M_DEPT.UPPER_DEPT_CD || ', ' ||
  'DEPT_NAME=' || M_DEPT.DEPT_NAME || ', ' ||
  'EMP_NO=' || M_EMP.EMP_NO || ', ' ||
  'TIER=' || M_DEPT.TIER || ']'
from
  PORTAL_USER.M_DEPT
    inner join PORTAL_USER.M_EMP_DEPT on
      M_DEPT.CORP_CD = M_EMP_DEPT.CORP_CD AND
      M_DEPT.DEPT_CD = M_EMP_DEPT.DEPT_CD AND M_DEPT.CORP_CD = '&1'
    left outer join PORTAL_USER.M_EMP on
      M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD
where
  M_EMP_DEPT.HEAD_FLG = '1' and
  (length(trim(M_DEPT.DEPT_NAME)) is null or 
   M_DEPT.TIER is null or 
   M_EMP.EMP_NO is null or
   not(M_DEPT.CORP_CD = '&1' and M_DEPT.DEPT_CD = '90000003')  AND
   M_DEPT.UPPER_DEPT_CD is null
  )
order by M_DEPT.CORP_CD, M_DEPT.DEPT_CD, M_EMP.EMP_NO;


exit;

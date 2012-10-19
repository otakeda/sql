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


--データを出力
SELECT DISTINCT
    EMP_NO
FROM
    M_EMP_DEPT ,
    M_EMP
WHERE
    M_EMP_DEPT.EMP_CD =  M_EMP.EMP_CD(+) AND
    CORP_CD='&1' AND
    M_EMP.DELETE_FLAG='1' AND
    M_EMP.ACCOUNT_TYPE='0';

spool off;

--エラーを出力
select CHR(13) || '------------------------------------------------------------' from dual;
select
  'Chief doesn''t exist [' ||
  'EMP_CD=' || M_EMP.EMP_CD || ', ' ||
  'EMP_NO=' || M_EMP.EMP_NO || ', ' ||
  'EMP_NAME=' || M_EMP.EMP_NAME || ']'
from
  PORTAL_USER.M_EMP 
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD, EMP_CD, PRIMARY_FLG, DEPT_CD) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          ) TMP_USER_IDX
        where
          IDX = 1
      ) TMP_USER1 on
        M_EMP.EMP_CD = TMP_USER1.EMP_CD
where
  TMP_USER1.PRIMARY_FLG = '2'
order by
  M_EMP.EMP_NO;

exit;

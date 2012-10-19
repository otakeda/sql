-- Project Name : IF TO CSV SBM DEPT DATA
-- Author       : Sakuma Eiji
-- Modified by  : 
-- Date         : 2008/02/13
-- DBMS         : Oracle 10g
-- 
set linesize 10000
set pagesize 0
set trimspool on
set feedback off

spool /home/sag/daf/import_csv/importDEPT20000306.csv


--データを出力
    select
        ''''||TRIM(TO_CHAR(BASE.DEPT_CODE))||''''||','||''''||
        TRIM(DECODE(TO_CHAR(NVL(UPDEPT.DEPT_CODE,40001)),TO_CHAR(TRIM(BASE.DEPT_CODE)),NULL,TO_CHAR(NVL(TRIM(UPDEPT.DEPT_CODE),40001))))||''''||','||''''||
        NVL(D.D_DEPT_NAME,BASE.DEPT_NAME)||''''||','||''''||
        null||''''||','||''''||
        TO_CHAR(DECODE(BASE.DEPT_ID,40001,0,BASE.LAYER))||''''
    from
        DEPT@base1 BASE,
        DEPT@base1 UPDEPT,
        (select c.Dept_ID,A.Dept_Name||' '||b.Dept_name||' '||C.Dept_Name AS D_DEPT_NAME
        from DEPT@base1 A ,DEPT@base1 B,DEPT@base1 C
        WHERE C.UPPER_DEPT_ID = B.DEPT_ID(+) AND 
              B.UPPER_DEPT_ID = A.DEPT_ID(+)  AND
              A.DELETE_FLAG = '0' AND 
              A.LAYER = '1' AND 
              B.DELETE_FLAG = '0' AND 
              B.LAYER = '2' AND 
              C.DELETE_FLAG = '0' AND 
              C.LAYER = '3' 
        UNION 
        select B.Dept_ID,A.Dept_Name||' '||b.Dept_name AS D_DEPT_NAME
        from DEPT@base1 A ,DEPT@base1 B
        WHERE 
              B.UPPER_DEPT_ID = A.DEPT_ID(+)  AND
              A.DELETE_FLAG = '0' AND 
              A.LAYER = '1' AND 
              B.DELETE_FLAG = '0' AND 
              B.LAYER = '2'
        UNION 
        select A.Dept_ID,A.Dept_Name AS D_DEPT_NAME
        from DEPT@base1 A 
        WHERE 
              A.DELETE_FLAG = '0' AND 
              A.LAYER = '1' ) D
    where BASE.delete_flag='0' AND (UPDEPT.delete_flag='0' or (BASE.UPPER_DEPT_ID IS NULL) ) AND
          BASE.UPPER_DEPT_ID = UPDEPT.DEPT_ID(+) AND
          BASE.DEPT_ID = D.DEPT_ID(+) AND
          BASE.CHIEF_EMP_ID IS NOT NULL 
    order by
        BASE.DEPT_CODE;

spool off;

exit;

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

spool /home/sag/daf/import_csv/importDEPT21000188.csv


--データを出力
    select
        ''''||DEPT_ID||''''||','||''''||
        UPPER_DEPT_CD||''''||','||''''||
        DEPT_NAME||''''||','||''''||
        null||''''||','||''''||
        decode(TIER, 'E', '0', TIER)||''''
    from
        M_HR_DEPT
    order by
        DEPT_ID;

spool off;

exit;

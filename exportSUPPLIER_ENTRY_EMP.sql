-- Project Name : BASE1 TO CSV SUPPLIER ENTRY EMP DATA
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
SELECT
    ''''||CE.cust_emp_id||''''||','||''''||
    CE.EMP_NAME||''''||','||''''||
    CE.EMP_NAME_KANA||''''||','||''''||
    CE.login_id||''''||','||''''||
    CE.password||''''||','||''''||
    CE.email||''''||','||''''||
    CE.tel||''''||','||''''||
    null||''''||','||''''||
    CE.fax||''''||','||''''||
    1||''''||','||''''||
    1||''''||','||''''||
    PO.post_cd||''''||','||''''||
    substr(CUST_DEPT_ID,9,4)||''''||','||''''||
    0||''''||','||''''||
    0||''''||','||''''||
    0||''''
FROM
    mst_ms.cust_emp@BASE1 CE
      left join (SELECT
                       CORP_ID,
                       trim(to_char(row_number() over (partition by CORP_ID order by  CORP_ID DESC),'00000000')) POST_CD,
                       POST
                 FROM
                     mst_ms.cust_emp@BASE1
                 WHERE
                      CORP_ID LIKE '4%' AND
                      POST IS NOt NULL
                 ) PO ON CE.POST = PO.POST AND CE.CORP_ID = PO.CORP_ID
WHERE
    CE.CORP_ID LIKE '&1';
spool off;

exit;

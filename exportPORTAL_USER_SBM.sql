-- Project Name : IF TO CSV SBM EMPLOYEE DATA
-- Author       : Eiji Sakuma
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

spool /home/sag/daf/import_csv/importEMP21000188.csv

--データを出力
        SELECT
            ''''||HR_USER.MM_USER_ID||''''||','||''''||
            HR_USER.KANJI_NAME||''''||','||''''||
            HR_USER.KANA_NAME||''''||','||''''||
            HR_USER.MAIL_ADDR||''''||','||''''||
            NULL||''''||','||''''||
            NULL||''''||','||''''||
            decode(HR_DEPT.MANAGER_USE_ID,HR_USER.MM_USER_ID,'1','0')||''''||','||''''||
            DECODE(HR_USER.INTERLOCKING_TYPE,'1','1','2','0')||''''||','||''''||
            HR_USER.TITLE_CD||''''||','||''''||
            HR_USER.DEPT_CD||''''||','||''''||
            CASE WHEN HR_USER.INTERLOCKING_TYPE='1' AND INSTR(HR_DEPT.DEPT_NAME,'財務統括購買本部') <> 0 THEN '1'
                 ELSE '0'
            END||''''||','||''''||
            '0'||''''
        FROM
            (SELECT
                M_HR_USER.MM_USER_ID,
                M_HR_USER.FIRST_NAME || ' ' || M_HR_USER.LAST_NAME as KANJI_NAME,
                null as KANA_NAME,
                M_HR_USER.MAIL_ADDR,
                INTERLOCKING_TYPE as INTERLOCKING_TYPE,
                M_HR_USER.TITLE_CD,
                M_HR_USER.DEPT_CD,
                sysdate as UPDATEDATE
            FROM
                M_HR_USER
            UNION      
            SELECT
                M_HR_TEMP_USER.MM_USER_ID,
                nvl(trim(M_HR_TEMP_USER.FIRST_NAME_KANJI || ' ' || M_HR_TEMP_USER.LAST_NAME_KANJI), M_HR_TEMP_USER.FIRST_NAME_HKANA || ' ' || M_HR_TEMP_USER.LAST_NAME_HKANA) as KANJI_NAME,
                M_HR_TEMP_USER.FIRST_NAME_HKANA || ' ' || M_HR_TEMP_USER.LAST_NAME_HKANA as KANA_NAME,
                M_HR_TEMP_USER.MAIL_ADDR,
                '1' as INTERLOCKING_TYPE,
                M_HR_TEMP_USER.TITLE_CD,
                M_HR_TEMP_USER.DEPT_CD,
                sysdate as UPDATEDATE
            FROM
                M_HR_TEMP_USER
                ) HR_USER,
            M_HR_DEPT HR_DEPT
        WHERE
            HR_USER.DEPT_CD = HR_DEPT.DEPT_ID(+)             
        order by HR_USER.MM_USER_ID,HR_USER.INTERLOCKING_TYPE,HR_DEPT.DEPT_ID;

spool off;


exit;

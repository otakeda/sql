set serveroutput on size 1000000;
set lines 200;
set trimspool on
VARIABLE retcode NUMBER;
EXEC :retcode := -1;
DECLARE
  /* Variable for Error Message *********************************************************/
  TYPE tArray1000 IS VARRAY(10000) OF VARCHAR2(1000) NOT NULL;
  vSystemErrorArray tArray1000 := tArray1000();

  TYPE tArray50 IS VARRAY(10000) OF VARCHAR2(50) NOT NULL;
  vErrorNotExistDeptCdArray tArray50 := tArray50();
  vErrorInterLockingType1 tArray50 := tArray50();
  CNST_CORP_CD CONSTANT VARCHAR(8) := '21000188'; 
  
  vTier5_count_before NUMBER := 0;
  vTier1_count        NUMBER := 0;
  vTier2_count        NUMBER := 0;
  vTier3_count        NUMBER := 0;
  vTier4_count        NUMBER := 0;
  vTier5_count        NUMBER := 0;
  vTier6_count        NUMBER := 0;
  vTier7_count        NUMBER := 0;

  /* Declare UserException **************************************************************/
  SRC_TABLE_IS_EMPTY            EXCEPTION;
BEGIN


/* 階層 = 5 組織のカウント */
SELECT COUNT(*) INTO vTier5_count_before FROM WK_IMPORT_DEPT WHERE TIER = '5';

dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier5_count_before = ' || vTier5_count_before );

/* 階層 = 5 組織が 1 以下の場合、階層 は まだ UPDATE されていないため、UPDATE 実施 （＝繰り返し UPDATE を避けたい）*/
IF vTier5_count_before <= 1 THEN

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' UPDATE Master(WK_IMPORT_DEPT.TIER)' );
  UPDATE WK_IMPORT_DEPT SET TIER = '5'
  WHERE TIER = '4';

  UPDATE WK_IMPORT_DEPT SET TIER = '4'
  WHERE TIER = '3';

END IF;

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' DELETE Master(WK_IMPORT_DEPT)' );

        DELETE FROM WK_IMPORT_DEPT WHERE DEPT_CD IN (
          '1022974A', '1033084A', '1033084B', '1033084C', '1024918A'
        , '1023346B', '1024977B'
        , '1037329A', '1037329B', '1037329C', '1037329D', '1037269A', '1037269B', '1037253A', '1038901A', '1037173A', '1037173B'
        , '1024847A', '1028410A', '1024931A', '1024931B', '1024977A'
        , '1028280A', '1025241A', '1025241B', '1025880A', '1026483A', '1026483B'
        , '1025795B', '1023017A', '1023017B', '1032848A', '1032848B', '1032848C', '1032848D', '1026709A'
        , '9000000A', '9000000B', '9000000C', '9000000D', '9000000E', '9000000F', '9000000G', '9000000H', '9000000Z', '1010752A');

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 01A)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1033084A',
            '営業統括_STG',
            '1',
            '10223880'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 01B)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1033084B',
            '営業統括_STG',
            '1',
            '10223880'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 01C)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1033084C',
            '営業統括_STG',
            '1',
            '10223880'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 02)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0310A)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037329A',
            '商品統括プロダクト・マーケティング本部副本部',
            '3',
            '10373290'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0310B)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037329B',
            '商品統括プロダクト・マーケティング本部副本部',
            '3',
            '10373290'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0310C)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037329C',
            '商品統括プロダクト・マーケティング本部副本部',
            '3',
            '10373290'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0310D)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037329D',
            '商品統括プロダクト・マーケティング本部副本部',
            '3',
            '10373290'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0320A)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037269A',
            '商品統括プロダクト・サービス本部副本部',
            '3',
            '10372690'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0320B)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037269B',
            '商品統括プロダクト・サービス本部副本部',
            '3',
            '10372690'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0330)' );
/*
        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037253A',
            '商品統括JIL推進本部副本部',
            '3',
            '10372530'
        );
*/
        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1038901A',
            '商品統括海外事業推進本部副本部',
            '3',
            '10389010'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0340A)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037173A',
            '技術統括モバイル・ソリューション本部副本部',
            '3',
            '10371730'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 0340B)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1037173B',
            '技術統括モバイル・ソリューション本部副本部',
            '3',
            '10371730'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 04)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 05A)' );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1024931A',
            '技術統括ネットワーク本部副本部',
            '3',
            '10249310'
        );

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '1028410A',
            '人事総務統括総務本部副本部',
            '3',
            '10284100'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 05B)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 06)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 07)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 08)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 09)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 10)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 11A)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 11B)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 12)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 13)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 13A)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 13B)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 13C)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 13D)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 14)' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 16)' );      

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000A',
            '■電子決裁用チーム',
            '1',
            '10223880'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 17)' );      

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000B',
            '所属不明統括',
            '1',
            '10223880'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 18)' );      
        
        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000C',
            '所属不明本部',
            '2',
            '9000000B'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 19)' );      
        
        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000D',
            '所属不明副本部',
            '3',
            '9000000C'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 20)' );      
        
        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000E',
            '所属不明統括部',
            '4',
            '9000000D'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 21)' );      
        
        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000F',
            '所属不明部',
            '5',
            '9000000E'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 22)' );      
        
        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000G',
            '要システム登録グループ',
            '6',
            '9000000F'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 23)' );      

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000H',
            '社員番号が変更されたユーザ',
            '1',
            '10223880'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_DEPT 24)' );      

        INSERT INTO WK_IMPORT_DEPT (
        DEPT_CD,
        DEPT_NAME,
        TIER,
        UPPER_DEPT_CD) 
        VALUES(
            '9000000Z',
            'ディーコープ株式会社',
            '1',
            '10223880'
        );



  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' UPDATE Master(WK_IMPORT_DEPT)' );

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = null
        WHERE DEPT_CD = '10223880';
        
        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1033084A' 
        WHERE DEPT_CD IN ('10330750');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1033084B' 
        WHERE DEPT_CD IN ('10331170');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1033084C' 
        WHERE DEPT_CD IN ('10329030');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037329A' 
        WHERE DEPT_CD IN ('10374000', '10374100');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037329B' 
        WHERE DEPT_CD IN ('10373300', '10373920');
/*
        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037329C' 
        WHERE DEPT_CD IN ('10373510', '10373600');
*/
        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037329C' 
        WHERE DEPT_CD IN ('10388800');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037329D' 
        WHERE DEPT_CD IN ('10373670');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037269A' 
        WHERE DEPT_CD IN ('10372890', '10372810', '10383790', '10383730');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037269B' 
        WHERE DEPT_CD IN ('10372700');
/*
        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037253A' 
        WHERE DEPT_CD IN ('10372540', '10372640');
*/
        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1038901A' 
        WHERE DEPT_CD IN ('10389020', '10389120');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037173A' 
        WHERE DEPT_CD IN ('10372000');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1037173B' 
        WHERE DEPT_CD IN ('10372090', '10368890', '10383360');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1024931A' 
        WHERE DEPT_CD IN ('10360790', '10360820', '10360860', '10360900', '10360930', '10360970', '10361000', '10361040', '10361070', '10361100', '10361130', '10361170', '10361220', '10361260', '10361030'
                         ,'10371370' , '10371450', '10371410', '10371520');

        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '1028410A' 
        WHERE DEPT_CD IN ('10284110', '10310620', '10284160', '10284210', '10284230', '10284240');
/*
        UPDATE WK_IMPORT_DEPT SET UPPER_DEPT_CD = '10252410' 
        WHERE DEPT_CD IN ('10383370');
*/


  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' DELETE Master(WK_IMPORT_EMP)' );
  
        DELETE FROM WK_IMPORT_EMP WHERE DEPT_CD IN (  
          '1022974A', '1033084A', '1033084B', '1033084C', '1024918A'
        , '1023346B', '1024977B'
        , '1037329A', '1037329B', '1037329C', '1037329D', '1037269A', '1037269B', '1037253A', '1038901A', '1037173A', '1037173B'
        , '1024847A', '1028410A', '1024931A', '1024931B', '1024977A'
        , '1028280A', '1025241A', '1025241B', '1025880A', '1026483A', '1026483B'
        , '1025795B', '1023017A', '1023017B', '1032848A', '1032848B', '1032848C', '1032848D', '1026709A'
        , '9000000A', '9000000B', '9000000C', '9000000D', '9000000E', '9000000F', '9000000G', '9000000H', '9000000Z', '1010752A');



  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' UPDATE Master(WK_IMPORT_EMP) DEPT EXISTS USER ' );

--不正部署更新
update WK_IMPORT_EMP set WK_IMPORT_EMP.DEPT_CD='9000000G' 
where exists(SELECT
                1
            FROM
                WK_IMPORT_EMP hru
                LEFT JOIN WK_IMPORT_DEPT on WK_IMPORT_DEPT.DEPT_CD = hru.DEPT_CD
where WK_IMPORT_DEPT.DEPT_CD is null
);



  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 1' );

        INSERT INTO WK_IMPORT_EMP 
        select 
               EMP_NO,
               EMP_NAME,
               EMP_NAME_KANA,
               EMAIL,
               null AS TEL,
               null AS EXTENSION,
               '1' AS HEAD_FLG,
               '0' AS PRIMARY_FLG,
               POST_CD,
               CASE
                    WHEN EMP_NO='0106044' THEN '1033084A'
                    WHEN EMP_NO='0106043' THEN '1033084B'
                    WHEN EMP_NO='4109820' THEN '1033084C'
                    WHEN EMP_NO='4360056' THEN '1037329A'
                    WHEN EMP_NO='0306017' THEN '1037329B'
                    WHEN EMP_NO='4335118' THEN '1037329C'
                    WHEN EMP_NO='4111814' THEN '1037329D'
                    WHEN EMP_NO='1106803' THEN '1037269A'
                    WHEN EMP_NO='4107120' THEN '1038901A'
                    WHEN EMP_NO='4107184' THEN '1037173A'
                    WHEN EMP_NO='4107397' THEN '1037173B'
                    WHEN EMP_NO='4107258' THEN '1024931A'
                    WHEN EMP_NO='4330403' THEN '1028410A'
                    ELSE DEPT_CD
               END DEPT_CD,
               '0' AS ADMIN_FLG,
               '0' AS REPORT_FLG,
               '1' AS DAF_FLG,
               '0' AS DEM_FLG
        FROM WK_IMPORT_EMP
        WHERE EMP_NO IN ('0106044', '0106043', '4109820', '4360056', '0306017', '4335118', '4111814', '1106803', '4107120', '4107184', '4107397', '4107258', '4330403')
        and PRIMARY_FLG='1';



  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 2' );

        INSERT INTO WK_IMPORT_EMP 
        select 
               EMP_NO,
               EMP_NAME,
               EMP_NAME_KANA,
               EMAIL,
               null AS TEL,
               null AS EXTENSION,
               '1' AS HEAD_FLG,
               '0' AS PRIMARY_FLG,
               POST_CD,
               CASE
                    WHEN EMP_NO='4360056' THEN '1037269B'
                    ELSE DEPT_CD
               END DEPT_CD,
               '0' AS ADMIN_FLG,
               '0' AS REPORT_FLG,
               '1' AS DAF_FLG,
               '0' AS DEM_FLG
        FROM WK_IMPORT_EMP
        WHERE EMP_NO IN ('4360056')
        and PRIMARY_FLG='1';

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' UPDATE Master(WK_IMPORT_EMP) ... 1' );

        UPDATE m_emp_dept set dept_cd ='9000000A' where corp_cd=CNST_CORP_CD and EMP_CD IN (select emp_cd from m_emp where emp_name like '■%');



  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 3' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'unknown',
        '所属不明組織長',
        '9000000B',
        '1',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 4' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'unknown',
        '所属不明組織長',
        '9000000C',
        '0',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 5' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'unknown',
        '所属不明組織長',
        '9000000D',
        '0',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 6' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'unknown',
        '所属不明組織長',
        '9000000E',
        '0',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 7' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'unknown',
        '所属不明組織長',
        '9000000F',
        '0',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 8' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'unknown',
        '所属不明組織長',
        '9000000G',
        '0',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 9' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'dee_sys',
        'Dee シス管',
        '9000000H',
        '0',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' INSERT Master(WK_IMPORT_EMP) ... 10' );

        INSERT INTO WK_IMPORT_EMP (
        EMP_NO,
        EMP_NAME,
        DEPT_CD,
        PRIMARY_FLG,
        POST_CD,
        EMAIL,
        HEAD_FLG,
        ADMIN_FLG,
        REPORT_FLG,
        DAF_FLG,
        DEM_FLG
        )
        VALUES
         (
        'dee_sys',
        'Dee シス管',
        '9000000Z',
        '0',
        '9999',
        'yukihiro_tanaka@deecorp.jp',
        '1',
        '0',
        '0',
        '1',
        '0'
        );



  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' UPDATE Master(WK_IMPORT_EMP) ... 2' );

        UPDATE
        	WK_IMPORT_EMP
        SET
        	DEPT_CD = '9000000G'
        WHERE
        	EMP_NO IN
        		(
        			select
        				EMP_NO
        			from
        				WK_IMPORT_EMP,
        				WK_IMPORT_DEPT 
        			where
        				WK_IMPORT_EMP.dept_cd = WK_IMPORT_DEPT.DEPT_CD (+)
        			and WK_IMPORT_DEPT.DEPT_CD is null
        		);
        
        UPDATE WK_IMPORT_EMP set POST_CD = '9999' where POST_CD is null;



  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' UPDATE Master(WK_IMPORT_EMP) ... 3' );

  UPDATE WK_IMPORT_EMP SET EMAIL = 'zaimu-kessaisho.jp@mb.softbank.co.jp' WHERE EMP_NO = '0106038';

  UPDATE WK_IMPORT_EMP SET EMAIL = 'ntest@deecorp.jp';

  commit;

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' COMMIT Master(WK_IMPORT_EMP) ' );

  /* 階層 = n 組織のカウント */
  SELECT COUNT(*) INTO vTier1_count FROM WK_IMPORT_DEPT WHERE TIER = '1';
  SELECT COUNT(*) INTO vTier2_count FROM WK_IMPORT_DEPT WHERE TIER = '2';
  SELECT COUNT(*) INTO vTier3_count FROM WK_IMPORT_DEPT WHERE TIER = '3';
  SELECT COUNT(*) INTO vTier4_count FROM WK_IMPORT_DEPT WHERE TIER = '4';
  SELECT COUNT(*) INTO vTier5_count FROM WK_IMPORT_DEPT WHERE TIER = '5';
  SELECT COUNT(*) INTO vTier6_count FROM WK_IMPORT_DEPT WHERE TIER = '6';
  SELECT COUNT(*) INTO vTier7_count FROM WK_IMPORT_DEPT WHERE TIER = '7';

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier1_count = ' || vTier1_count );
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier2_count = ' || vTier2_count );
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier3_count = ' || vTier3_count );
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier4_count = ' || vTier4_count );
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier5_count = ' || vTier5_count );
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier6_count = ' || vTier6_count );
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' vTier7_count = ' || vTier7_count );

  :retcode := 0;

EXCEPTION
  WHEN others THEN
    sys.DBMS_OUTPUT.PUT_LINE ('ORA- ' || SQLCODE );
    sys.DBMS_OUTPUT.PUT_LINE ('ErrorReason: ' || SQLERRM );
    sys.DBMS_OUTPUT.PUT_LINE ( ' -- ERROR ---------------------------------------------------------------------------------- ' );
    sys.dbms_output.put_line ( 'rollback.' );
    rollback;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
    vSystemErrorArray.DELETE;
END;

/
exit :retcode;

-- 
-- Project Name : CSV TO PORTAL
-- Author       : eiji sakuma
-- Modified by  : 
-- Date         : 2008/02/12
-- DBMS         : Oracle 10g
-- 
set serveroutput on size 1000000;
set lines 200;
set trimspool on

VARIABLE retcode NUMBER;
EXEC :retcode := -1;

-- PL/SQL part begins here
DECLARE
  /* Variable for Error Message *********************************************************/
  TYPE tArray1000 IS VARRAY(10000) OF VARCHAR2(1000) NOT NULL;
  vSystemErrorArray tArray1000 := tArray1000();

  TYPE tArray50 IS VARRAY(10000) OF VARCHAR2(50) NOT NULL;
  vErrorNotExistDeptCdArray tArray50 := tArray50();
  vErrorInterLockingType1 tArray50 := tArray50();

  /* Declare UserException **************************************************************/
  SRC_TABLE_IS_EMPTY            EXCEPTION;
  NOT_EXIST_DEPT_CD             EXCEPTION;  /* The dept_cd where it does not exist */
  INTERLOCKING_TYPE_1_NOT_FOUND EXCEPTION;  /* Exception when chief doesn't exist  */

  MAIN_MANAGE_1_OVER            EXCEPTION;  /* There is more than one main management.  */
  NOTEXIST_SOURCE_DATA          EXCEPTION;  /* Former forwarded to the transfer because there is no data  */
  NOTEXIST_DEPT                 EXCEPTION;  /* There tissue does not match data  */


  /* Declare Constst ********************************************************************/
  BULK_SIZE CONSTANT    NUMBER := 100; 
  CNST_CORP_CD CONSTANT VARCHAR(8) := '&1'; 

  /* Other variables ********************************************************************/
  var_old_emp_no  VARCHAR(20) := ' ';
  var_emp_cd      VARCHAR(10);
  var_head_flg    CHAR(1) := '0';     /* 1 when oneself is head of organization. 0 when other */
  var_notexist_dept_cnt	      PLS_INTEGER := 0;     /* Belong to a nonexistent department employees Count */
  var_notexist_if_cnt	      PLS_INTEGER := 0;     /* Belong to a nonexistent department employees Count */
  var_main_manage_cnt	      PLS_INTEGER := 0;     /* Belong to a nonexistent department employees Count */
  var_system_err_index        PLS_INTEGER := 0;  /* System Error Array Index                  */
  var_err_cnt_dept_not_exist  PLS_INTEGER := 0;  /* Error number                              */
  var_err_cnt_interlocking    PLS_INTEGER := 0;  /* Error number                              */
  var_err_cnt                 PLS_INTEGER := 0;  /* Error number                              */

  var_insert_cnt_dept     PLS_INTEGER := 0;  /* Record registration number to M_DEPT                  */
  var_insert_cnt_post     PLS_INTEGER := 0;  /* Record registration number to M_POST                  */
  var_insert_cnt_emp      PLS_INTEGER := 0;  /* Record registration number to M_EMP                   */  
  var_update_cnt_emp      PLS_INTEGER := 0;  /* Record update number to M_EMP                         */  
  var_insert_cnt_emp_dept PLS_INTEGER := 0;  /* Record registration number to M_EMP_DEPT              */
  var_update_cnt_emp_dept PLS_INTEGER := 0;  /* Record update number to M_EMP_DEPT                    */
  var_insert_cnt_dem      PLS_INTEGER := 0;  /* Record registration number to M_SUBSYSTEM_ACCESS(DEM) */
/* MODIFY START   2007/07/18 SAKUMA */
  var_insert_cnt_dema     PLS_INTEGER := 0;  /* Record registration number to M_SUBSYSTEM_ACCESS(DEMa) */
  var_insert_cnt_kbb      PLS_INTEGER := 0;  /* Record registration number to M_SUBSYSTEM_ACCESS(KBB) */
  var_insert_cnt_dsv      PLS_INTEGER := 0;  /* Record registration number to M_SUBSYSTEM_ACCESS(DSV) */
  var_insert_cnt_dips     PLS_INTEGER := 0;  /* Record registration number to M_SUBSYSTEM_ACCESS(DIPS) */
/* MODIFY END   2007/07/18 SAKUMA */
  --var_update_cnt_dem      PLS_INTEGER := 0;  /* Record update number to M_SUBSYSTEM_ACCESS(DEM)       */
  var_insert_cnt_daf      PLS_INTEGER := 0;  /* Record registration number to M_SUBSYSTEM_ACCESS(DAF) */
  --var_update_cnt_daf      PLS_INTEGER := 0;  /* Record update number to M_SUBSYSTEM_ACCESS(DAF)       */
/* MODIFY START   2007/07/26 SAKUMA */
  var_buy_cnt             NUMBER(10,0);  /* Record Count to Buying Dept  */
/* MODIFY END   2007/07/26 SAKUMA */

  /* Declare Cursor **********************************************************************/
  CURSOR cMHrPost IS 
    select
       CNST_CORP_CD as CORP_CD,
       POST_CD,
       POST_NAME,
       NULL AS UPDATE_EMP_CD,
       sysdate as REGISTER_DATE,
       sysdate as UPDATE_DATE
from wk_import_post
order by
        POST_CD;
  TYPE tMHrPost IS TABLE OF cMHrPost%ROWTYPE INDEX BY BINARY_INTEGER;
  vMHrPost tMHrPost;

  CURSOR cMHrDept IS 
    select
       CNST_CORP_CD as CORP_CD,
       DEPT_CD,
       UPPER_DEPT_CD,
       DEPT_NAME,
       DEPT_NAME_KANA,
       TIER,
       NULL AS UPDATE_EMP_CD,
       sysdate as REGISTER_DATE,
       sysdate as UPDATE_DATE,
       '0' AS COALITION_FLAG
from wk_import_dept
order by
        DEPT_CD;
  TYPE tMHrDept IS TABLE OF cMHrDept%ROWTYPE INDEX BY BINARY_INTEGER;
  vMHrDept tMHrDept;

/* MODIFY START   2007/07/26 SAKUMA */
  CURSOR cUser IS
        SELECT
            PO_EMP.EMP_CD ,
            HR_USER.EMP_NO,
            HR_USER.EMP_NAME,
            HR_USER.EMP_NAME_KANA,
            HR_USER.DEE_USER_ID,
            LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW (HR_USER.DEE_PASSWORD, 'AL32UTF8'),3))) AS DEE_PASSWORD,
            NVL(HR_USER.EMAIL,PO_EMP.EMAIL) AS MAIL_ADDR,
            HR_USER.TEL,
            HR_USER.EXTENSION AS EXT_NO,
            HR_USER.FAX,
            HEAD_FLG,
            HR_USER.PRIMARY_FLG,
            HR_USER.POST_CD,
            HR_DEPT.DEPT_CD AS IMPORT_DEPT,
            PO_EMP_DEPT.CORP_CD,
            PO_EMP_DEPT.DEPT_CD,
            CASE WHEN PO_EMP.EMP_CD IS NULL     AND HR_USER.PRIMARY_FLG='1' AND HR_DEPT.DEPT_CD IS NOT NULL THEN '1'
                 WHEN PO_EMP.EMP_CD IS NOT NULL AND HR_USER.PRIMARY_FLG='1' AND HR_DEPT.DEPT_CD IS NOT NULL THEN '2'
                 ELSE '0'
            END UP_EMP,
            CASE WHEN PO_EMP_DEPT.DEPT_CD IS NULL     AND HR_DEPT.DEPT_CD IS NOT NULL THEN '1'
                 WHEN PO_EMP_DEPT.DEPT_CD IS NOT NULL AND HR_DEPT.DEPT_CD IS NOT NULL THEN '2'
                 ELSE '0'
            END UP_EMPDEPT,
            CASE WHEN HR_USER.PRIMARY_FLG='1' THEN HR_USER.DEM_FLG
                 ELSE '0'
            END AS UP_DEM,
            HR_USER.DCM_FLG AS UP_DCM,
            HR_USER.DIPS_FLG AS UP_DIPS,
            CASE WHEN HR_DEPT.DEPT_CD IS NULL THEN '1'
                 ELSE '0'
            END MM_ERR,
            SYSDATE AS UPDATEDATE
        FROM
            WK_IMPORT_SUP_EMP HR_USER,
            WK_IMPORT_DEPT HR_DEPT,
            (SELECT DISTINCT
                EMP.EMP_CD,
                EMP.EMP_NO,EMAIL
            FROM
                M_EMP_DEPT EMPDEPT,
                M_EMP EMP
            WHERE
                EMPDEPT.CORP_CD=CNST_CORP_CD AND
                EMPDEPT.EMP_CD = EMP.EMP_CD
            ) PO_EMP,
            (SELECT
                EMPDEPT.CORP_CD,
                EMPDEPT.DEPT_CD,
                EMP.EMP_CD,
                EMP.EMP_NO
            FROM
                M_EMP_DEPT EMPDEPT,
                M_EMP EMP
            WHERE
                EMPDEPT.CORP_CD=CNST_CORP_CD AND
                EMPDEPT.EMP_CD = EMP.EMP_CD
            ) PO_EMP_DEPT
        WHERE
            HR_USER.DEPT_CD = HR_DEPT.DEPT_CD(+)             AND
            HR_USER.EMP_NO = PO_EMP.EMP_NO(+)            AND
            HR_USER.EMP_NO = PO_EMP_DEPT.EMP_NO(+)       AND
            HR_USER.DEPT_CD = PO_EMP_DEPT.DEPT_CD(+)      
        order by HR_USER.EMP_NO ASC,HR_USER.PRIMARY_FLG DESC,HR_DEPT.DEPT_CD DESC;
  TYPE tUser IS TABLE OF cUser%ROWTYPE INDEX BY BINARY_INTEGER;
  vUser tUser;
/* MODIFY END   2007/07/26 SAKUMA */

BEGIN

  dbms_output.enable(1000000);
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' mm_dept_user begins.' );
  dbms_output.put_line ('= M_DEPT =============================================================');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' Portal(M_DEPT) delete.' );
  delete from PORTAL_USER.M_DEPT where CORP_CD = CNST_CORP_CD and COALITION_FLAG = '0';
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(SQL%ROWCOUNT, '9,999,999,990') || ' records deleted.' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' Master(DEE_DEPT_ID) --> Portal(M_DEPT).' );


  OPEN cMHrDept;

  LOOP
    /* The records of "BULK_SIZE" number are acquired from the cursor[cMHrDept], 
       and it sets it in the variable[vMHrDept]. 
       It is the fetch performance measures. */
    FETCH cMHrDept BULK COLLECT INTO vMHrDept LIMIT BULK_SIZE;
    
    IF cMHrDept%rowcount = 0 THEN
      RAISE SRC_TABLE_IS_EMPTY;
    END IF;
    
    FOR i in 1 .. vMHrDept.COUNT
    LOOP
      BEGIN 
        insert into PORTAL_USER.M_DEPT (
          CORP_CD,
          DEPT_CD,
          UPPER_DEPT_CD,
          DEPT_NAME,
          DEPT_NAME_KANA,
          TIER,
          UPDATE_EMP_CD,
          REGISTER_DATE,
          UPDATE_DATE
        ) values (
          vMHrDept(i).CORP_CD,
          vMHrDept(i).DEPT_CD,
          vMHrDept(i).UPPER_DEPT_CD,
          vMHrDept(i).DEPT_NAME,
          vMHrDept(i).DEPT_NAME_KANA,
          vMHrDept(i).TIER,
          vMHrDept(i).UPDATE_EMP_CD,
          vMHrDept(i).REGISTER_DATE,
          vMHrDept(i).UPDATE_DATE
        );
        var_insert_cnt_dept := var_insert_cnt_dept + 1;
        
      EXCEPTION
        WHEN others THEN
          --sys.DBMS_OUTPUT.PUT_LINE('-- ERROR in nest block -------------------------------------------------------------------- ' );
          var_system_err_index := var_system_err_index + 1;
          vSystemErrorArray.EXTEND(1);
          vSystemErrorArray(var_system_err_index) := SQLERRM || ' [CORP_CD:' || vMHrDept(i).CORP_CD || ', DEPT_CD:' || vMHrDept(i).DEPT_CD || ']';
          --sys.DBMS_OUTPUT.PUT_LINE('ORA- ' || SQLCODE );
          --sys.DBMS_OUTPUT.PUT_LINE('ErrorReason: ' || SQLERRM );
          --sys.DBMS_OUTPUT.PUT_LINE('CORP_CD:' || vMHrDept(i).CORP_CD || ', DEPT_CD:' || vMHrDept(i).DEPT_CD);
          --sys.DBMS_OUTPUT.PUT_LINE('-- ERROR ---------------------------------------------------------------------------------- ' );
          var_err_cnt := var_err_cnt + 1;
      END;
    END LOOP;

 
    EXIT WHEN cMHrDept%NOTFOUND;
  END LOOP;
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') || ' ' || TO_CHAR(var_insert_cnt_dept, '9,999,999,990') || ' records(M_DEPT) succeeded.');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') || ' ' || TO_CHAR(var_err_cnt, '9,999,999,990') || ' records(M_DEPT) failed.');
  --dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);

  FOR i IN 1..var_system_err_index LOOP 
    dbms_output.put_line (vSystemErrorArray(i) || ']');
  END LOOP;
  vSystemErrorArray.DELETE;

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' m_Post begins.' );
  dbms_output.put_line ('= M_DEPT =============================================================');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' Portal(M_POST) delete.' );
  delete from PORTAL_USER.M_POST where CORP_CD = CNST_CORP_CD;
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(SQL%ROWCOUNT, '9,999,999,990') || ' records deleted.' );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' Master(POST_CD) --> Portal(M_POST).' );


  OPEN cMHrPost;

  LOOP
    /* The records of "BULK_SIZE" number are acquired from the cursor[cMHrPost], 
       and it sets it in the variable[vMHrPost]. 
       It is the fetch performance measures. */
    FETCH cMHrPost BULK COLLECT INTO vMHrPost LIMIT BULK_SIZE;
    
    -- 2010/03/04 Start Sakuma if m_post count = 0 then 1 default record insert
    IF cMHrPost%rowcount = 0 THEN
    --  RAISE SRC_TABLE_IS_EMPTY;
        insert into PORTAL_USER.M_POST (
          CORP_CD,
          POST_CD,
          POST_NAME,
          REGISTER_DATE,
          UPDATE_DATE
        ) values (
          CNST_CORP_CD,
          '99999999',
          '設定なし',
          sysdate,
          sysdate
        );
        var_insert_cnt_post := var_insert_cnt_post + 1;
       EXIT;
    END IF;
    -- 2010/03/04 End Sakuma 
    
    FOR i in 1 .. vMHrPost.COUNT
    LOOP
      BEGIN 
        insert into PORTAL_USER.M_POST (
          CORP_CD,
          POST_CD,
          POST_NAME,
          REGISTER_DATE,
          UPDATE_DATE
        ) values (
          vMHrPost(i).CORP_CD,
          vMHrPost(i).POST_CD,
          vMHrPost(i).POST_NAME,
          sysdate,
          sysdate
        );
        var_insert_cnt_post := var_insert_cnt_post + 1;
        
      EXCEPTION
        WHEN others THEN
          --sys.DBMS_OUTPUT.PUT_LINE('-- ERROR in nest block -------------------------------------------------------------------- ' );
          var_system_err_index := var_system_err_index + 1;
          vSystemErrorArray.EXTEND(1);
          vSystemErrorArray(var_system_err_index) := SQLERRM || ' [CORP_CD:' || vMHrPost(i).CORP_CD || ', POST_CD:' || vMHrPost(i).POST_CD || ']';
          var_err_cnt := var_err_cnt + 1;
      END;
    END LOOP;

 
    EXIT WHEN cMHrPost%NOTFOUND;
  END LOOP;
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') || ' ' || TO_CHAR(var_insert_cnt_post, '9,999,999,990') || ' records(M_DEPT) succeeded.');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') || ' ' || TO_CHAR(var_err_cnt, '9,999,999,990') || ' records(M_DEPT) failed.');
  --dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);

  FOR i IN 1..var_system_err_index LOOP 
    dbms_output.put_line (vSystemErrorArray(i) || ']');
  END LOOP;
  vSystemErrorArray.DELETE;

  dbms_output.put_line ('= M_EMP ==============================================================');
  vSystemErrorArray := tArray1000();
  var_system_err_index := 0;
  
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' Master(M_EMP) --> Portal(M_EMP).' );

  OPEN cUser;
  var_insert_cnt_emp := 0;
  var_update_cnt_emp := 0;
  var_err_cnt := 0;

  LOOP
    FETCH cUser BULK COLLECT INTO vUser LIMIT BULK_SIZE;
    
    --IF cUser%rowcount = 0 THEN
    --  RAISE SRC_TABLE_IS_EMPTY;
    --END IF;
    

    FOR i in 1 .. vUser.COUNT
    LOOP
      SAVEPOINT SP1;
      BEGIN

        IF vUser(i).MM_ERR = '1' THEN
          RAISE NOT_EXIST_DEPT_CD;
        END IF;

          
          
        -- M_EMP =============================================================
        IF vUser(i).UP_EMP ='1' THEN
            insert into PORTAL_USER.M_EMP (
              EMP_CD,
              EMP_NO,
              EMP_NAME,
              EMP_NAME_KANA,
              EMAIL,
              TEL,
              EXTENSION,
              FAX,
              DEE_PASSWORD,
              DEE_USER_ID,
              DELETE_FLAG,
              REGISTER_DATE,
              UPDATE_DATE
            ) values (
              TRIM(TO_CHAR(SEQ_EMP_CD.NEXTVAL, '0000000000')),
              TRIM(vUser(i).EMP_NO),
              TRIM(vUser(i).EMP_NAME),
              TRIM(vUser(i).EMP_NAME_KANA),
              LOWER(TRIM(vUser(i).MAIL_ADDR)),
              TRIM(vUser(i).TEL),
              TRIM(vUser(i).EXT_NO),
              TRIM(vUser(i).FAX),
              TRIM(vUser(i).DEE_PASSWORD),
              TRIM(vUser(i).DEE_USER_ID),
              '0',
              vUser(i).UPDATEDATE,
              vUser(i).UPDATEDATE
            );
            var_insert_cnt_emp := var_insert_cnt_emp + 1;
        ELSIF vUser(i).UP_EMP ='2' THEN
            update PORTAL_USER.M_EMP
            set 
              EMP_NAME = TRIM(vUser(i).EMP_NAME), 
              EMP_NAME_KANA = TRIM(vUser(i).EMP_NAME_KANA), 
              EMAIL = LOWER(TRIM(vUser(i).MAIL_ADDR)), 
              TEL = TRIM(vUser(i).TEL), 
              EXTENSION = TRIM(vUser(i).EXT_NO), 
              FAX = TRIM(vUser(i).FAX), 
              DEE_USER_ID = TRIM(vUser(i).DEE_USER_ID), 
              DELETE_FLAG = '0', 
              UPDATE_DATE = vUser(i).UPDATEDATE
            where
              EMP_CD = vUser(i).EMP_CD;
            var_update_cnt_emp := var_update_cnt_emp + 1;
        END IF; -- END OF "IF vUser(i).EMP_CD IS NULL THEN"
        -- M_EMP_DEPT ==========================================================
        
        IF vUser(i).EMP_CD IS NULL THEN
          select trim(to_char(SEQ_EMP_CD.CURRVAL, '0000000000')) into var_emp_cd from dual;
        ELSE
          var_emp_cd := vUser(i).EMP_CD;
        END IF;

        IF vUser(i).UP_EMPDEPT = '1' THEN
          insert into PORTAL_USER.M_EMP_DEPT (
            EMP_CD,
            CORP_CD,
            DEPT_CD,
            HEAD_FLG,
            PRIMARY_FLG,
            POST_CD,
            BUY_SUP_DIV,
            DELETE_FLAG,
            REGISTER_DATE,
            UPDATE_DATE
          ) values (
            var_emp_cd,
            CNST_CORP_CD,
            vUser(i).IMPORT_DEPT,
            vUser(i).HEAD_FLG,
            vUser(i).PRIMARY_FLG,
            vUser(i).POST_CD,
            '2',
            '0',
            vUser(i).UPDATEDATE,
            vUser(i).UPDATEDATE
          );
          var_insert_cnt_emp_dept := var_insert_cnt_emp_dept + 1;
        ELSIF vUser(i).UP_EMPDEPT = '2' THEN
          update PORTAL_USER.M_EMP_DEPT
          set
            HEAD_FLG = vUser(i).HEAD_FLG,
            PRIMARY_FLG = vUser(i).PRIMARY_FLG,
            POST_CD = vUser(i).POST_CD,
            BUY_SUP_DIV = '2',
            DELETE_FLAG = '0',
            UPDATE_DATE = vUser(i).UPDATEDATE
          where
            EMP_CD = vUser(i).EMP_CD and
            CORP_CD = CNST_CORP_CD and
            DEPT_CD = vUser(i).IMPORT_DEPT;
          var_update_cnt_emp_dept := var_update_cnt_emp_dept + 1;
        END IF; -- END OF "IF vUser(i).CORP_CD IS NULL THEN"
        


        -- M_SUBSYSTEM_ACCESS(DEM)==============================================
        IF vUser(i).UP_DEM = '1' THEN
          insert into PORTAL_USER.M_SUBSYSTEM_ACCESS (
            EMP_CD,
            CORP_CD,
            DEPT_CD,
            SUBSYSTEM_CD,
            ACCESS_FLG,
            REGISTER_DATE,
            UPDATE_DATE
          ) select temp.emp_cd,temp.corp_cd,temp.dept_cd,temp.subsystem_cd,temp.access_flg,temp.REGISTER_DATE,temp.UPDATE_DATE from (select 
            var_emp_cd as emp_cd,
            CNST_CORP_CD as corp_cd,
            vUser(i).IMPORT_DEPT as dept_cd,
            'S_DEM' as subsystem_cd,
            '1' as access_flg,
            vUser(i).UPDATEDATE as REGISTER_DATE,
            vUser(i).UPDATEDATE as UPDATE_DATE from dual) temp
          left join m_subsystem_access msa on temp.emp_cd =  msa.emp_cd and 
					      temp.corp_cd =  msa.corp_cd and 
					      temp.dept_cd =  msa.dept_cd and 
					      temp.subsystem_cd =  msa.subsystem_cd
			where msa.emp_cd is null;
          var_insert_cnt_dem := var_insert_cnt_dem + 1;
        END IF; -- END OF "IF vUser(i).UP_DEM IS NULL THEN"

        IF vUser(i).UP_DCM = '1' THEN
          insert into PORTAL_USER.M_SUBSYSTEM_ACCESS (
            EMP_CD,
            CORP_CD,
            DEPT_CD,
            SUBSYSTEM_CD,
            ACCESS_FLG,
            REGISTER_DATE,
            UPDATE_DATE
          ) select temp.emp_cd,temp.corp_cd,temp.dept_cd,temp.subsystem_cd,temp.access_flg,temp.REGISTER_DATE,temp.UPDATE_DATE from (select 
            var_emp_cd as emp_cd,
            CNST_CORP_CD as corp_cd,
            vUser(i).IMPORT_DEPT as dept_cd,
            'S_DCM' as subsystem_cd,
            '1' as access_flg,
            vUser(i).UPDATEDATE as REGISTER_DATE,
            vUser(i).UPDATEDATE as UPDATE_DATE from dual) temp
          left join m_subsystem_access msa on temp.emp_cd =  msa.emp_cd and 
					      temp.corp_cd =  msa.corp_cd and 
					      temp.dept_cd =  msa.dept_cd and 
					      temp.subsystem_cd =  msa.subsystem_cd
			where msa.emp_cd is null;
          var_insert_cnt_dema := var_insert_cnt_dema + 1;
        END IF; -- END OF "IF vUser(i).UP_DEMA IS NULL THEN"

        IF vUser(i).UP_DIPS = '1' THEN
          insert into PORTAL_USER.M_SUBSYSTEM_ACCESS (
            EMP_CD,
            CORP_CD,
            DEPT_CD,
            SUBSYSTEM_CD,
            ACCESS_FLG,
            REGISTER_DATE,
            UPDATE_DATE
          ) select temp.emp_cd,temp.corp_cd,temp.dept_cd,temp.subsystem_cd,temp.access_flg,temp.REGISTER_DATE,temp.UPDATE_DATE from (select 
            var_emp_cd as emp_cd,
            CNST_CORP_CD as corp_cd,
            vUser(i).IMPORT_DEPT as dept_cd,
            'S_DIPS' as subsystem_cd,
            '1' as access_flg,
            vUser(i).UPDATEDATE as REGISTER_DATE,
            vUser(i).UPDATEDATE as UPDATE_DATE from dual) temp
          left join m_subsystem_access msa on temp.emp_cd =  msa.emp_cd and 
					      temp.corp_cd =  msa.corp_cd and 
					      temp.dept_cd =  msa.dept_cd and 
					      temp.subsystem_cd =  msa.subsystem_cd
			where msa.emp_cd is null;
          var_insert_cnt_dips := var_insert_cnt_dips + 1;
        END IF; -- END OF "IF vUser(i).UP_SV IS NULL THEN"
		--
          insert into PORTAL_USER.M_SUBSYSTEM_ACCESS (
            EMP_CD,
            CORP_CD,
            DEPT_CD,
            SUBSYSTEM_CD,
            ACCESS_FLG,
            REGISTER_DATE,
            UPDATE_DATE
          ) select temp.emp_cd,temp.corp_cd,temp.dept_cd,temp.subsystem_cd,temp.access_flg,temp.REGISTER_DATE,temp.UPDATE_DATE from (select 
            var_emp_cd as emp_cd,
            CNST_CORP_CD as corp_cd,
            vUser(i).IMPORT_DEPT as dept_cd,
            'S_DSM' as subsystem_cd,
            '1' as access_flg,
            vUser(i).UPDATEDATE as REGISTER_DATE,
            vUser(i).UPDATEDATE as UPDATE_DATE from dual) temp
          left join m_subsystem_access msa on temp.emp_cd =  msa.emp_cd and 
					      temp.corp_cd =  msa.corp_cd and 
					      temp.dept_cd =  msa.dept_cd and 
					      temp.subsystem_cd =  msa.subsystem_cd
			where msa.emp_cd is null;

        
      EXCEPTION
        WHEN NOT_EXIST_DEPT_CD THEN
          var_err_cnt_dept_not_exist := var_err_cnt_dept_not_exist + 1;
          vErrorNotExistDeptCdArray.EXTEND(1);
          vErrorNotExistDeptCdArray(var_err_cnt_dept_not_exist) := 'EMP_NO:' || vUser(i).EMP_NO || ', DEPT_CD:' || vUser(i).DEPT_CD;
          --dbms_output.put_line ('ErrorReason: The dept_cd where it does not exist!');
          --dbms_output.put_line ('EMP_NO:' || vUser(i).EMP_NO || ', DEPT_CD:' || vUser(i).DEPT_CD);
          --sys.DBMS_OUTPUT.PUT_LINE('-- ERROR ---------------------------------------------------------------------------------- ' );
          ROLLBACK TO SP1;
          var_err_cnt := var_err_cnt + 1;
        WHEN INTERLOCKING_TYPE_1_NOT_FOUND THEN
          var_err_cnt_interlocking := var_err_cnt_interlocking + 1;
          vErrorInterLockingType1.EXTEND(1);
          vErrorInterLockingType1(var_err_cnt_interlocking) := 'EMP_NO:' || vUser(i).EMP_NO;
          --dbms_output.put_line ('ErrorReason: INTERLOCKING_TYPE[1] not found!');
          --dbms_output.put_line ('EMP_NO:' || vUser(i).EMP_NO || '');
          --dbms_output.put_line ('-- ERROR ---------------------------------------------------------------------------------- ' );
          ROLLBACK TO SP1;
          var_err_cnt := var_err_cnt + 1;
        WHEN others THEN
          --sys.DBMS_OUTPUT.PUT_LINE('-- ERROR in nest block -------------------------------------------------------------------- ' );
          var_system_err_index := var_system_err_index + 1;
          vSystemErrorArray.EXTEND(1);
          vSystemErrorArray(var_system_err_index) := SQLERRM || ' [EMP_NO:' || vUser(i).EMP_NO || ']';
          --sys.DBMS_OUTPUT.PUT_LINE('ORA- ' || SQLCODE );
          --sys.DBMS_OUTPUT.PUT_LINE('ErrorReason: ' || SQLERRM );
          --sys.DBMS_OUTPUT.PUT_LINE('EMP_NO:' || vUser(i).EMP_NO);
          --sys.DBMS_OUTPUT.PUT_LINE('-- ERROR ---------------------------------------------------------------------------------- ' );
          ROLLBACK TO SP1;
          var_err_cnt := var_err_cnt + 1;
      END;
    END LOOP;
 
    EXIT WHEN cUser%NOTFOUND;
  END LOOP;


  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_insert_cnt_emp, '9,999,999,990') || ' records(M_EMP) inserted.');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_update_cnt_emp, '9,999,999,990') || ' records(M_EMP) updated.');
  dbms_output.put_line ('= M_EMP_DEPT =========================================================');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_insert_cnt_emp_dept, '9,999,999,990') || ' records(M_EMP_DEPT) inserted.');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_update_cnt_emp_dept, '9,999,999,990') || ' records(M_EMP_DEPT) updated.');
  dbms_output.put_line ('= M_SUBSYSTEM_ACCESS[DEM] ============================================');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_insert_cnt_dem, '9,999,999,990') || ' records(DEM) inserted.');
/* MODIFY START   2007/07/18 SAKUMA */
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_insert_cnt_dema, '9,999,999,990') || ' records(DEMa) inserted.');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_insert_cnt_kbb, '9,999,999,990') || ' records(KBB) inserted.');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_insert_cnt_dsv, '9,999,999,990') || ' records(DSV) inserted.');
/* MODIFY END   2007/07/18 SAKUMA */
  --dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_update_cnt_dem, '9,999,999,990') || ' records(DEM) updated.');
  dbms_output.put_line ('= M_SUBSYSTEM_ACCESS[DAF] ============================================');
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_insert_cnt_daf, '9,999,999,990') || ' records(DAF) inserted.');
  --dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_update_cnt_daf, '9,999,999,990') || ' records(DAF) updated.');

  -- Update DeleteFlag[M_EMP_DEPT]==============================================
  dbms_output.put_line ('= Update DeleteFlag[M_EMP_DEPT] ======================================');

  update M_EMP_DEPT ed
  set
    ed.UPDATE_DATE = SYSDATE,
    ed.DELETE_FLAG = '1' 
  WHERE EXISTS(
            select 1 from
                (
                select
                    M_EMP_DEPT.EMP_CD,
                    M_EMP.EMP_NO,
                    M_EMP_DEPT.CORP_CD,
                    M_EMP_DEPT.DEPT_CD ,
                    WK_IMPORT_SUP_EMP.DEPT_CD as DELETE_FLAG
                from
                    M_EMP_DEPT 
                        left outer join M_EMP on
                            M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD
                        left outer join WK_IMPORT_SUP_EMP
                             on
                                M_EMP.EMP_NO = WK_IMPORT_SUP_EMP.EMP_NO and
                                M_EMP_DEPT.DEPT_CD = WK_IMPORT_SUP_EMP.DEPT_CD
                where
                    M_EMP_DEPT.CORP_CD =CNST_CORP_CD AND M_EMP.ACCOUNT_TYPE = '0' AND M_EMP_DEPT.DELETE_FLAG ='0'
                ) WK
            where
                WK.DELETE_FLAG is null and
                ed.EMP_CD = WK.EMP_CD and
                ed.CORP_CD = WK.CORP_CD and
                ed.DEPT_CD = WK.DEPT_CD
            );

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(SQL%ROWCOUNT, '9,999,999,990') || ' records updated.' );




  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(SQL%ROWCOUNT, '9,999,999,990') || ' records updated.' );

  -- Update DeleteFlag[M_EMP]===================================================
  dbms_output.put_line ('= Update DeleteFlag[M_EMP] ===========================================');
        UPDATE M_EMP SET DELETE_FLAG = 1
        where exists(
        select 1
        FROM (
                select
                    M_EMP.EMP_CD,
                    M_EMP.ACCOUNT_TYPE,
                    COUNT(M_EMP_DEPT.DEPT_CD) AS EDCOUNT
                from
                    M_EMP 
                        left outer join M_EMP_DEPT on
                            M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD and M_EMP_DEPT.DELETE_FLAG='0' and DELETE_FLAG= '0'
                where M_EMP.DELETE_FLAG= '0'
                group by 
                    M_EMP.EMP_CD,
                    M_EMP.ACCOUNT_TYPE) EDDATA
        where ACCOUNT_TYPE = 0 AND 
              EDCOUNT = 0 AND 
              M_EMP.EMP_CD = EDDATA.EMP_CD);

  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(SQL%ROWCOUNT, '9,999,999,990') || ' records updated.' );

  dbms_output.put_line ('= INSERT[M_SUBSYSTEM_ACCESS] 組織変更があった場合サブシステムのアクセス権限を変更された組織に付け替えます。  =========================');
  IF CNST_CORP_CD = '21000188' THEN
  -- SBM===================================================
	  INSERT INTO M_SUBSYSTEM_ACCESS(EMP_CD,CORP_CD,DEPT_CD,SUBSYSTEM_CD,ACCESS_FLG,UPDATE_EMP_CD,REGISTER_DATE,UPDATE_DATE) 
	  SELECT
	      ED.EMP_CD,
	      ED.CORP_CD,
	      ED.DEPT_CD,
	      SUBSYS.SUBSYSTEM_CD,
	      '1' AS ACCESS_FLG,
	      NULL AS UPDATE_EMP_CD,
	      SYSDATE AS REGISTER_DATE,
	      SYSDATE AS UPDATE_DATE
	  FROM
	      M_EMP_DEPT ED       
	          INNER JOIN (SELECT DISTINCT 
	                          MSA.EMP_CD,
	                          MSA.CORP_CD,
	                          MSA.SUBSYSTEM_CD
	                      FROM
	                          M_SUBSYSTEM_ACCESS MSA
	                          LEFT JOIN M_EMP_DEPT MED ON 
	                                    MED.EMP_CD = MSA.EMP_CD AND
	                                    MED.CORP_CD = MSA.CORP_CD AND
	                                    MED.DEPT_CD = MSA.DEPT_CD AND MED.DELETE_FLAG='0'
	                          LEFT JOIN M_EMP ME ON ME.EMP_CD = MSA.EMP_CD
	                      WHERE
	                          MED.DEPT_CD IS NULL AND
	                          ME.ACCOUNT_TYPE=0 AND
	                          MSA.SUBSYSTEM_CD NOT IN ('DAF','KBB','DEMa') and MSA.ACCESS_FLG = '1'
	                      ) SUBSYS ON SUBSYS.EMP_CD = ED.EMP_CD AND SUBSYS.CORP_CD = ED.CORP_CD 
	             left join M_SUBSYSTEM_ACCESS DEAD on ED.EMP_CD = DEAD.EMP_CD AND ED.CORP_CD = DEAD.CORP_CD  AND ED.DEPT_CD = DEAD.DEPT_CD AND  SUBSYS.SUBSYSTEM_CD = DEAD.SUBSYSTEM_CD 
	  WHERE ED.CORP_CD = CNST_CORP_CD AND DEAD.DEPT_CD is null and
	        ED.DELETE_FLAG = '0';
  ELSE
  -- NOT SBM===================================================
	  INSERT INTO M_SUBSYSTEM_ACCESS(EMP_CD,CORP_CD,DEPT_CD,SUBSYSTEM_CD,ACCESS_FLG,UPDATE_EMP_CD,REGISTER_DATE,UPDATE_DATE) 
	  SELECT
	      ED.EMP_CD,
	      ED.CORP_CD,
	      ED.DEPT_CD,
	      SUBSYS.SUBSYSTEM_CD,
	      '1' AS ACCESS_FLG,
	      NULL AS UPDATE_EMP_CD,
	      SYSDATE AS REGISTER_DATE,
	      SYSDATE AS UPDATE_DATE
	  FROM
	      M_EMP_DEPT ED       
	          INNER JOIN (SELECT DISTINCT 
	                          MSA.EMP_CD,
	                          MSA.CORP_CD,
	                          MSA.SUBSYSTEM_CD
	                      FROM
	                          M_SUBSYSTEM_ACCESS MSA
	                          LEFT JOIN M_EMP_DEPT MED ON 
	                                    MED.EMP_CD = MSA.EMP_CD AND
	                                    MED.CORP_CD = MSA.CORP_CD AND
	                                    MED.DEPT_CD = MSA.DEPT_CD AND MED.DELETE_FLAG='0'
	                          LEFT JOIN M_EMP ME ON ME.EMP_CD = MSA.EMP_CD
	                      WHERE
	                          MED.DEPT_CD IS NULL AND
	                          ME.ACCOUNT_TYPE=0 AND
	                          MSA.SUBSYSTEM_CD NOT IN ('DAF','KBB') and MSA.ACCESS_FLG = '1'
	                      ) SUBSYS ON SUBSYS.EMP_CD = ED.EMP_CD AND SUBSYS.CORP_CD = ED.CORP_CD 
	             left join M_SUBSYSTEM_ACCESS DEAD on ED.EMP_CD = DEAD.EMP_CD AND ED.CORP_CD = DEAD.CORP_CD  AND ED.DEPT_CD = DEAD.DEPT_CD AND  SUBSYS.SUBSYSTEM_CD = DEAD.SUBSYSTEM_CD 
	  WHERE ED.CORP_CD = CNST_CORP_CD AND DEAD.DEPT_CD is null and
	        ED.DELETE_FLAG = '0';
  END IF;
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(SQL%ROWCOUNT, '9,999,999,990') || ' records transfer.' );


  dbms_output.put_line ('= UPDATE[M_SUBSYSTEM_ACCESS] =========================');
/* 2010/03/05 Start sakuma サプライヤのアクセス権は所属変更のたびにアクセス権が無くなるので、以下の更新処理は削除
  update M_SUBSYSTEM_ACCESS s
  set
    s.UPDATE_DATE = SYSDATE,
    s.ACCESS_FLG = '0'
  WHERE EXISTS (
            select * from
                (
                select
                    M_SUBSYSTEM_ACCESS.EMP_CD,
                    M_EMP.EMP_NO,
                    M_SUBSYSTEM_ACCESS.CORP_CD,
                    M_SUBSYSTEM_ACCESS.DEPT_CD ,
                    WK_IMPORT_SUP_EMP.DEPT_CD as DELETE_FLAG
                from
                    M_SUBSYSTEM_ACCESS 
                        left outer join M_EMP on
                            M_SUBSYSTEM_ACCESS.EMP_CD = M_EMP.EMP_CD
                        left outer join WK_IMPORT_SUP_EMP
                             on
                                M_EMP.EMP_NO = WK_IMPORT_SUP_EMP.EMP_NO and
                                M_SUBSYSTEM_ACCESS.DEPT_CD = WK_IMPORT_SUP_EMP.DEPT_CD
                where
                    M_SUBSYSTEM_ACCESS.CORP_CD =CNST_CORP_CD AND M_EMP.ACCOUNT_TYPE = '0' AND M_SUBSYSTEM_ACCESS.ACCESS_FLG ='1'
                ) WK
            where
                WK.DELETE_FLAG is null and
                s.EMP_CD = WK.EMP_CD and
                s.CORP_CD = WK.CORP_CD and
                s.DEPT_CD = WK.DEPT_CD
            );
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(SQL%ROWCOUNT, '9,999,999,990') || ' records updated.' );
  2010/03/05 End sakuma */
  dbms_output.put_line ('======================================================================');
  --アカウントタイプが１で主務が複数のデータを補正する
  --本日以前でアカウントタイプが１で主務が複数のデータを兼務に補正する
	UPDATE M_EMP_DEPT ED SET ED.PRIMARY_FLG='0'
	where exists(
	SELECT
	    CORP_CD,
	    EMP_CD,
	    DEPT_CD,
	    REGISTER_DATE
	FROM
	    (SELECT
	        row_number() over (partition by M_EMP_DEPT.CORP_CD, M_EMP_DEPT.EMP_CD order by  CORP_CD ASC, EMP_CD ASC,REGISTER_DATE DESC) as IDX,
	        CORP_CD,
	        EMP_CD,
	        DEPT_CD,
	        REGISTER_DATE
	    FROM
	        M_EMP_DEPT
	    WHERE
	        m_emp_dept.emp_cd in (SELECT
	                                    EMP_CD
	                                FROM
	                                    (SELECT
	                                        M_EMP_DEPT.EMP_CD,
	                                        COUNT(M_EMP_DEPT.DEPT_CD) as cnt
	                                    FROM
	                                        M_EMP_DEPT       INNER join M_EMP on M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD
	                                    WHERE
	                                        PRIMARY_FLG='1' AND
	                                        M_EMP_DEPT.DELETE_FLAG='0'
	                                    GROUP BY
	                                        M_EMP_DEPT.EMP_CD
	                                    )
	                                WHERE
	                                    cnt >1
	                                )  AND
	        m_emp_dept.primary_flg='1' AND
	        M_EMP_DEPT.DELETE_FLAG='0' AND
	        m_emp_dept.CORP_CD=CNST_CORP_CD
	    ) TMP_USER_IDX
	WHERE
	    TMP_USER_IDX.IDX > 1 AND
	    TMP_USER_IDX.CORP_CD = ED.CORP_CD AND
	    TMP_USER_IDX.DEPT_CD = ED.DEPT_CD AND
	    TMP_USER_IDX.EMP_CD = ED.EMP_CD 
	);


  IF var_err_cnt = 0 THEN
    :retcode := 0;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
  ELSE
    dbms_output.put_line ('#ERROR_LIST ################################');
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' ' || TO_CHAR(var_err_cnt, '9,999,999,990') || ' records failed.');
    FOR i IN 1..var_system_err_index LOOP 
      dbms_output.put_line (vSystemErrorArray(i));
    END LOOP;

    FOR i IN 1..var_err_cnt_dept_not_exist LOOP 
      dbms_output.put_line ('ErrorReason: The dept_cd where it does not exist! [' || vErrorNotExistDeptCdArray(i) || ']');
    END LOOP;

    FOR i IN 1..var_err_cnt_interlocking LOOP 
      dbms_output.put_line ('ErrorReason: INTERLOCKING_TYPE=1 not found! [' || vErrorInterLockingType1(i) || ']');
    END LOOP;
  END IF;

  select COUNT(M_EMP_DEPT.DEPT_CD) into var_notexist_dept_cnt
  FROM M_EMP_DEPT 
       LEFT JOIN M_DEPT ON M_EMP_DEPT.DEPT_CD =M_DEPT.DEPT_CD
       LEFT JOIN M_EMP ON M_EMP_DEPT.EMP_CD =M_EMP.EMP_CD 
  where M_DEPT.DEPT_CD is null AND M_EMP_DEPT.CORP_CD = CNST_CORP_CD  and M_EMP.ACCOUNT_TYPE='0' and M_EMP_DEPT.DELETE_FLAG='0';
  if var_notexist_dept_cnt > 0 then
     :retcode := 0;
     RAISE NOTEXIST_DEPT;
  END IF;
  select count(EMP_CD) into var_notexist_if_cnt 
               FROM (
                    select
                        M_EMP_DEPT.EMP_CD,
                        M_EMP.EMP_NO,M_EMP.EMP_NAME,
                        M_EMP_DEPT.CORP_CD,
                        M_EMP_DEPT.DEPT_CD,M_DEPT.DEPT_NAME,M_EMP.ACCOUNT_TYPE,
                        WK_IMPORT_SUP_EMP.DEPT_CD AS IMPORT_DEPT
                    from
                        M_EMP_DEPT 
                        left outer join M_EMP on
                            M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD
                        left outer join M_DEPT on
                            M_EMP_DEPT.CORP_CD = M_DEPT.CORP_CD AND
                            M_EMP_DEPT.DEPT_CD = M_DEPT.DEPT_CD AND
                            M_DEPT.COALITION_FLAG = '0'
                        left outer join WK_IMPORT_SUP_EMP
                             on
                                M_EMP.EMP_NO = WK_IMPORT_SUP_EMP.EMP_NO and
                                M_EMP_DEPT.DEPT_CD = WK_IMPORT_SUP_EMP.DEPT_CD
                    where
                        M_EMP_DEPT.CORP_CD =CNST_CORP_CD AND M_EMP_DEPT.DELETE_FLAG='0') IFDATA
               where ACCOUNT_TYPE = '0' and 
                     IMPORT_DEPT is null;
  if var_notexist_if_cnt > 0 then
     :retcode := 0;
    RAISE NOTEXIST_SOURCE_DATA;
  END IF;
  SELECT
      count(*) into var_main_manage_cnt
  FROM
      (SELECT
          M_EMP_DEPT.EMP_CD,
          COUNT(M_EMP_DEPT.DEPT_CD) as cnt
      FROM
          M_EMP_DEPT       INNER join M_EMP on M_EMP_DEPT.EMP_CD = M_EMP.EMP_CD
      WHERE
          PRIMARY_FLG='1' AND
          CORP_CD=CNST_CORP_CD AND
          M_EMP_DEPT.DELETE_FLAG='0'
      GROUP BY
          M_EMP_DEPT.EMP_CD
      )
  WHERE
      cnt >1;
  if var_main_manage_cnt > 0 then
     :retcode := 0;
     RAISE MAIN_MANAGE_1_OVER;
  END IF;

  vSystemErrorArray.DELETE;
  vErrorNotExistDeptCdArray.DELETE;
  vErrorInterLockingType1.DELETE;
  commit;
  
EXCEPTION
  WHEN SRC_TABLE_IS_EMPTY THEN
    dbms_output.put_line ('----------------------------------------------------------------');
    dbms_output.put_line ('移行元のデータが存在しません.' );
    dbms_output.put_line ('-- ERROR ---------------------------------------------------------------------------------- ' );
    dbms_output.put_line ('ロールバックします。' );
    rollback;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
    vSystemErrorArray.DELETE;
    vErrorNotExistDeptCdArray.DELETE;
    vErrorInterLockingType1.DELETE;
  WHEN MAIN_MANAGE_1_OVER THEN
    DBMS_OUTPUT.PUT_LINE ('----------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('複数の主務を持つアカウントが存在します。' || var_main_manage_cnt );
    DBMS_OUTPUT.PUT_LINE ('-- ERROR ---------------------------------------------------------------------------------- ' );
    dbms_output.put_line ('ロールバックします。' );
    rollback;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
    vSystemErrorArray.DELETE;
    vErrorNotExistDeptCdArray.DELETE;
    vErrorInterLockingType1.DELETE;
  WHEN NOTEXIST_SOURCE_DATA THEN
    dbms_output.put_line ('----------------------------------------------------------------');
    dbms_output.put_line ('移行先に移行元に無いデータが存在します。' || var_notexist_if_cnt );
    dbms_output.put_line ('-- ERROR ---------------------------------------------------------------------------------- ' );
    dbms_output.put_line ('ロールバックします。' );
    rollback;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
    vSystemErrorArray.DELETE;
    vErrorNotExistDeptCdArray.DELETE;
    vErrorInterLockingType1.DELETE;
  WHEN NOTEXIST_DEPT THEN
    dbms_output.put_line ('----------------------------------------------------------------');
    dbms_output.put_line ('移行先に組織データの整合性が合わないアカウントがあります。.' || var_notexist_dept_cnt );
    dbms_output.put_line ('-- ERROR ---------------------------------------------------------------------------------- ' );
    dbms_output.put_line ('ロールバックします。' );
    rollback;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
    vSystemErrorArray.DELETE;
    vErrorNotExistDeptCdArray.DELETE;
    vErrorInterLockingType1.DELETE;
  WHEN others THEN
    sys.DBMS_OUTPUT.PUT_LINE ('ORA- ' || SQLCODE );
    sys.DBMS_OUTPUT.PUT_LINE ('ErrorReason: ' || SQLERRM );
    sys.DBMS_OUTPUT.PUT_LINE (' -- ERROR ---------------------------------------------------------------------------------- ' );
    sys.dbms_output.put_line ('ロールバックします。' );
    rollback;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
    vSystemErrorArray.DELETE;
    vErrorNotExistDeptCdArray.DELETE;
    vErrorInterLockingType1.DELETE;
END;
/
exit :retcode;


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



  /* Declare Constst ********************************************************************/
  BULK_SIZE CONSTANT    NUMBER := 100; 

  /* Other variables ********************************************************************/
  var_system_err_index	      PLS_INTEGER := 0;     /* Belong to a nonexistent department employees Count */
  var_notexist_corp_cnt	      PLS_INTEGER := 0;     /* Belong to a nonexistent department employees Count */
  var_err_cnt                 PLS_INTEGER := 0;  /* Error number                              */

  var_insert_cnt_corp     PLS_INTEGER := 0;  /* Record registration number to M_DEPT                  */
  var_update_cnt_corp     PLS_INTEGER := 0;  /* Record update number to M_EMP_DEPT                    */

BEGIN

  dbms_output.enable(1000000);
  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' m_corp begins.' );
  dbms_output.put_line ('= M_CORP =============================================================');

          insert into PORTAL_USER.M_CORP (
            CORP_CD,
            CORP_GROUP_CD,
            CORP_NAME,
            DEE_CORP_ID,
            TDB_CORP_CD,
            UPDATE_EMP_CD,
            REGISTER_DATE,
            UPDATE_DATE,
            CSV_FLG
          ) select temp.CORP_CD,temp.CORP_GROUP_CD,temp.CORP_NAME,temp.DEE_CORP_ID,temp.TDB_CORP_CD,temp.UPDATE_EMP_CD,sysdate,SYSDATE,temp.CSV_FLG from wk_import_corp temp
          left join M_CORP mc on temp.corp_cd =  mc.corp_cd 
          where mc.corp_cd is null;


--  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') || ' ' || TO_CHAR(var_insert_cnt_corp, '9,999,999,990') || ' records(M_CORP) succeeded.');
--  dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') || ' ' || TO_CHAR(var_err_cnt, '9,999,999,990') || ' records(M_CORP) failed.');
  --dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);

  FOR i IN 1..var_system_err_index LOOP 
    dbms_output.put_line (vSystemErrorArray(i) || ']');
  END LOOP;
  vSystemErrorArray.DELETE;

  commit;
  
EXCEPTION
  WHEN others THEN
    sys.DBMS_OUTPUT.PUT_LINE ('ORA- ' || SQLCODE );
    sys.DBMS_OUTPUT.PUT_LINE ('ErrorReason: ' || SQLERRM );
    sys.DBMS_OUTPUT.PUT_LINE (' -- ERROR ---------------------------------------------------------------------------------- ' );
    sys.dbms_output.put_line ('ロールバックします。' );
    rollback;
    dbms_output.put_line ( to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')  || ' returnCode: ' || :retcode);
    vSystemErrorArray.DELETE;
END;
/
exit :retcode;


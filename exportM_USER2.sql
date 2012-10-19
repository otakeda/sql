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

--ヘッダを出力
select
  '"社員番号","氏名","所属組織コード1","主務/兼務区分1","役職ID1","所属組織コード2","主務/兼務区分2","役職ID2","所属組織コード3","主務/兼務区分3","役職ID3","所属組織コード4","主務/兼務区分4","役職ID4","所属組織コード5","主務/兼務区分5","役職ID5","所属組織コード6","主務/兼務区分6","役職ID6","所属組織コード7","主務/兼務区分7","役職ID7","所属組織コード8","主務/兼務区分8","役職ID8","所属組織コード9","主務/兼務区分9","役職ID9","所属組織コード10","主務/兼務区分10","役職ID10","電話番号","メールアドレス","削除フラグ","担当者コード"'
from dual;

--データを出力
select
  '"' || replace(M_EMP.EMP_NO, '"', '\"') || '",' ||
  '"' || replace(NVL(TRIM(M_EMP.EMP_NAME), M_EMP.EMP_NAME_KANA), '"', '\"') || '",' ||
  '"' || replace(DECODE(M_EMP.DELETE_FLAG,'0',TMP_USER1.DEPT_CD,NULL), '"', '\"') || '",' ||
  '"' || replace(DECODE(M_EMP.DELETE_FLAG,'0',TMP_USER1.PRIMARY_FLG,NULL), '"', '\"') || '",' ||
  '"' || replace(DECODE(M_EMP.DELETE_FLAG,'0',TMP_USER1.POST_CD,NULL), '"', '\"') || '",' ||
  '"' || replace(TMP_USER2.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER2.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER2.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER3.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER3.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER3.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER4.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER4.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER4.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER5.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER5.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER5.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER6.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER6.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER6.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER7.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER7.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER7.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER8.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER8.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER8.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER9.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER9.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER9.POST_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER10.DEPT_CD, '"', '\"') || '",' ||
  '"' || replace(TMP_USER10.PRIMARY_FLG, '"', '\"') || '",' ||
  '"' || replace(TMP_USER10.POST_CD, '"', '\"') || '",' ||
  '"' || replace(nvl(M_EMP.EXTENSION,' ') || '/' || nvl(M_EMP.TEL,' '), '"', '\"') || '",' ||
  '"' || replace(M_EMP.EMAIL, '"', '\"') || '",' ||
  '"' || replace(M_EMP.DELETE_FLAG, '"', '\"') || '",' ||
  '"' || replace(M_EMP.EMP_CD, '"', '\"') || '"'
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
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where 
            DELETE_FLAG='0' AND
            CORP_CD='&1'
          ) TMP_USER_IDX
        where
          IDX = 1
      ) TMP_USER1 on
        M_EMP.EMP_CD = TMP_USER1.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 2
      ) TMP_USER2 on
        M_EMP.EMP_CD = TMP_USER2.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 3
      ) TMP_USER3 on
        M_EMP.EMP_CD = TMP_USER3.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 4
      ) TMP_USER4 on
        M_EMP.EMP_CD = TMP_USER4.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 5
      ) TMP_USER5 on
        M_EMP.EMP_CD = TMP_USER5.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 6
      ) TMP_USER6 on
        M_EMP.EMP_CD = TMP_USER6.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 7
      ) TMP_USER7 on
        M_EMP.EMP_CD = TMP_USER7.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 8
      ) TMP_USER8 on
        M_EMP.EMP_CD = TMP_USER8.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 9
      ) TMP_USER9 on
        M_EMP.EMP_CD = TMP_USER9.EMP_CD
    left outer join (
        select
          CORP_CD,
          EMP_CD,
          PRIMARY_FLG,
          DEPT_CD,
          POST_CD
        from
          (select
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
            CORP_CD,
            EMP_CD,
            PRIMARY_FLG,
            DEPT_CD,
            POST_CD
          from
            PORTAL_USER.M_EMP_DEPT
          where
            CORP_CD='&1' AND
            DELETE_FLAG = '0'
          ) TMP_USER_IDX
        where
          IDX = 10
      ) TMP_USER10 on
        M_EMP.EMP_CD = TMP_USER10.EMP_CD
where
  TMP_USER1.PRIMARY_FLG = '1' AND 
  PORTAL_USER.M_EMP.DELETE_FLAG='0'
order by
  M_EMP.EMP_NO;

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
            row_number() over (partition by CORP_CD, EMP_CD order by  CORP_CD ASC, EMP_CD ASC, PRIMARY_FLG DESC, DEPT_CD ASC) as IDX,
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

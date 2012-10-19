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

spool /home/sag/daf/import_csv/importEMP20000306.csv

--データを出力
        SELECT       
                    ''''||emp_no||''''||','||''''||
                    KANJI_NAME||''''||','||''''||
                    KANA_NAME||''''||','||''''||
                    MAIL_ADDR||''''||','||''''||
                    TEL||''''||','||''''||
                    EXT_NO||''''||','||''''||
                    HEAD_FLG||''''||','||''''||
                    INTERLOCKING_TYPE||''''||','||''''||
                    TITLE_CD||''''||','||''''||
                    DEE_DEPT_ID||''''||','||''''||
                    '0'||''''||','||''''||
                    '0'||''''
        FROM
                (SELECT distinct
                    e.emp_no,
                    trim(e.family_name||' ' || e.first_name) AS KANJI_NAME,
                    trim(e.family_name_kana||' ' || e.first_name_kana) AS KANA_NAME,
                    e.email as MAIL_ADDR ,KEY_TELEPHONE_NUMBER as TEL,
                    e.EXTENSION_NUMBER AS EXT_NO,
                    decode(nvl(inter.INTERROCK_CNT,0),1,'1',DECODE(nvl(primary_flg,'0'),'1','1','0')) as INTERLOCKING_TYPE,
                    row_number() over (partition by d.dept_id,e.emp_id order by  d.dept_CODE, p.rank,p.post_id) as UNIQUE_FLG,
                    decode(row_number() over (partition by d.dept_id,decode(d.CHIEF_EMP_ID,e.emp_id,'1','0') order by  d.dept_CODE, p.rank,p.post_id),1,decode(d.CHIEF_EMP_ID,e.emp_id,'1','0'),'0') as HEAD_FLG,
                    NVL(p.post_id,'999') AS TITLE_CD,
                    TRIM(d.dept_CODE) AS DEE_DEPT_ID,
                    '0',
                    '0'
                from emp@base1 e
	                left join emp_belong@base1 b on b.emp_id=e.emp_id --and primary_flg='1'
	                left join dept@base1 d on d.dept_id=coalesce(b.dept_id_5,b.dept_id_4,b.dept_id_3,b.dept_id_2,b.dept_id_1) and d.delete_flag=0 and d.chief_emp_id is not null
	                left join post@base1 p on b.post_id=p.post_id 
	                LEFT JOIN 
				(SELECT EMP_NO , INTERROCK_CNT
				FROM 
					(SELECT V_DEL.EMP_NO , 
						COUNT(V_DEL.EMP_NO) AS INTERROCK_CNT
					FROM
	                                        (SELECT      '20000306' AS CORP_CD ,emp_no,
	                                                    DEE_DEPT_ID AS DEPT_CD
						FROM
							(SELECT e.emp_no,
		                                            row_number() over (partition by d.dept_id,e.emp_id order by  d.dept_CODE, p.rank,p.post_id) as UNIQUE_FLG,
		                                            TRIM(d.dept_CODE) AS DEE_DEPT_ID
		                                        from emp@base1 e
			                                        left join emp_belong@base1 b on b.emp_id=e.emp_id --and primary_flg='1'
			                                        left join dept@base1 d on d.dept_id=coalesce(b.dept_id_5,b.dept_id_4,b.dept_id_3,b.dept_id_2,b.dept_id_1) and d.delete_flag=0 and d.chief_emp_id is not null
			                                        left join post@base1 p on b.post_id=p.post_id 
		                                        WHERE
								e.resign_date is null AND
								e.emp_no is not null AND
								e.emp_no not in ('999999', '888888') and
								d.dept_CODE IS NOT NULL AND
								b.start_date <= sysdate AND
								(b.end_date>= trunc(sysdate) or b.end_date is null) AND
								b.emp_type_id in ('00','01','04','12','10','13')
		                                        UNION
	                                                SELECT e.emp_no,
								1 as UNIQUE_FLG,
								cd.DEE_DEPT_ID
	                                                from 
								(SELECT
		                                                        DEE_DEPT_ID,
		                                                        dept_NAME ,
		                                                        CHIEF_EMP_ID
								FROM
									(SELECT
										DEE_DEPT_ID,
										dept_NAME ,
										CHIEF_EMP_ID,
										sum(HEAD_FLG2) AS HEAD_FLG
									FROM
			                                                        (SELECT
											decode(d.CHIEF_EMP_ID,e.emp_id,'1','0')  as HEAD_FLG2,
											d.CHIEF_EMP_ID,
											dept_NAME ,
											TRIM(d.dept_CODE) AS DEE_DEPT_ID
			                                                        FROM
											emp@base1 e
											left join emp_belong@base1 b on b.emp_id=e.emp_id --and primary_flg='1'
											left join dept@base1 d on d.dept_id=coalesce(b.dept_id_5,b.dept_id_4,b.dept_id_3,b.dept_id_2,b.dept_id_1) and delete_flag=0 and D.CHIEF_EMP_ID IS NOT NULL
			                                                        WHERE
											e.resign_date is null AND
											e.emp_no is not null AND
											e.emp_no not in ('999999', '888888') AND
											b.start_date <= sysdate AND
											d.dept_CODE IS NOT NULL AND
											(b.end_date>= trunc(sysdate) or b.end_date is null) AND
											b.emp_type_id in ('00','01','04','12','10','13')
			                                                        )
									GROUP BY
										DEE_DEPT_ID,
										dept_NAME ,
										CHIEF_EMP_ID
									)
		                                                WHERE
									HEAD_FLG=0 AND
									dee_dept_id is not null
		                                                ) CD
		                                                LEFT JOIN emp@base1 e  on e.emp_id = cd.CHIEF_EMP_ID
		                                                left join emp_belong@base1 b on b.emp_id=e.emp_id --and primary_flg='1'
		                                                left join post@base1 p on b.post_id=p.post_id 
	                                                WHERE
								e.resign_date is null AND
								e.emp_no is not null AND
								e.emp_no not in ('999999', '888888') and
								b.start_date <= sysdate AND
								(b.end_date>= trunc(sysdate) or b.end_date is null) AND
								b.emp_type_id in ('00','01','04','12','10','13')
							)
	                                WHERE UNIQUE_FLG=1
					) V_DEL 
	                                GROUP BY V_DEL.EMP_NO
				)
		                WHERE INTERROCK_CNT=1) INTER ON INTER.EMP_NO = e.emp_no
        	WHERE
			e.resign_date is null AND
			e.emp_no is not null AND
			e.emp_no not in ('999999', '888888') and
			d.dept_CODE IS NOT NULL AND
			b.start_date <= sysdate AND
			(b.end_date>= trunc(sysdate) or b.end_date is null) AND
			b.emp_type_id in ('00','01','04','12','10','13')) WHERE UNIQUE_FLG=1 
	order by emp_no asc,INTERLOCKING_TYPE desc,DEE_DEPT_ID asc;
spool off;


exit;

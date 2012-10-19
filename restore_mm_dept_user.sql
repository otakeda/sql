set linesize 1000
set pagesize 0
set trimspool on

--spool restore.log;
insert into M_DEPT select * from WK_M_DEPT;
truncate table m_emp;
insert into m_emp  select * from WK_m_emp;
truncate table M_EMP_DEPT;
insert into M_EMP_DEPT  select * from WK_M_EMP_DEPT;
truncate table m_subsystem_access;
insert into m_subsystem_access  select * from WK_m_subsystem_access;


commit;
EXIT;

-- Example call:
-- sqlplus sys/oracle@localhost:1521/xe as sysdba @oracle_create_user.sql martin password Y
--
-- Takes in 3 parameters:
-- 1: new username
-- 2: new password
-- 3: Y/N create demo data

-- Must be run as SYS
whenever sqlerror exit sql.sqlcode

begin
  if upper(user) != 'SYS' then
    raise_application_error(-20000, 'User must be SYS');
  end if;
end;
/

-- Parameters: If using to create another user later on, just modify this section
define new_user_name = '&1'
define new_user_pass = '&2'
define create_demo_data_yn = '&3'

-- Create user
create user &new_user_name. identified by &new_user_pass. default tablespace users quota unlimited on users;
grant connect, create view, create job, create table, create synonym, create sequence, create trigger, create procedure, create any context, create type to &new_user_name.;
grant execute on utl_http to &new_user_name.;
grant execute on dbms_crypto to &new_user_name.;
grant execute on utl_file to &new_user_name.;


-- Optionally create the emp_dept users
-- Script idea from: https://ruepprich.wordpress.com/2010/04/28/conditional-branching-in-sqlplus-scripts/
column script_name new_value l_script_name

select decode(lower('&create_demo_data_yn'),'y','emp_dept.sql','noop.sql') script_name
from dual;

prompt Altering session to: &new_user_name.
alter session set current_schema=&new_user_name.;

@&l_script_name.

-- Should be run as SYS

-- Configuration: If using to create another user later on, just modify this section
define new_user_name = 'OOS_ORACLE_USER_NAME'
define new_user_pass = 'OOS_ORACLE_USER_PASS'

-- Create user
create user &new_user_name. identified by &new_user_pass. default tablespace users quota unlimited on users;
grant connect,create view, create job, create table, create sequence, create trigger, create procedure, create any context, create type to &new_user_name.;
grant execute on utl_http to &new_user_name.;
grant execute on dbms_crypto to &new_user_name.;
grant execute on utl_file to &new_user_name.;


exit

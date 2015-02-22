-- Should be run as SYS
create user OOS_ORACLE_USER_NAME identified by OOS_ORACLE_USER_PASS default tablespace users quota unlimited on users;
grant connect,create view, create job, create table, create sequence, create trigger, create procedure, create any context, create type to OOS_ORACLE_USER_NAME;
grant execute on utl_http to OOS_ORACLE_USER_NAME;
grant execute on dbms_crypto to OOS_ORACLE_USER_NAME;
grant execute on utl_file to OOS_ORACLE_USER_NAME;


exit

/*

Default tablespace verified with the query:

select *
from database_properties
where property_name = 'DEFAULT_PERMANENT_TABLESPACE';

*/

set define '^'
set verify off

ACCEPT default_tbs CHAR PROMPT 'Please enter the tablespace you would like to make the default [USERS]: '

declare
    l_new_tablespace varchar2(50);
begin

    l_new_tablespace := '^default_tbs';

    if l_new_tablespace IS NULL
    then
        l_new_tablespace := 'USERS';
    end if;

    execute immediate 'alter database default tablespace ' || l_new_tablespace;

end;
/

exit

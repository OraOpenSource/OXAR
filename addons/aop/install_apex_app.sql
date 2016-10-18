-- Should be run as SYS
-- Install APEX application
--
-- Example: sqlplus sys/oracle@localhost:1521/xe as sysdba @install_apex_app my_workspace my_schema app_id app_alias my_apex_app.sql
-- sqlplus sys/oracle@localhost:1521/xe as sysdba @install_apex_app AOP AOP 500 AOP aop_sample_apex_app.sql
--
-- Takes in 4 parameters:
-- 1: Workspace Name
-- 2: Workspace Schema
-- 3: Application Id
-- 4: Application Alias
-- 5: The sql file which contains the exported APEX app e.g. aop_sample_apex_app.sql


-- Must be run as SYS
whenever sqlerror exit sql.sqlcode

begin
  if upper(user) != 'SYS' then
    raise_application_error(-20000, 'User must be SYS');
  end if;
end;
/

define workspace_name = '&1'
define workspace_schema = '&2'
define app_id = '&3'
define app_alias = '&4'
define apex_app = '&5'

declare
    l_workspace_id number;
	
	-- command line configuration 
	l_workspace_name varchar2(100) := upper('&workspace_name');
	l_application_id number := &app_id;
	l_parsing_schema varchar2(100) := upper('&workspace_schema');
begin
    select workspace_id into l_workspace_id
      from apex_workspaces
     where upper(workspace) = upper(l_workspace_name);
    --
    apex_application_install.set_workspace_id(l_workspace_id);
    apex_application_install.set_application_id(l_application_id);
    apex_application_install.generate_offset;
    apex_application_install.set_schema(l_parsing_schema);
    apex_application_install.set_application_alias('&app_alias');
end;
/

@&apex_app
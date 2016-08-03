-- Should be run as SYS
-- Example: sqlplus sys/oracle@localhost:1521/xe as sysdba @create_workspace martin my_schema
--
-- Create APEX Workspace
--
-- Takes in 2 parameters:
-- 1: Workspace Name
-- 2: Workspace Schema


whenever sqlerror exit sql.sqlcode

-- Parameters
define workspace_name = '&1'
define workspace_schema = '&2'

-- Must be run as SYS
begin
  if upper(user) != 'SYS' then
    raise_application_error(-20000, 'User must be SYS');
  end if;
end;
/


declare
  l_workspace_id apex_workspaces.workspace_id%type;
begin
  select workspace_id
  into l_workspace_id
  from apex_workspaces
  where workspace = upper('internal');

  wwv_flow_api.set_security_group_id(l_workspace_id);

  apex_instance_admin.add_workspace (
    p_workspace_id => null,
    p_workspace => upper('&workspace_name'),
    p_primary_schema => upper('&workspace_schema'),
    p_additional_schemas => '');
end;
/

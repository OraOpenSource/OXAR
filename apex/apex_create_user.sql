-- Should be run as SYS
-- Create APEX Workspace User
--
-- Example: sqlplus sys/oracle@localhost:1521/xe as sysdba @apex_create_user martin my_schema martin password
--
-- Takes in 4 parameters:
-- 1: Workspace Name
-- 2: Workspace Schema
-- 3: APEX New Username
-- 4: APEX New Password


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
define workspace_user_name = '&3'
define workspace_user_pass = '&4'



declare
  l_workspace_id apex_workspaces.workspace_id%type;
begin
  select workspace_id
  into l_workspace_id
  from apex_workspaces
  where workspace = upper('&workspace_name');

  wwv_flow_api.set_security_group_id(l_workspace_id);

  apex_util.create_user(
    p_user_name => '&workspace_user_name',
    p_web_password => '&workspace_user_pass',
    p_change_password_on_first_use => 'N',
    p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
    p_default_schema => '&workspace_schema',
    p_allow_app_building_yn => 'Y',
    p_allow_sql_workshop_yn => 'Y',
    p_allow_websheet_dev_yn => 'Y',
    p_allow_team_development_yn => 'Y');
end;
/

-- Should be run as SYS
-- Create APEX Workspace

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
    p_workspace => 'OOS_APEX_USER_WORKSPACE',
    p_primary_schema => 'OOS_ORACLE_USER_NAME',
    p_additional_schemas => '');

  select workspace_id
  into l_workspace_id
  from apex_workspaces
  where workspace = upper('OOS_APEX_USER_WORKSPACE');

  wwv_flow_api.set_security_group_id(l_workspace_id);

  apex_util.create_user(
    p_user_name => 'OOS_APEX_USER_NAME',
    p_web_password => 'OOS_APEX_USER_PASS',
    p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
    p_default_schema => 'OOS_ORACLE_USER_NAME',
    p_allow_app_building_yn => 'Y',
    p_allow_sql_workshop_yn => 'Y',
    p_allow_websheet_dev_yn => 'Y',
    p_allow_team_development_yn => 'Y');
end;
/


exit

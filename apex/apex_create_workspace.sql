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
end;
/


exit

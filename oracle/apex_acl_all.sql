-- From: https://docs.oracle.com/cd/E59726_01/install.50/e39144/listener.htm#HTMIG29162
-- With some modifications to handle multiple APEX version numbers

declare
  acl_path varchar2(4000);
  l_apex_username all_users.username%type;
begin

  if upper(user) != 'SYS' then
    raise_application_error(-20000, 'User must be SYS');
  end if;

  -- Look for the ACL currently assigned to '*' and give APEX_050000
  -- the "connect" privilege if APEX_050000 does not have the privilege yet.

  -- To support backwards compatibility with APEX 4.2 and APEX 5.0 need to find max APEX version
  l_apex_username := apex_application.g_flow_schema_owner;

  select acl
  into acl_path
  from dba_network_acls
  where host = '*'
    and lower_port is null
    and upper_port is null;

  if dbms_network_acl_admin.check_privilege(acl_path, l_apex_username, 'connect') IS NULL THEN
    dbms_network_acl_admin.add_privilege(
      acl_path,
      l_apex_username,
      true,
      'connect');
  end if;

exception
  -- when no acl has been assigned to '*'.
  when no_data_found then
    dbms_network_acl_admin.create_acl(
      'power_users.xml',
      'ACL that lets power users to connect to everywhere',
      l_apex_username,
      true, 'connect');
    dbms_network_acl_admin.assign_acl('power_users.xml','*');
end;
/
commit;

-- Can check the network ACLS using the following queries
--
-- select host, lower_port, upper_port, acl
-- from dba_network_acls;
--
-- select acl, principal
-- from dba_network_acl_privileges;
--

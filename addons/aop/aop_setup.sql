-- Takes in the following parameters:
-- 1: AOP user name

define aop_user_name = '&1'


declare
  c_acl constant varchar2(255) := 'aop.xml';
  l_apex_schema varchar2(30);
begin

  select schema
    into l_apex_schema
    from dba_registry
   where comp_id = 'APEX';
 
  if upper(user) != 'SYS' then
    raise_application_error(-20000, 'User must be SYS');
  end if;

  dbms_network_acl_admin.create_acl(
    c_acl,
    'AOP ACL',
    l_apex_schema,
    true,
    'connect');
  dbms_network_acl_admin.assign_acl(c_acl,'www.apexofficeprint.com');

  commit;
end;
/

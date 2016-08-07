-- Takes in the following parameters:
-- 1: AOP user name

define aop_user_ame = '&1'


declare
  c_acl constant varchar2(255) := 'aop.xml';
begin

  if upper(user) != 'SYS' then
    raise_application_error(-20000, 'User must be SYS');
  end if;

  dbms_network_acl_admin.create_acl(
    c_acl,
    'AOP ACL',
    '&aop_user_ame.',
    true,
    'connect');
  dbms_network_acl_admin.assign_acl(c_acl,'*');

  commit;
end;
/

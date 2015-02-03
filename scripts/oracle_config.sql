-- Substitution Strings
-- OOS_APEX_PUB_USR_PWD


-- Required
alter user apex_public_user account unlock;
alter user apex_public_user identified by OOS_APEX_PUB_USR_PWD;

-- Optional

-- APEX configurations
-- exec apex_instance_admin.set_parameter(p_parameter => 'STRONG_SITE_ADMIN_PASSWORD', p_value => 'N');
-- exec apex_instance_admin.set_parameter(p_parameter => 'WORKSPACE_PROVISION_DEMO_OBJECTS', p_value => 'N');
-- exec apex_instance_admin.set_parameter(p_parameter => 'WORKSPACE_WEBSHEET_OBJECTS', p_value => 'N');

-- APEX SMTP setup
-- exec apex_instance_admin.set_parameter(p_parameter => 'SMTP_HOST_ADDRESS', p_value => '');
-- exec apex_instance_admin.set_parameter(p_parameter => 'SMTP_HOST_PORT', p_value => '');
-- exec apex_instance_admin.set_parameter(p_parameter => 'SMTP_USERNAME', p_value => '');
-- exec apex_instance_admin.set_parameter(p_parameter => 'SMTP_PASSWORD', p_value => '');
-- exec apex_instance_admin.set_parameter(p_parameter => 'SMTP_TLS_MODE', p_value => 'Y');

-- Oracle Wallet (required for SSL connections)
-- exec apex_instance_admin.set_parameter(p_parameter => 'WALLET_PATH', p_value => '');
-- exec apex_instance_admin.set_parameter(p_parameter => 'WALLET_PWD', p_value => '');


-- Don't expire passwords
alter profile default limit password_life_time unlimited;

-- Disable XML configuration
exec dbms_xdb.sethttpport(0);

exit

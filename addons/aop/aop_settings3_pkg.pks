create or replace package aop_settings3_pkg
AUTHID CURRENT_USER
as

/* Copyright 2017 - APEX RnD
*/

-- AOP Plug-in Component Settings

-- AOP Server url
g_aop_url    varchar2(100) := 'http://www.apexofficeprint.com/api/';

-- AOP API Key; only needed when AOP Cloud is used (http(s)://www.apexofficeprint.com/api)
g_api_key    varchar2(50) := '1C511A58ECC73874E0530100007FD01A';

-- Set AOP in Debug mode
-- options: Local, Yes(=Remote), No
g_debug      varchar2(10) := 'No';

-- Set the converter to go to PDF (or other format different from template)
-- options: null (LibreOffice), officetopdf (MS Office - Windows only), abiword (Abiword - Linux only)
g_converter  varchar2(50) := null;


end aop_settings3_pkg;
/

set define off verify off feedback off

create or replace package aop_api3_pkg
AUTHID CURRENT_USER
as

/* Copyright 2017 - APEX RnD
*/

-- AOP Version
c_aop_version            constant varchar2(5) := '3.0';
c_aop_url                constant varchar2(50) := 'http://www.apexofficeprint.com/api/';

-- Global variables
-- Call to AOP
g_proxy_override          varchar2(300) := null;  -- null=proxy defined in the application attributes
g_transfer_timeout        number(6)     := 1800;  -- default of APEX is 180
g_wallet_path             varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
g_wallet_pwd              varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
g_output_filename         varchar2(100) := null;  -- output
g_language                varchar2(2)   := 'en';  -- Language can be: en, fr, nl, de
g_logging                 clob          := '';    -- ability to add your own logging: e.g. "request_id":"123", "request_app":"APEX", "request_user":"RND"
-- AOP settings for Interactive Report (see also Printing attributes in IR)
g_rpt_header_font_name    varchar2(50)  := '';    -- Arial - see https://www.microsoft.com/typography/Fonts/product.aspx?PID=163
g_rpt_header_font_size    varchar2(3)   := '';    -- 14
g_rpt_header_font_color   varchar2(50)  := '';    -- #071626
g_rpt_header_back_color   varchar2(50)  := '';    -- #FAFAFA
g_rpt_header_border_width varchar2(50)  := '';    -- 1 ; '0' = no border
g_rpt_header_border_color varchar2(50)  := '';    -- #000000
g_rpt_data_font_name      varchar2(50)  := '';    -- Arial - see https://www.microsoft.com/typography/Fonts/product.aspx?PID=163
g_rpt_data_font_size      varchar2(3)   := '';    -- 14
g_rpt_data_font_color     varchar2(50)  := '';    -- #000000
g_rpt_data_back_color     varchar2(50)  := '';    -- #FFFFFF
g_rpt_data_border_width   varchar2(50)  := '';    -- 1 ; '0' = no border
g_rpt_data_border_color   varchar2(50)  := '';    -- #000000
g_rpt_data_alt_row_color  varchar2(50)  := '';    -- #FFFFFF for no alt row color, use same color as g_rpt_data_back_color
-- Call to URL data source
g_url_username            varchar2(300) := null;
g_url_password            varchar2(300) := null;
g_url_proxy_override      varchar2(300) := null;
g_url_transfer_timeout    number        := 180;
g_url_body                clob          := empty_clob();
g_url_body_blob           blob          := empty_blob();
g_url_parm_name           apex_application_global.vc_arr2; --:= empty_vc_arr;
g_url_parm_value          apex_application_global.vc_arr2; --:= empty_vc_arr;
g_url_wallet_path         varchar2(300) := null;
g_url_wallet_pwd          varchar2(300) := null;


-- Constants
c_source_type_apex       constant varchar2(4) := 'APEX';
c_source_type_workspace  constant varchar2(9) := 'WORKSPACE';
c_source_type_sql        constant varchar2(3) := 'SQL';
c_source_type_plsql      constant varchar2(5) := 'PLSQL';
c_source_type_plsql_sql  constant varchar2(9) := 'PLSQL_SQL';
c_source_type_filename   constant varchar2(8) := 'FILENAME';
c_source_type_url        constant varchar2(3) := 'URL';
c_source_type_rpt        constant varchar2(6) := 'IR';
c_mime_type_docx         constant varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
c_mime_type_xlsx         constant varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
c_mime_type_pptx         constant varchar2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
c_mime_type_pdf          constant varchar2(100) := 'application/pdf';
c_mime_type_html         constant varchar2(100) := 'text/html';
c_mime_type_markdown     constant varchar2(100) := 'text/markdown';
c_mime_type_rtf          constant varchar2(100) := 'application/rtf';
c_mime_type_json         constant varchar2(100) := 'application/json';
c_output_encoding_raw    CONSTANT VARCHAR2(3) := 'raw';
c_output_encoding_base64 CONSTANT VARCHAR2(6) := 'base64';


-- Types
--type t_bind_record is record(name varchar2(100), value varchar2(32767));
--type t_bind_table  is table of t_bind_record index by pls_integer;
c_binds wwv_flow_plugin_util.t_bind_list;


-- Useful functions

-- convert a url with for example an image to base64
function url2base64 (
  p_url in varchar2)
  return clob;

-- get the value of one of the above constants
function getconstantvalue (
  p_constant in varchar2)
  return varchar2 deterministic;

-- get the mime type of a file extention: docx, xlsx, pptx, pdf
function getmimetype (
  p_file_ext in varchar2)
  return varchar2 deterministic;

-- convert a blob to a clob
function blob2clob(p_blob in blob)
  return clob;

-- Manual call to AOP
-- p_aop_remote_debug: Yes (=Remote) / No / Local
function plsql_call_to_aop(
  p_data_type             in varchar2 default c_source_type_sql,
  p_data_source           in clob,
  p_template_type         in varchar2 default c_source_type_apex,
  p_template_source       in clob,
  p_output_type           in varchar2,
  p_output_filename       in out nocopy varchar2,
  p_output_type_item_name in varchar2 default null,
  p_output_to             in varchar2 default null,
  p_procedure             in varchar2 default null,
  p_binds                 in wwv_flow_plugin_util.t_bind_list default c_binds,
  p_special               in varchar2 default null,
  p_aop_remote_debug      in varchar2 default 'No',
  p_output_converter      in varchar2 default null,
  p_aop_url               in varchar2,
  p_api_key               in varchar2,
  p_app_id                in number default null,
  p_page_id               in number default null,
  p_user_name             in varchar2 default null,
  p_init_code             in clob default 'null;',
  p_output_encoding       IN varchar2 default c_output_encoding_raw)
  return blob;


-- APEX Plugins

-- Process Type Plugin
function f_process_aop(
  p_process in apex_plugin.t_process,
  p_plugin  in apex_plugin.t_plugin)
  return apex_plugin.t_process_exec_result;

-- Dynamic Action Plugin
function f_render_aop (
  p_dynamic_action in apex_plugin.t_dynamic_action,
  p_plugin         in apex_plugin.t_plugin)
  return apex_plugin.t_dynamic_action_render_result;

function f_ajax_aop(
  p_dynamic_action in apex_plugin.t_dynamic_action,
  p_plugin         in apex_plugin.t_plugin)
  return apex_plugin.t_dynamic_action_ajax_result;


-- Other Procedure

-- Create an APEX session from PL/SQL
-- p_enable_debug: Yes / No (default)
procedure create_apex_session(
  p_app_id       in apex_applications.application_id%type,
  p_user_name    in apex_workspace_sessions.user_name%type default 'ADMIN',
  p_page_id      in apex_application_pages.page_id%type default null,
  p_session_id   in apex_workspace_sessions.apex_session_id%type default null,
  p_enable_debug in varchar2 default 'No');

-- Get the current APEX Session
function get_apex_session
  return apex_workspace_sessions.apex_session_id%type;

-- Join an APEX Session
procedure join_apex_session(
  p_session_id   in apex_workspace_sessions.apex_session_id%type,
  p_app_id       in apex_applications.application_id%type default null,
  p_enable_debug in varchar2 default 'No');

-- Drop the current APEX Session
procedure drop_apex_session(
  p_app_id     in apex_applications.application_id%type);

end aop_api3_pkg;
/
create or replace package body aop_api3_pkg wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
24a9c 7616
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
IPLW/Q==

/
create or replace package aop_plsql3_pkg
AUTHID CURRENT_USER
as

/* Copyright 2017 - APEX RnD
*/

-- AOP Version
c_aop_version  constant varchar2(5)   := '3.0';

--
-- Pre-requisites: apex_web_service package
-- if APEX is not installed, you can use this package as your starting point
-- but you would need to change the apex_web_service calls by utl_http calls or similar
--


--
-- Change following variables for your environment
--
g_aop_url  varchar2(200) := 'http://www.apexofficeprint.com/api/';
g_api_key  varchar2(200) := '1C511A58ECC73874E0530100007FD01A';

-- Global variables
-- Call to AOP
g_proxy_override          varchar2(300) := null;  -- null=proxy defined in the application attributes
g_transfer_timeout        number(6)     := 180;   -- default is 180
g_wallet_path             varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
g_wallet_pwd              varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings

-- Constants
c_mime_type_docx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
c_mime_type_xlsx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
c_mime_type_pptx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
c_mime_type_pdf         varchar2(100) := 'application/pdf';

function make_aop_request(
  p_aop_url          in varchar2 default g_aop_url,
  p_api_key          in varchar2 default g_api_key,
  p_json             in clob,
  p_template         in blob,
  p_output_type      in varchar2 default null,
  p_output_filename  in varchar2 default 'output',
  p_aop_remote_debug in varchar2 default 'No')
  return blob;

end aop_plsql3_pkg;
/
create or replace package body aop_plsql3_pkg as


function replace_with_clob(
   p_source in clob
  ,p_search in varchar2
  ,p_replace in clob
) return clob
as
  l_pos pls_integer;
begin
  l_pos := instr(p_source, p_search);
  if l_pos > 0 then
    return substr(p_source, 1, l_pos-1)
      || p_replace
      || substr(p_source, l_pos+length(p_search));
  end if;
  return p_source;
end replace_with_clob;


function make_aop_request(
  p_aop_url          in varchar2 default g_aop_url,
  p_api_key          in varchar2 default g_api_key,
  p_json             in clob,
  p_template         in blob,
  p_output_type      in varchar2 default null,
  p_output_filename  in varchar2 default 'output',
  p_aop_remote_debug in varchar2 default 'No')
  return blob
as
  l_output_converter  varchar2(20) := ''; --default
  l_aop_json          clob;
  l_template_clob     clob;
  l_template_type     varchar2(4);
  l_data_json         clob;
  l_output_type       varchar2(4);
  l_blob              blob;
  l_error_description varchar2(32767);
begin
  l_template_clob := apex_web_service.blob2clobbase64(p_template);
  l_template_clob := replace(l_template_clob, chr(13) || chr(10), null);
  l_template_clob := replace(l_template_clob, '"', '\u0022');
  if dbms_lob.instr(p_template, utl_raw.cast_to_raw('ppt/presentation'))> 0
  then
    l_template_type := 'pptx';
  elsif dbms_lob.instr(p_template, utl_raw.cast_to_raw('worksheets/'))> 0
  then
    l_template_type := 'xlsx';
  elsif dbms_lob.instr(p_template, utl_raw.cast_to_raw('word/document'))> 0
  then
    l_template_type := 'docx';
  else
    l_template_type := 'unknown';
  end if;

  if p_output_type is null
  then
    l_output_type := l_template_type;
  else
    l_output_type := p_output_type;
  end if;

  l_data_json := p_json;

  l_aop_json := '
  {
      "version": "***AOP_VERSION***",
      "api_key": "***AOP_API_KEY***",
      "aop_remote_debug": "***AOP_REMOTE_DEBUG***",
      "template": {
        "file":"***AOP_TEMPLATE_BASE64***",
         "template_type": "***AOP_TEMPLATE_TYPE***"
      },
      "output": {
        "output_encoding": "base64",
        "output_type": "***AOP_OUTPUT_TYPE***",
        "output_converter": "***AOP_OUTPUT_CONVERTER***"
      },
      "files":
        ***AOP_DATA_JSON***
  }';

  l_aop_json := replace(l_aop_json, '***AOP_VERSION***', c_aop_version);
  l_aop_json := replace(l_aop_json, '***AOP_API_KEY***', p_api_key);
  l_aop_json := replace(l_aop_json, '***AOP_REMOTE_DEBUG***', p_aop_remote_debug);
  l_aop_json := replace_with_clob(l_aop_json, '***AOP_TEMPLATE_BASE64***', l_template_clob);
  l_aop_json := replace_with_clob(l_aop_json, '***AOP_TEMPLATE_TYPE***', l_template_type);
  l_aop_json := replace(l_aop_json, '***AOP_OUTPUT_TYPE***', l_output_type);
  l_aop_json := replace(l_aop_json, '***AOP_OUTPUT_CONVERTER***', l_output_converter);
  l_aop_json := replace_with_clob(l_aop_json, '***AOP_DATA_JSON***', l_data_json);
  l_aop_json := replace(l_aop_json, '\\n', '\n');

  apex_web_service.g_request_headers(1).name := 'Content-Type';
  apex_web_service.g_request_headers(1).value := 'application/json';

  begin
    l_blob := apex_web_service.make_rest_request_b(
      p_url              => p_aop_url,
      p_http_method      => 'POST',
      p_body             => l_aop_json,
      p_proxy_override   => g_proxy_override,
      p_transfer_timeout => g_transfer_timeout,
      p_wallet_path      => g_wallet_path,
      p_wallet_pwd       => g_wallet_pwd);
  exception
  when others
  then
    raise_application_error(-20001,'Issue calling AOP Service (REST call: ' || apex_web_service.g_status_code || '): ' || CHR(10) || SQLERRM);
  end;

  -- read header variable and create error message
  -- HTTP Status Codes:
  --  200 is normal
  --  500 error received
  --  503 Service Temporarily Unavailable, the AOP server is probably not running
  if apex_web_service.g_status_code = 200
  then
    l_error_description := null;
  elsif apex_web_service.g_status_code = 503
  then
    l_error_description := 'AOP Server not running.';
  elsif apex_web_service.g_status_code = 500
  then
    for l_loop in 1.. apex_web_service.g_headers.count loop
      if apex_web_service.g_headers(l_loop).name = 'error_description'
      then
        l_error_description := apex_web_service.g_headers(l_loop).value;
        -- errors returned by AOP server are base64 encoded
        l_error_description := utl_encode.text_decode(l_error_description, 'AL32UTF8', UTL_ENCODE.BASE64);
      end if;
    end loop;
  else
    l_error_description := 'Unknown error. Check AOP server logs.';
  end if;

  -- YOU CAN STORE THE L_BLOB TO A LOCAL DEBUG TABLE AS AOP SERVER RETURNS A DOCUMENT WITH MORE INFORMATION
  --

  -- check if succesfull
  if apex_web_service.g_status_code <> 200
  then
    raise_application_error(-20002,'Issue returned by AOP Service (REST call: ' || apex_web_service.g_status_code || '): ' || CHR(10) || l_error_description);
  end if;

  -- return print
  return l_blob;

end make_aop_request;

end aop_plsql3_pkg;
/

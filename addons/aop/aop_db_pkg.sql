set define off verify off feedback off

create or replace package aop_api2_pkg
AUTHID CURRENT_USER
as

/* Copyright 2016 - APEX R&D
*/

-- AOP Version
c_aop_version            constant varchar2(5) := '2.4';


-- Global variables
-- Call to AOP
g_proxy_override          varchar2(300) := null;  -- null=proxy defined in the application attributes
g_transfer_timeout        number(6)     := 180;   -- default is 180
g_wallet_path             varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
g_wallet_pwd              varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
-- AOP settings for Interactive Report (see also Printing attributes in IR)
g_output_filename         varchar2(100) := null;  -- output
g_language                varchar2(2)   := 'en';  -- Language can be: en, fr, nl, de
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
g_url_parm_name           apex_application_global.vc_arr2; -- := empty_vc_arr;
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


-- Manual call to AOP
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
  p_init_code             in clob default 'null;')
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

end aop_api2_pkg;
/
create or replace package body aop_api2_pkg wrapped 
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
14f89 4b70
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

/
create or replace package aop_plsql2_pkg
AUTHID CURRENT_USER
as

/* Copyright 2016 - APEX R&D
*/

-- AOP Version
c_aop_version  constant varchar2(5)   := '2.4';

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

end aop_plsql2_pkg;
/
create or replace package body aop_plsql2_pkg as


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
  l_output_converter varchar2(20) := ''; --default
  l_aop_json         clob;
  l_template_clob    clob;
  l_template_type    varchar2(4);
  l_data_json        clob;
  l_output_type      varchar2(4);
  l_clob             clob;
  l_return           blob;
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

  l_clob := apex_web_service.make_rest_request(
    p_url => p_aop_url,
    p_http_method => 'POST',
    p_body => l_aop_json);

  l_return := apex_web_service.clobbase642blob (p_clob => l_clob);

  return l_return;

end make_aop_request;

end aop_plsql2_pkg;
/

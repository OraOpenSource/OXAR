create or replace package aop_api2_pkg as

/* Copyright 2016 - APEX R&D
*/

-- AOP Version  
c_aop_version            constant varchar2(5) := '2.2';     


-- Global variables
-- Language can be: en, fr, nl, de
g_language varchar2(2) := 'en';


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
  p_page_id               in number default null)
  return blob;


-- APEX Plugin
function f_process_aop(
  p_process in apex_plugin.t_process,
  p_plugin  in apex_plugin.t_plugin)
  return apex_plugin.t_process_exec_result;


-- Other Procedure

-- Create an APEX session from PL/SQL
-- to workarround the issue in pure PL/SQL an undocument feature is used
-- in APEX 5.1 this needs to be replaced by an official call
procedure create_apex_session (
    p_app_id  number,
    p_page_id number 
);

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
ed77 37d7
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

/
create or replace package aop_plsql2_pkg as

/* Copyright 2016 - APEX R&D
*/

-- AOP Version
c_aop_version  constant varchar2(5)   := '2.2';

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

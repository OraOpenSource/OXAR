create or replace package AOP_API_PKG as

--
-- Change following variables for your environment
--
g_aop_url  varchar2(200) := 'http://www.apexofficeprint.com/api/';
g_api_key  varchar2(200) := '1C511A58ECC73874E0530100007FD01A';
g_app_id   number        := 232;

-- AOP Version
c_version constant varchar2(5)   := '2.1';

-- Constants
c_source_type_apex      constant varchar2(4) := 'APEX';
c_source_type_workspace constant varchar2(9) := 'WORKSPACE';  
c_source_type_sql       constant varchar2(3) := 'SQL';
c_source_type_plsql     constant varchar2(5) := 'PLSQL';
c_source_type_filename  constant varchar2(8) := 'FILENAME';
c_source_type_url       constant varchar2(3) := 'URL';
c_source_type_rpt       varchar2(6) := 'IR';  
c_mime_type_docx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; 
c_mime_type_xlsx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
c_mime_type_pptx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
c_mime_type_pdf         varchar2(100) := 'application/pdf';  

-- Types
type t_bind_record is record (
  name  varchar2(100),
  value varchar2(32767)
);

type t_bind_table is table of t_bind_record index by binary_integer;

c_binds t_bind_table;

-- Manual call to AOP
function plsql_call_to_aop(
  p_data_type       in varchar2 default c_source_type_sql,
  p_data_source     in varchar2,
  p_template_type   in varchar2 default c_source_type_apex,
  p_template_source in varchar2,
  p_output_type     in varchar2,
  p_output_filename in varchar2 default 'output',
  p_binds           in t_bind_table default c_binds,
  p_aop_remote_debug in varchar2 default 'No')
  return blob;

-- Call with APEX Plugin to AOP
function f_process_aop(
  p_process in apex_plugin.t_process,
  p_plugin  in apex_plugin.t_plugin )
  return apex_plugin.t_process_exec_result;
  
end AOP_API_PKG;
/

create or replace package body AOP_API_PKG as
 
--
-- Helper functions
--
-- assert function
procedure assert(
  p_condition in boolean,
  p_message in varchar2)
as
begin
  if not p_condition or p_condition is null then
    raise_application_error(-20000, p_message);
  end if;
end assert;
 
--
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
 
-- Removes leading { and trailing } on JSON
procedure unwrap_json(p_json in out clob)
as
begin
  -- Remove the {} wrappers
  p_json := trim(leading '{' from p_json);
  p_json := trim(trailing '}' from p_json);
end unwrap_json;
                                 
-- Check for valid JSON
procedure validate_json (p_json in clob, p_type in varchar2)
as
  c_check_json  varchar2(10) := 'valid JSON' ;                                 
  l_check_json  varchar2(10);                                 
begin
  apex_debug.message('AOP: Validate JSON ' || p_type);                                
  $if dbms_db_version.VER_LE_11_2
  $then
    -- we can not check as the feature only became available in 12c                              
    l_check_json := c_check_json;
  $elsif dbms_db_version.VER_LE_12
  $then
    -- we can not check as the feature only became available in 12c                              
    l_check_json := c_check_json;
  $elsif dbms_db_version.VER_LE_12_1 
  $then
    -- we can not check as the feature only became available in 12c                              
    l_check_json := c_check_json;
  $else                               
    select case when p_json is json 
                then c_check_json 
            end as check_json 
      into l_check_json                                   
      from dual;                                 
  $end                                
  assert(l_check_json = c_check_json, 'Invalid JSON for ' || p_type);                               
end validate_json;  
 
--
  function get_json(
    p_data_type in varchar2,
    p_data_source_sql in varchar2,
    p_data_source_plsql in varchar2,
    p_data_source_url in varchar2,
    p_json_type in varchar2,
    p_binds     in t_bind_table default c_binds)
    return clob
  as
    l_sql               varchar2(4000);
    l_return            clob;
    l_template          clob;
    l_template_type     varchar2(4);
    l_data              clob;
    l_data_type_list    apex_application_global.vc_arr2;
    l_column_value_list apex_plugin_util.t_column_value_list2;
    l_binds             dbms_sql.varchar2_table;
    l_ireport           apex_ir.t_report;
    l_region_id         number;    
    l_source_type       varchar2(20);
    l_region_source     clob;
    l_cursor            binary_integer;
    l_ref_cursor        sys_refcursor;
    l_exec              binary_integer;  

  begin    
    apex_debug.message('AOP: p_data_type: %s', p_data_type);

    if p_data_type = c_source_type_apex then
      begin
          select substr(filename, -4) as template_type, apex_web_service.blob2clobbase64(blob_content) as template
            into l_template_type, l_template
            from apex_application_files
           where filename = p_data_source_url
             and flow_id  = g_app_id;
      exception
        when no_data_found
        then
          raise_application_error(-20001, 'Template not found in Shared Components > Application Files');
      end;  
      
      l_template := replace(l_template, chr(13) || chr(10), null);
      l_template := replace(l_template, '"', '\u0022');
      l_return :=
            '{"file":"' || l_template || '",' ||
            ' "template_type":"' || l_template_type || '"}';
            
    elsif p_data_type = c_source_type_workspace then
      begin
          select substr(file_name, -4) as template_type, apex_web_service.blob2clobbase64(document) as template
            into l_template_type, l_template
            from apex_workspace_files
           where file_name = p_data_source_url
             and rownum < 2;
      exception
        when no_data_found
        then
          raise_application_error(-20001, 'Template not found in Shared Components > Workspace Files');
      end;          
      
      l_template := replace(l_template, chr(13) || chr(10), null);
      l_template := replace(l_template, '"', '\u0022');
      l_return :=
            '{"file":"' || l_template || '",' ||
            ' "template_type":"' || l_template_type || '"}';

    elsif p_data_type = c_source_type_url then
      l_return := apex_web_service.make_rest_request(
        p_url => p_data_source_url,
        p_http_method => 'GET');

      -- Remove ORDS wrappers
      if regexp_count(l_return,'^{"items":\[') = 1 then
        apex_debug.message('AOP: ORDS item detected, removing wrappers');
        l_return := replace(l_return, '{"items":');
        -- Remove leading items
        l_return := regexp_replace(l_return,'^{"items":\', null);
        -- Remove trailing items
        l_return := regexp_replace(l_return,'}$', null);
      end if;

    elsif p_data_type = c_source_type_sql then

      apex_debug.message('AOP: p_json_type: %s', p_json_type);

      if p_json_type = 'template' then
          -- Setup columns
          l_data_type_list(1) := apex_plugin_util.c_data_type_varchar2;
          l_data_type_list(2) := apex_plugin_util.c_data_type_blob;

          l_column_value_list := apex_plugin_util.get_data2 (
            p_sql_statement => p_data_source_sql,
             p_min_columns => 2,
             p_max_columns => 2,
             p_data_type_list => l_data_type_list,
             p_component_name => null,
             p_search_type => apex_plugin_util.c_search_exact_case,
             p_search_column_no => 1,
             p_search_string => '%',
             p_first_row => 1,
             p_max_rows => 1);

          assert(l_column_value_list(1).value_list.count = 1, 'Got: ' || l_column_value_list(1).value_list.count || ' rows. Expecting 1 row');

          -- APEX get_data2 puts in carriage returns on clobs. Need to remove them for JSON
          l_template := apex_web_service.blob2clobbase64(l_column_value_list(2).value_list(1).blob_value);
          l_template := replace(l_template, chr(13) || chr(10), null);
          l_template := replace(l_template, '"', '\u0022');

          l_return :=
            '{"file":"' || l_template || '",' ||
            ' "template_type":"' || replace(l_column_value_list(1).value_list(1).varchar2_value,'"', '\u0022') || '"}';

      elsif p_json_type = 'data' then
          l_sql := p_data_source_sql;
          apex_debug.message('AOP: %s', l_sql);                         
          l_cursor := dbms_sql.open_cursor; 
          DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
          apex_debug.message('AOP: Get binds of report');                             
          l_binds := wwv_flow_utilities.get_binds(l_sql) ;
          apex_debug.message('AOP: Binds of report: %s', to_char(l_binds.count));                                                                
          for i in 1..l_binds.count
          loop
            apex_debug.message('AOP: Bind %s: %s', to_char(i), l_binds(i));                                                                                                   
            DBMS_SQL.BIND_VARIABLE(l_cursor, l_binds(i), v(replace(l_binds(i), ':', '')));
          end loop;   
          apex_debug.message('AOP: PL/SQL bind variables'); 
          apex_debug.message('AOP: Binds of report: ' || to_char(p_binds.count));                                                                
          for i in 1..p_binds.count
          loop
            apex_debug.message('AOP: PL/SQL Bind ' || to_char(i) || ': ' || p_binds(i).name || ': ' || p_binds(i).value); 
            dbms_output.put_line('AOP: Bind ' || to_char(i) || ': ' || p_binds(i).name || ': ' || p_binds(i).value);                                   
            DBMS_SQL.BIND_VARIABLE(l_cursor, p_binds(i).name, p_binds(i).value);
          end loop;          
          l_exec := DBMS_SQL.EXECUTE(l_cursor); 
          l_ref_cursor := dbms_sql.to_refcursor(l_cursor);                                  
    
          -- make sure APEX 5.01 or higher is installed, as the patchset will fix issues in apex_json
          apex_json.initialize_clob_output(dbms_lob.call, true, 2);
          apex_json.write(l_ref_cursor);  
          l_return := apex_json.get_clob_output;
          
      else       
         assert(false, 'Invalid json_type: ' || p_json_type);
      end if;

    elsif p_data_type = c_source_type_plsql then

      l_return := apex_plugin_util.get_plsql_func_result_clob(p_plsql_function => p_data_source_plsql);

      -- Cleanup APEX clobs
      l_return := replace(l_return, chr(13) || chr(10), null);

    elsif p_data_type = c_source_type_filename then

      l_return :=
            '{"filename":"' || p_data_source_url || '",' ||
            ' "template_type": "' || substr(p_data_source_url, -4) || '"}';
                                   
    else
      assert(false, 'Invalid data_type: ' || p_data_type);
    end if; -- p_data_type

    l_return := trim(l_return);
    return l_return;
                                   
  exception
  when others then
    -- Ensure that the cursor is closed.
    if DBMS_SQL.IS_OPEN(l_cursor) 
    then                               
      DBMS_SQL.CLOSE_CURSOR(l_cursor); 
    end if; 
    raise;
  end get_json;
 
-- Create an APEX session from PL/SQL
-- to workarround the issue in pure PL/SQL an undocument feature is used
-- in APEX 5.1 this needs to be replaced by an official call
procedure create_apex_session (
  p_app_id  number,
  p_page_id number default 101
)
as
  n         owa.vc_arr;
  v         owa.vc_arr;
begin
  -- check if an APEX session exists
  if apex_util.get_session_state('APP_ID') = p_app_id
  then 
    -- we already have an APEX session
    null;
  else 
    n(1) := 'HTTP_HOST';
    v(1) := 'localhost';
    owa.init_cgi_env(1,n,v);
    -- MAKE SURE APP and PAGE ID EXISTS
    f(p=>to_char(p_app_id)||':'||to_char(p_page_id)||'::FSP_SHOW_POPUPLOV');      
  end if;  
end create_apex_session;
 
--
-- Manual call to APEX Office Print (AOP) from PL/SQL
--
function plsql_call_to_aop (
  p_data_type        in varchar2 default c_source_type_sql,
  p_data_source      in varchar2,
  p_template_type    in varchar2 default c_source_type_apex,
  p_template_source  in varchar2,
  p_output_type      in varchar2,
  p_output_filename  in varchar2 default 'output',
  p_binds            in t_bind_table default c_binds,
  p_aop_remote_debug in varchar2 default 'No')
  return blob
as
  l_output_file_ext  varchar2(5);
  l_output_filename  varchar2(100);
  l_output_converter varchar2(20);
  l_aop_json      clob;
  l_template_json clob;
  l_data_json     clob;
  l_clob          clob;
  l_blob          blob;
  
begin
  apex_debug.message('AOP: begin procedure');
 
  -- create an APEX session
  -- apex_plugin_util.get_data2 requires an APEX session
  create_apex_session(p_app_id=> g_app_id);
  
  -- Validations
  apex_debug.message('AOP: Start Validation');
  assert(p_data_type in (c_source_type_url,c_source_type_sql,c_source_type_plsql), 'Invalid data type: ' || p_data_type);
  assert(p_template_type in (c_source_type_apex,c_source_type_sql,c_source_type_plsql,c_source_type_filename) or p_template_type is null, 'Invalid template type: ' || p_template_type);
  assert(p_output_type in ('docx','xlsx','pptx','pdf','rtf','html'), 'Invalid output type: ' || p_output_type);
  apex_debug.message('AOP: End Validation');
 
  -- Make sure it's extension is the same as the output type. If not, change it.
  l_output_file_ext := trim(leading '.' from lower(regexp_substr(p_output_filename, '[.]+[[:print:]]*$')));
  apex_debug.message('AOP: Filename Ext: %s', l_output_file_ext);
 
  if (l_output_file_ext <> 'zip' and l_output_file_ext != p_output_type) or l_output_file_ext is null then
    l_output_filename := l_output_filename || '.' || p_output_type;
  end if;  
  apex_debug.message('AOP: Filename: %s', l_output_filename);
 
  -- Create JSON to send to node.js
  l_aop_json := '
  {
      "version": "***AOP_VERSION***",
      "api_key": "***AOP_API_KEY***",
      "aop_remote_debug": "***AOP_REMOTE_DEBUG***",      
      "template": {
        ***AOP_TEMPLATE_JSON***
      },
      "output": {
        "output_encoding": "base64",
        "output_type": "***AOP_OUTPUT_TYPE***",
        "output_converter": "***AOP_OUTPUT_CONVERTER***"        
      },
      "files":  
        ***AOP_DATA_JSON***      
  }';

  -- Handle Filename
  if l_output_filename is null then
    l_output_filename := 'output';
  end if; -- l_output_filename is null

  -- Make sure it's extension is the same as the output type. If not, change it.
  l_output_file_ext := trim(leading '.' from lower(regexp_substr(l_output_filename, '[.]+[[:print:]]*$')));
  apex_debug.message('AOP: Filename Ext: %s', l_output_file_ext);

  if (l_output_file_ext <> 'zip' and l_output_file_ext != p_output_type) or l_output_file_ext is null then
    l_output_filename := l_output_filename || '.' || p_output_type;
  end if;
  apex_debug.message('AOP: Filename: %s', l_output_filename);
  
  apex_debug.message('AOP: Get JSON');
  l_data_json := get_json(p_data_type         => p_data_type, 
                          p_data_source_sql   => p_data_source, 
                          p_data_source_plsql => p_data_source,                           
                          p_data_source_url   => p_data_source,
                          p_json_type         => 'data',
                          p_binds             => p_binds);
  unwrap_json(p_json => l_data_json);
 
  if p_template_type is not null then
    apex_debug.message('AOP: Get Template');
    l_template_json := get_json(p_data_type         => p_template_type, 
                                p_data_source_sql   => p_template_source, 
                                p_data_source_plsql => p_template_source, 
                                p_data_source_url   => p_template_source, 
                                p_json_type         => 'template');
    unwrap_json(p_json => l_template_json);
  else
    apex_debug.message('AOP: Template is not defined, using standard AOP Sample Template');
    l_template_json := '"file": "", "template_type": "docx"';
  end if;
 
  validate_json (p_json => '{' || l_template_json || '}', p_type => 'Template');                            
  validate_json (p_json => l_data_json, p_type => 'Data');
                                   
  -- Need to use custom replace since the replace string is a clob                                                         
  l_aop_json := replace_with_clob(l_aop_json, '***AOP_TEMPLATE_JSON***', l_template_json);
  l_aop_json := replace_with_clob(l_aop_json, '***AOP_DATA_JSON***', l_data_json);
  l_aop_json := replace(l_aop_json, '***AOP_OUTPUT_TYPE***', p_output_type);
  l_aop_json := replace(l_aop_json, '***AOP_OUTPUT_CONVERTER***', l_output_converter);
  l_aop_json := replace(l_aop_json, '***AOP_API_KEY***', g_api_key);
  l_aop_json := replace(l_aop_json, '***AOP_VERSION***', c_version);
  l_aop_json := replace(l_aop_json, '***AOP_REMOTE_DEBUG***', nvl(p_aop_remote_debug,'No'));
  l_aop_json := replace(l_aop_json, '\\n', '\n');
 
  -- WHEN DEBUGGING THE JSON - INSTALL LOGGER AND UNCOMMENT NEXT ROW
  -- logger.log('l_aop_json', null, l_aop_json);
                                   
  apex_debug.message('AOP: Create collection with JSON that will be sent to AOP');
  if apex_application.g_debug
  then
    apex_collection.create_or_truncate_collection('AOP_DEBUG'); 
    apex_collection.add_member(
        p_collection_name => 'AOP_DEBUG',
        p_c001            => 'l_aop_json',
        p_d001            => sysdate,
        p_clob001         => l_aop_json);
  end if;
  apex_debug.message('AOP: Use following select statement to view the JSON');
  apex_debug.message('AOP: select clob001 from apex_collections where collection_name = ''AOP_DEBUG''');                                   
                                   
  -- Call AOP node.js
  apex_web_service.g_request_headers(1).name := 'Content-Type';
  apex_web_service.g_request_headers(1).value := 'application/json';
 
  -- For 1st party authentication
  -- http://www.oracle.com/technetwork/developer-tools/rest-data-services/documentation/listener-dev-guide-1979546.html#modify_the_application_to_use_first_party_authentication
  --apex_web_service.g_request_headers(apex_web_service.g_request_headers.count + 1).name := 'Apex-Session';
  --apex_web_service.g_request_headers(apex_web_service.g_request_headers.count).value := apex_application.g_flow_id || ', ' || apex_application.g_instance;
 
  -- APEX 4.2 we can only use apex_web_service.make_rest_request returning clob
  -- APEX 5.0 allows to use apex_web_service.make_rest_request_b so automatically we get back a blob and we don't need to do the conversion
  -- we would need to set the type to raw
  l_clob := apex_web_service.make_rest_request(
    p_url => g_aop_url,
    p_http_method => 'POST',
    p_body => l_aop_json);
 
  apex_debug.message('AOP: returned HTTP status code: ' || apex_web_service.g_status_code);
  assert(apex_web_service.g_status_code = 200, 'AOP Service is not available. Please verify the logs on the server and if AOP is running. Returned HTTP code: ' || apex_web_service.g_status_code);                                                                    
  -- HTTP Status Codes:
  --   200 is normal
  --   503 Service Temporarily Unavailable, the AOP server is probably not running                                 
  apex_debug.message('AOP: returned number of bytes: ' || dbms_lob.getlength(l_clob));
                                   
  l_blob := apex_web_service.clobbase642blob (p_clob => l_clob);
 
  apex_debug.message('AOP: Downloading file');
 
  apex_debug.message('AOP: End of APEX Office Print');
  
  return l_blob;
end plsql_call_to_aop;

 
--
-- APEX Plugin
--
function f_process_aop(
  p_process in apex_plugin.t_process,
  p_plugin  in apex_plugin.t_plugin )
  return apex_plugin.t_process_exec_result
as
  -- Constants
  c_source_type_apex      varchar2(4) := 'APEX';
  c_source_type_workspace varchar2(9) := 'WORKSPACE';  
  c_source_type_sql       varchar2(3) := 'SQL';
  c_source_type_plsql     varchar2(5) := 'PLSQL';
  c_source_type_filename  varchar2(8) := 'FILENAME';
  c_source_type_url       varchar2(3) := 'URL';
  c_source_type_rpt       varchar2(6) := 'IR';  
  c_mime_type_docx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; 
  c_mime_type_xlsx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  c_mime_type_pptx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
  c_mime_type_pdf         varchar2(100) := 'application/pdf';  
  c_application_id        number := apex_application.g_flow_id;
  c_page_id               number := apex_application.g_flow_step_id;
  c_session               number := v('APP_SESSION');
   
  -- Application Plugin Attributes
  l_aop_url               p_plugin.attribute_01%type := p_plugin.attribute_01;
  l_api_key               p_plugin.attribute_02%type := p_plugin.attribute_02;
  l_aop_remote_debug      p_plugin.attribute_03%type := p_plugin.attribute_03;
  l_output_converter      p_plugin.attribute_04%type := p_plugin.attribute_04;
  
  -- Item Plugin Attributes
  l_data_type             p_process.attribute_05%type := upper(p_process.attribute_05);
  l_data_source_sql       p_process.attribute_11%type := p_process.attribute_11;
  l_data_source_plsql     p_process.attribute_12%type := p_process.attribute_12;
  l_data_source_url       p_process.attribute_01%type := p_process.attribute_01;
  l_data_source_static_id p_process.attribute_13%type := p_process.attribute_13;

  l_template_type         p_process.attribute_06%type := upper(p_process.attribute_06);
  l_template_source_file  p_process.attribute_07%type := p_process.attribute_07;
  l_template_source_sql   p_process.attribute_09%type := p_process.attribute_09;
  l_template_source_plsql p_process.attribute_10%type := p_process.attribute_10;

  l_output_type           p_process.attribute_04%type := lower(p_process.attribute_04);
  l_output_type_item_name p_process.attribute_08%type := p_process.attribute_08; 
  l_output_filename       p_process.attribute_03%type := p_process.attribute_03; 
  l_output_to             p_process.attribute_14%type := upper(p_process.attribute_14); 
  l_special               p_process.attribute_02%type := p_process.attribute_02;
  l_procedure             p_process.attribute_15%type := p_process.attribute_15; 
  
  -- Variables
  l_version          varchar2(5) := '2.1';   
  l_output_file_ext  varchar2(255);
  l_data_json        clob;
  l_template_json    clob;
  l_aop_json         clob;
  l_clob             clob;
  l_blob             blob;
  l_check_json       varchar2(20);
  l_output_mime_type varchar2(100);
  
  -- Other variables
  l_return           apex_plugin.t_process_exec_result;


  -- Methods
  procedure assert(
    p_condition in boolean,
    p_message in varchar2)
  as
  begin
    if not p_condition or p_condition is null then
      raise_application_error(-20000, p_message);
    end if;
  end assert;


  -- Required to replace strings in clobs with another clob
  -- From: http://stackoverflow.com/questions/23126455/how-to-call-replace-with-clob-without-exceeding-32k
  function replace_with_clob(
    i_source in clob,
    i_search in varchar2,
    i_replace in clob
  ) return clob
  as
    l_pos pls_integer;
  begin
    l_pos := instr(i_source, i_search);
    if l_pos > 0 then
      return substr(i_source, 1, l_pos-1)
        || i_replace
        || substr(i_source, l_pos+length(i_search));
    end if;
    return i_source;
  end replace_with_clob;
  
  
  --
  function get_ireport_settings
  return clob
  as
    l_base_report_id number;
    l_report_id      number;
    l_region_id      number;
    l_ref_cursor     sys_refcursor;  
    l_settings       clob;
    l_columns        clob;
    l_highlights     clob;
    l_break          clob;
    l_computations   clob;
    l_output         clob;
    l_tmp            clob;
  begin
    apex_debug.message('AOP: Begin Interactive Report settings'); 

    apex_debug.message('AOP: Get the region_id based on the static id of the region');
    begin
      select r.region_id
        into l_region_id
        from APEX_APPLICATION_PAGE_REGIONS r
       where r.source_type in ('Interactive Report')
         and r.application_id = c_application_id
         and r.page_id        = c_page_id
         and r.static_id      = l_data_source_static_id;
       apex_debug.message('AOP: Region id: %s', to_char(l_region_id));
    exception
      when no_data_found
      then
        assert(false, 'Report region with static id not found: ' || l_data_source_static_id);
    end;
    
    apex_debug.message('AOP: SESSION: %s', to_char(c_session));

    begin
      l_base_report_id := APEX_IR.GET_LAST_VIEWED_REPORT_ID(p_page_id => c_page_id, p_region_id => l_region_id);

      select report_id
        into l_report_id
        from APEX_APPLICATION_PAGE_IR_RPT
       where application_id = c_application_id
         and page_id        = c_page_id
         and region_id      = l_region_id
         and session_id     = c_session
         and base_report_id = l_base_report_id;

      apex_debug.message('AOP: Report id of SESSION: %s', to_char(l_report_id));
    exception
    when no_data_found
    then
      l_report_id := APEX_IR.GET_LAST_VIEWED_REPORT_ID(p_page_id => c_page_id, p_region_id => l_region_id);
      apex_debug.message('AOP: Report id of API: %s', to_char(l_report_id));
    end;
    
    apex_debug.message('AOP: Column settings');
    open l_ref_cursor for 
    select column_alias, display_order, report_label, column_type, display_text_as, heading_alignment, column_alignment, format_mask
      from APEX_APPLICATION_PAGE_IR_COL
     where application_id = c_application_id
       and page_id = c_page_id
       and region_id = l_region_id
     order by display_order;
    apex_json.initialize_clob_output(dbms_lob.call, true, 2);
    apex_json.write(p_name => 'settings', p_cursor => l_ref_cursor);  
    l_settings := apex_json.get_clob_output;

    apex_debug.message('AOP: Columns');
    open l_ref_cursor for 
    select report_columns
      from APEX_APPLICATION_PAGE_IR_RPT
     where application_id = c_application_id
       and page_id        = c_page_id
       and region_id      = l_region_id
       and report_id      = l_report_id;
    apex_json.initialize_clob_output(dbms_lob.call, true, 2);
    apex_json.write(p_name => 'columns', p_cursor => l_ref_cursor);  
    l_columns := apex_json.get_clob_output;  
    
    apex_debug.message('AOP: Highlights');
    open l_ref_cursor for 
    select condition_column_name, condition_operator, condition_expr_type, condition_expression, condition_expression2,
         highlight_row_color, highlight_row_font_color, highlight_cell_color, highlight_cell_font_color
      from APEX_APPLICATION_PAGE_IR_COND
     where application_id    = c_application_id
       and page_id           = c_page_id
       and report_id         = l_report_id
       and condition_type    = 'Highlight'
       and condition_enabled = 'Yes'
     order by highlight_sequence;
    apex_json.initialize_clob_output(dbms_lob.call, true, 2);
    apex_json.write(p_name => 'highlights', p_cursor => l_ref_cursor);  
    l_highlights := apex_json.get_clob_output;
    
    apex_debug.message('AOP: Break');
    open l_ref_cursor for 
    select break_enabled_on, sum_columns_on_break, avg_columns_on_break, max_columns_on_break, 
           min_columns_on_break, median_columns_on_break, count_columns_on_break, count_distnt_col_on_break
      from APEX_APPLICATION_PAGE_IR_RPT
     where application_id = c_application_id
       and page_id        = c_page_id
       and region_id      = l_region_id
       and report_id      = l_report_id;
    apex_json.initialize_clob_output(dbms_lob.call, true, 2);
    apex_json.write(p_name => 'break', p_cursor => l_ref_cursor);  
    l_break := apex_json.get_clob_output;

    apex_debug.message('AOP: Computations');
    open l_ref_cursor for 
    select COMPUTATION_COLUMN_ALIAS, COMPUTATION_COLUMN_IDENTIFIER, COMPUTATION_EXPRESSION, COMPUTATION_FORMAT_MASK, COMPUTATION_COLUMN_TYPE, COMPUTATION_REPORT_LABEL
      from APEX_APPLICATION_PAGE_IR_COMP
     where application_id = c_application_id
       and page_id        = c_page_id
       and report_id      = l_report_id;
    apex_json.initialize_clob_output(dbms_lob.call, true, 2);
    apex_json.write(p_name => 'computations', p_cursor => l_ref_cursor);  
    l_computations := apex_json.get_clob_output;
    
    apex_debug.message('AOP: Output'); 
    l_output := '{';
    l_output := l_output || l_settings;
    l_tmp := ', ';
    l_output := l_output || l_tmp;
    l_output := l_output || l_columns;
    l_tmp := ', ';
    l_output := l_output || l_tmp;
    l_output := l_output || l_highlights;
    l_tmp := ', ';
    l_output := l_output || l_tmp;
    l_output := l_output || l_break;
    l_tmp := ', ';
    l_output := l_output || l_tmp;
    l_output := l_output || l_computations;
    l_tmp := '} ';
    l_output := l_output || l_tmp;

    apex_debug.message('AOP: End Interactive Report settings');
    return l_output;
  end get_ireport_settings;  
  
  
  --
  function get_json(
    p_data_type in varchar2,
    p_data_source_sql in varchar2,
    p_data_source_plsql in varchar2,
    p_data_source_url in varchar2,
    p_json_type in varchar2)
    return clob
  as
    l_sql               varchar2(4000);
    l_return            clob;
    l_template          clob;
    l_template_type     varchar2(4);
    l_data              clob;
    l_data_type_list    apex_application_global.vc_arr2;
    l_column_value_list apex_plugin_util.t_column_value_list2;
    l_binds             dbms_sql.varchar2_table;
    l_ireport           apex_ir.t_report;
    l_region_id         number;
    l_source_type       varchar2(20);
    l_region_source     clob;
    l_cursor            binary_integer;
    l_ref_cursor        sys_refcursor;
    l_exec              binary_integer;  

  begin    
    apex_debug.message('AOP: p_data_type: %s', p_data_type);

    if p_data_type = c_source_type_apex then
      begin
          select substr(filename, -4) as template_type, apex_web_service.blob2clobbase64(blob_content) as template
            into l_template_type, l_template
            from apex_application_files
           where filename = p_data_source_url
             and flow_id  =  c_application_id;
      exception
        when no_data_found
        then
          raise_application_error(-20001, 'Template ('|| p_data_source_url ||') not found in Shared Components > Application Files');
      end;  
      
      l_template := replace(l_template, chr(13) || chr(10), null);
      l_template := replace(l_template, '"', '\u0022');
      l_return :=
            '{"file":"' || l_template || '",' ||
            ' "template_type":"' || l_template_type || '"}';
            
    elsif p_data_type = c_source_type_workspace then
      begin
          select substr(file_name, -4) as template_type, apex_web_service.blob2clobbase64(file_content) as template
            into l_template_type, l_template
            from apex_workspace_static_files
           where file_name = p_data_source_url
             and rownum < 2;
      exception
        when no_data_found
        then
          raise_application_error(-20001, 'Template ('|| p_data_source_url ||') not found in Shared Components > Workspace Files');
      end;          
      
      l_template := replace(l_template, chr(13) || chr(10), null);
      l_template := replace(l_template, '"', '\u0022');
      l_return :=
            '{"file":"' || l_template || '",' ||
            ' "template_type":"' || l_template_type || '"}';

    elsif p_data_type = c_source_type_url then
      l_return := apex_web_service.make_rest_request(
        p_url => p_data_source_url,
        p_http_method => 'GET');

      -- Remove ORDS wrappers
      if regexp_count(l_return,'^{"items":\[') = 1 then
        apex_debug.message('AOP: ORDS item detected, removing wrappers');
        l_return := replace(l_return, '{"items":');
        -- Remove leading items
        l_return := regexp_replace(l_return,'^{"items":\', null);
        -- Remove trailing items
        l_return := regexp_replace(l_return,'}$', null);
      end if;

    elsif p_data_type = c_source_type_sql then

      apex_debug.message('AOP: p_json_type: %s', p_json_type);

      if p_json_type = 'template' then
          -- Setup columns
          l_data_type_list(1) := apex_plugin_util.c_data_type_varchar2;
          l_data_type_list(2) := apex_plugin_util.c_data_type_blob;

          l_column_value_list := apex_plugin_util.get_data2 (
            p_sql_statement => p_data_source_sql,
             p_min_columns => 2,
             p_max_columns => 2,
             p_data_type_list => l_data_type_list,
             p_component_name => null,
             p_search_type => apex_plugin_util.c_search_exact_case,
             p_search_column_no => 1,
             p_search_string => '%',
             p_first_row => 1,
             p_max_rows => 1);

          assert(l_column_value_list(1).value_list.count = 1, 'Got: ' || l_column_value_list(1).value_list.count || ' rows. Expecting 1 row');

          -- APEX get_data2 puts in carriage returns on clobs. Need to remove them for JSON
          l_template := apex_web_service.blob2clobbase64(l_column_value_list(2).value_list(1).blob_value);
          l_template := replace(l_template, chr(13) || chr(10), null);
          l_template := replace(l_template, '"', '\u0022');

          l_return :=
            '{"file":"' || l_template || '",' ||
            ' "template_type":"' || replace(l_column_value_list(1).value_list(1).varchar2_value,'"', '\u0022') || '"}';

      elsif p_json_type = 'data' then
          l_sql := p_data_source_sql;
          apex_debug.message('AOP: %s', l_sql);
          l_cursor := dbms_sql.open_cursor; 
          DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
          apex_debug.message('AOP: Get binds of report');
          l_binds := wwv_flow_utilities.get_binds(l_sql) ;
          apex_debug.message('AOP: Binds of report: %s', to_char(l_binds.count));
          for i in 1..l_binds.count
          loop
            apex_debug.message('AOP: Bind %s: %s', to_char(i), l_binds(i));
            DBMS_SQL.BIND_VARIABLE(l_cursor, l_binds(i), v(replace(l_binds(i), ':', '')));
          end loop;          

          l_exec := DBMS_SQL.EXECUTE(l_cursor); 
          l_ref_cursor := dbms_sql.to_refcursor(l_cursor);
    
          -- make sure APEX 5.01 or higher is installed, as the patchset will fix issues in apex_json
          apex_json.initialize_clob_output(dbms_lob.call, true, 2);
          apex_json.write(l_ref_cursor);  
          l_return := apex_json.get_clob_output;
          
      else       
         assert(false, 'Invalid json_type: ' || p_json_type);
      end if;

    elsif p_data_type = c_source_type_plsql then

      l_return := apex_plugin_util.get_plsql_func_result_clob(p_plsql_function => p_data_source_plsql);

      -- Cleanup APEX clobs
      l_return := replace(l_return, chr(13) || chr(10), null);

    elsif p_data_type = c_source_type_filename then

      l_return :=
            '{"filename":"' || p_data_source_url || '",' ||
            ' "template_type": "' || substr(p_data_source_url, -4) || '"}';

    elsif p_data_type = c_source_type_rpt then

      apex_debug.message('AOP: Get the region_id based on the static id of the region');
      begin                             
        select r.region_id, r.source_type, r.region_source
          into l_region_id, l_source_type, l_region_source
          from APEX_APPLICATION_PAGE_REGIONS r
         where r.source_type in ('Report', 'Interactive Report')
           and r.page_id        = c_page_id
           and r.application_id = c_application_id
           and r.static_id      = l_data_source_static_id;
         apex_debug.message('AOP: Region id: %s', to_char(l_region_id));
         apex_debug.message('AOP: Source Type: %s', l_source_type);
         apex_debug.message('AOP: Region Source: %s', l_region_source);
      exception
        when no_data_found
        then
          assert(false, 'Report region with static id not found: ' || l_data_source_static_id);
      end;

      if l_source_type = 'Report' then
        -- we have to replace the #OWNER# tag as APEX might put that as prefix
        if instr(l_special, 'REPORT_AS_LABELS') > 0 then
          l_sql := 'select ''file1'' as "filename", cursor (select ''true'' as "aop_labelprinting", cursor(' || replace(l_region_source,'"#'||'OWNER'||'#".','') || ') as "row" from dual) as "data" from dual';  
        else
          l_sql := 'select ''file1'' as "filename", cursor (select cursor(' || replace(l_region_source,'"#'||'OWNER'||'#".','') || ') as "row" from dual) as "data" from dual';  
        end if;

        apex_debug.message('AOP: %s', l_sql);
        l_cursor := dbms_sql.open_cursor; 
        DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
        apex_debug.message('AOP: Get binds of report');
        l_binds := wwv_flow_utilities.get_binds(l_sql) ;
        apex_debug.message('AOP: Binds of report: %s', to_char(l_binds.count));
        for i in 1..l_binds.count
        loop
          apex_debug.message('AOP: Bind %s: %s', to_char(i), l_binds(i));
          DBMS_SQL.BIND_VARIABLE(l_cursor, l_binds(i), v(replace(l_binds(i), ':', '')));
        end loop;
  
        l_exec := DBMS_SQL.EXECUTE(l_cursor); 
        l_ref_cursor := dbms_sql.to_refcursor(l_cursor);
  
        apex_json.initialize_clob_output(dbms_lob.call, true, 2);
        apex_json.write(l_ref_cursor);  
        l_return := apex_json.get_clob_output;

      elsif l_source_type = 'Interactive Report' then  
        l_ireport := APEX_IR.GET_REPORT (
                       p_page_id   => c_page_id,
                       p_region_id => l_region_id,
                       p_report_id => null);
        if instr(l_special, 'REPORT_AS_LABELS') > 0
        then
          l_sql := 'select ''file1'' as "filename", cursor (select ''true'' as "aop_labelprinting", cursor(' || replace(l_ireport.sql_query,'"#'||'OWNER'||'#".','') || ') as "labels" from dual) as "data" from dual';
        else
          l_sql := 'select ''file1'' as "filename", ''***AOP_IREPORT_JSON***'' as "aopireportoptions", cursor (select cursor(' || replace(l_ireport.sql_query,'"#'||'OWNER'||'#".','') || ') as "aopireportdata" from dual) as "data" from dual';  
        end if;
        apex_debug.message('AOP: %s', l_sql);
        l_cursor := dbms_sql.open_cursor; 
        DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
        apex_debug.message('AOP: Binds of report: %s', to_char(l_ireport.binds.count));
        for i in 1..l_ireport.binds.count
        loop
          apex_debug.message('AOP: Bind %s: %s', to_char(i), l_ireport.binds(i).value);
          DBMS_SQL.BIND_VARIABLE(l_cursor, l_ireport.binds(i).name, l_ireport.binds(i).value);
        end loop;
          
        l_exec := DBMS_SQL.EXECUTE(l_cursor); 
        l_ref_cursor := dbms_sql.to_refcursor(l_cursor);
  
        apex_json.initialize_clob_output(dbms_lob.call, true, 2);
        apex_json.write(l_ref_cursor);  
        l_return := apex_json.get_clob_output;
        l_return := replace_with_clob(l_return, '"***AOP_IREPORT_JSON***"', get_ireport_settings);

      else
        assert(false, 'Unknown source_type for report. Got: ' || l_source_type);
      end if;  
                                   
    else
      assert(false, 'Invalid data_type: ' || p_data_type);
    end if; -- p_data_type

    l_return := trim(l_return);
    return l_return;
   
  exception
  when others then
    -- Ensure that the cursor is closed.
    if DBMS_SQL.IS_OPEN(l_cursor) 
    then   
      DBMS_SQL.CLOSE_CURSOR(l_cursor); 
    end if; 
    raise;
  end get_json;


  -- Removes leading { and trailing } on JSON
  procedure unwrap_json(p_json in out clob)
  as
  begin
    -- Remove the {} wrappers
    p_json := trim(leading '{' from p_json);
    p_json := trim(trailing '}' from p_json);
  end unwrap_json;

begin
  apex_debug.message('AOP: Start of APEX Office Print');

  -- debug
  if apex_application.g_debug then
    apex_plugin_util.debug_process (
      p_plugin => p_plugin,
      p_process => p_process);
  end if;

  apex_debug.message('AOP: Start Validation');

  assert(l_template_type is null or l_template_type in (c_source_type_apex,c_source_type_workspace,c_source_type_sql,c_source_type_plsql,c_source_type_filename), 'Invalid template type: ' || l_template_type);
  assert(l_data_type in (c_source_type_url,c_source_type_sql,c_source_type_plsql,c_source_type_rpt), 'Invalid data type: ' || l_data_type);
  assert(l_data_source_sql is not null or l_data_source_plsql is not null or l_data_source_url is not null or 1=1, 'Missing data source');

  if l_output_type = 'apex_item' then
    assert(l_output_type_item_name is not null, 'Output type item name required');

    l_output_type := v(l_output_type_item_name);
  end if;
  assert(l_output_type in ('docx','xlsx','pptx','pdf','rtf','html'), 'Invalid output type: ' || l_output_type);

  if l_output_type = 'docx'
  then
    l_output_mime_type := c_mime_type_docx; 
  elsif l_output_type = 'xlsx'
  then
    l_output_mime_type := c_mime_type_xlsx; 
  elsif l_output_type = 'pptx'
  then
    l_output_mime_type := c_mime_type_pptx; 
  elsif l_output_type = 'pdf'
  then
    l_output_mime_type := c_mime_type_pdf; 
  else
    l_output_mime_type := '';
  end if;

  apex_debug.message('AOP: End Validation');

  -- Create JSON to send to node.js
  l_aop_json := '
  {
      "version": "***AOP_VERSION***",
      "api_key": "***AOP_API_KEY***",
      "aop_remote_debug": "***AOP_REMOTE_DEBUG***",
      "template": {
        ***AOP_TEMPLATE_JSON***
      },
      "output": {
        "output_encoding": "base64",
        "output_type": "***AOP_OUTPUT_TYPE***",
        "output_converter": "***AOP_OUTPUT_CONVERTER***"
      },
      "files":  
        ***AOP_DATA_JSON***
  }';

  -- Handle Filename
  if l_output_filename is null then
    l_output_filename := 'output';
  end if; -- l_output_filename is null

  -- Make sure it's extension is the same as the output type. If not, change it.
  l_output_file_ext := trim(leading '.' from lower(regexp_substr(l_output_filename, '[.]+[[:print:]]*$')));
  apex_debug.message('AOP: Filename Ext: %s', l_output_file_ext);

  if (l_output_file_ext <> 'zip' and l_output_file_ext != l_output_type) or l_output_file_ext is null then
    l_output_filename := l_output_filename || '.' || l_output_type;
  end if;
  apex_debug.message('AOP: Filename: %s', l_output_filename);
  
  apex_debug.message('AOP: Get JSON');
  l_data_json := get_json(p_data_type         => l_data_type, 
                          p_data_source_sql   => l_data_source_sql, 
                          p_data_source_plsql => l_data_source_plsql,
                          p_data_source_url   => l_data_source_url,
                          p_json_type         => 'data');
  unwrap_json(p_json => l_data_json);

  -- Special
  if instr(l_special, 'NUMBER_TO_STRING') > 0
  then
    apex_debug.message('AOP: Convert numbers to character string, so formatting is kept.');
    l_data_json := regexp_replace(l_data_json,'\!FMT!\', null);
    -- Convert nummeric values with decimals. Eg. 12.3
    l_data_json := REGEXP_REPLACE(l_data_json, '(\:)([[:digit:]]*\.[[:digit:]]*)', '\1"\2"');
    -- Convert remaning nummeric values to character strings Eg. 001 => "001"
    l_data_json := REGEXP_REPLACE(l_data_json, '(\:)([[:digit:]]*)(\,)', '\1"\2"\3');
  end if;

  if l_template_type is not null then
    apex_debug.message('AOP: Get Template');
    l_template_json := get_json(p_data_type         => l_template_type, 
                                p_data_source_sql   => l_template_source_sql, 
                                p_data_source_plsql => l_template_source_plsql, 
                                p_data_source_url   => l_template_source_file, 
                                p_json_type         => 'template');
    unwrap_json(p_json => l_template_json);
  else
    apex_debug.message('AOP: Template is not defined, using standard AOP Sample Template');
    l_template_json := '"file": "", "template_type": "docx"';
  end if;

  -- Need to use custom replace since the replace string is a clob
  l_aop_json := replace_with_clob(l_aop_json, '***AOP_TEMPLATE_JSON***', l_template_json);
  l_aop_json := replace_with_clob(l_aop_json, '***AOP_DATA_JSON***', l_data_json);
  l_aop_json := replace(l_aop_json, '***AOP_OUTPUT_TYPE***', l_output_type);
  l_aop_json := replace(l_aop_json, '***AOP_OUTPUT_CONVERTER***', l_output_converter);
  l_aop_json := replace(l_aop_json, '***AOP_API_KEY***', l_api_key);
  l_aop_json := replace(l_aop_json, '***AOP_VERSION***', l_version);
  l_aop_json := replace(l_aop_json, '***AOP_REMOTE_DEBUG***', nvl(l_aop_remote_debug,'No'));
  l_aop_json := replace(l_aop_json, '\\n', '\n');

  -- WHEN DEBUGGING THE JSON - INSTALL LOGGER AND UNCOMMENT NEXT ROW
  -- logger.log('l_aop_json', null, l_aop_json);

  apex_debug.message('AOP: Create collection with JSON that will be sent to AOP');
  if apex_application.g_debug
  then
    apex_collection.create_or_truncate_collection('AOP_DEBUG'); 
    apex_collection.add_member(
        p_collection_name => 'AOP_DEBUG',
        p_c001            => 'l_aop_json',
        p_d001            => sysdate,
        p_clob001         => l_aop_json);
  end if;
  apex_debug.message('AOP: Use following select statement to view the JSON');
  apex_debug.message('AOP: select clob001 from apex_collections where collection_name = ''AOP_DEBUG''');

  -- Call AOP node.js
  apex_web_service.g_request_headers(apex_web_service.g_request_headers.count + 1).name := 'Content-Type';
  apex_web_service.g_request_headers(apex_web_service.g_request_headers.count).value := 'application/json';

  -- For 1st party authentication
  -- http://www.oracle.com/technetwork/developer-tools/rest-data-services/documentation/listener-dev-guide-1979546.html#modify_the_application_to_use_first_party_authentication
  apex_web_service.g_request_headers(apex_web_service.g_request_headers.count + 1).name := 'Apex-Session';
  apex_web_service.g_request_headers(apex_web_service.g_request_headers.count).value := apex_application.g_flow_id || ', ' || apex_application.g_instance;

  -- APEX 4.2 we can only use apex_web_service.make_rest_request returning clob
  -- APEX 5.0 allows to use apex_web_service.make_rest_request_b so automatically we get back a blob and we don't need to do the conversion
  -- we would need to set the type to raw
  l_clob := apex_web_service.make_rest_request(
    p_url => l_aop_url,
    p_http_method => 'POST',
    p_body => l_aop_json);

  apex_debug.message('AOP: returned HTTP status code: %s', apex_web_service.g_status_code);
  assert(apex_web_service.g_status_code = 200, 
         'Issue returned by AOP Service. Please verify the logs on the server. ' || CHR(10)
         || 'Returned HTTP code: ' || apex_web_service.g_status_code || '.' || CHR(10)
         || 'Returned message: ' || substr(l_clob,1,500)
        );
  -- HTTP Status Codes:
  --   200 is normal
  --   503 Service Temporarily Unavailable, the AOP server is probably not running
  apex_debug.message('AOP: returned number of bytes: %s', dbms_lob.getlength(l_clob));

  l_blob := apex_web_service.clobbase642blob (p_clob => l_clob);

  apex_debug.message('AOP: Check how to output');

  if l_output_to is not null
  then
    apex_debug.message('AOP: Run the procedure');
    begin
      execute immediate 'begin ' || l_procedure  || '(p_output_blob => :p_output_blob, p_output_filename => :p_output_filename, p_output_mime_type => :p_output_mime_type); end;' using l_blob, l_output_filename, l_output_mime_type;
    exception
      when others
      then
        raise_application_error(-20001, 'Issue running the procedure. Got error: ' || SQLERRM);
    end;
  end if;

  if l_output_to is null or l_output_to = 'PROCEDURE_BROWSER'
  then
    apex_debug.message('AOP: Downloading file');
    sys.htp.flush;
    sys.htp.init;
    owa_util.mime_header('application/octet-stream',false);
    sys.htp.p('Content-length:'||dbms_lob.getlength(l_blob));
    sys.htp.p('Content-Disposition:attachment;filename="'||l_output_filename||'"');
    owa_util.http_header_close;
    wpg_docload.download_file(l_blob);
    apex_application.stop_apex_engine;
  end if;

  apex_debug.message('AOP: End of APEX Office Print');

  l_return.success_message := p_process.success_message;
  return l_return;
end f_process_aop;


end AOP_API_PKG;
/


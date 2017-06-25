set define off verify off feedback off

create or replace package aop_sample3_pkg as

/* Copyright 2017 - APEX RnD
*/

-- AOP Version
c_aop_version  constant varchar2(5)   := '3.0';

--
-- Store output in AOP Output table
--
procedure aop_store_document(
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2);


--
-- Send email from AOP
--
procedure send_email_prc(
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2);


--
-- AOP_PLSQL_PKG example
--
procedure call_aop_plsql3_pkg;


--
-- AOP_API3_PKG example
--
procedure call_aop_api3_pkg;

procedure schedule_aop_api3_pkg;


--
-- REST example (call this procedure from ORDS)
--
function get_file(p_customer_id   in number,
                  p_output_type   in varchar2)
return blob;


--
-- write to filesystem
--
procedure write_filesystem;


--
-- view the tags that are used in a template (docx)
--
procedure get_tags_in_template;


--
-- all possible options for Excel cell styling
--
function test_excel_styles
return clob;


end aop_sample3_pkg;
/
create or replace package body aop_sample3_pkg as


--
-- Store output in AOP Output table
--
procedure aop_store_document(
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2)
as
begin
  insert into aop_output (output_blob, filename, mime_type, last_update_date)
  values (p_output_blob, p_output_filename, p_output_mime_type, sysdate);

  commit;
end aop_store_document;


--
-- Send email from AOP
--
procedure send_email_prc(
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2)
as
  l_id number;
begin
  l_id := apex_mail.send(
            p_to => 'support@apexofficeprint.com',
            p_from => 'support@apexofficeprint.com',
            p_subj => 'Mail from APEX with attachment',
            p_body => 'Please review the attachment.',
            p_body_html => '<b>Please</b> review the attachment.') ;
  apex_mail.add_attachment(
      p_mail_id    => l_id,
      p_attachment => p_output_blob,
      p_filename   => p_output_filename,
      p_mime_type  => p_output_mime_type) ;
  commit;
end send_email_prc;


--
-- AOP_PLSQL3_PKG example
--
procedure call_aop_plsql3_pkg
as
  c_mime_type_docx  varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  c_mime_type_xlsx  varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  c_mime_type_pptx  varchar2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
  c_mime_type_pdf   varchar2(100) := 'application/pdf';
  l_template        blob;
  l_output_file     blob;
begin
  select template_blob
    into l_template
    from aop_template
   where id = 1;

  l_output_file := aop_plsql3_pkg.make_aop_request(
                     p_json        => '[{ "filename": "file1", "data": [{ "cust_first_name": "APEX Office Print" }] }]',
                     p_template    => l_template,
                     p_output_type => 'docx',
                     p_aop_remote_debug => 'Yes');

  insert into aop_output (output_blob, filename, mime_type, last_update_date)
  values (l_output_file, 'output.docx', c_mime_type_docx, sysdate);
end call_aop_plsql3_pkg;


--
-- AOP_API3_PKG example
--
procedure call_aop_api3_pkg
as
  l_binds           wwv_flow_plugin_util.t_bind_list;
  l_return          blob;
  l_output_filename varchar2(100) := 'output';

begin
  -- define bind variables
  l_binds(1).name := 'p_id';
  l_binds(1).value := '1';

  for i in 1..l_binds.count
  loop
    dbms_output.put_line('AOP: Bind ' || to_char(i) || ': ' || l_binds(i).name || ': ' || l_binds(i).value);
  end loop;

  l_return := aop_api3_pkg.plsql_call_to_aop (
                p_data_type       => 'SQL',
                p_data_source     => q'[
                  select
                    'file1' as "filename",
                    cursor(
                      select
                        c.cust_first_name as "cust_first_name",
                        c.cust_last_name as "cust_last_name",
                        c.cust_city as "cust_city",
                        cursor(select o.order_total as "order_total",
                                      'Order ' || rownum as "order_name",
                                  cursor(select p.product_name as "product_name",
                                                i.quantity as "quantity",
                                                i.unit_price as "unit_price", APEX_WEB_SERVICE.BLOB2CLOBBASE64(p.product_image) as "image"
                                           from demo_order_items i, demo_product_info p
                                          where o.order_id = i.order_id
                                            and i.product_id = p.product_id
                                        ) "product"
                                 from demo_orders o
                                where c.customer_id = o.customer_id
                              ) "orders"
                      from demo_customers c
                      where customer_id = :p_id
                    ) as "data"
                  from dual
                ]',
                p_template_type   => 'SQL',
                p_template_source => q'[
                   select template_type, template_blob
                    from aop_template
                   where id = 1
                ]',
                p_output_type     => 'docx',
                p_output_filename => l_output_filename,
                p_binds           => l_binds,
                p_aop_url         => 'http://www.apexofficeprint.com/api/',
                p_api_key         => '1C511A58ECC73874E0530100007FD01A',
                p_app_id          => 232);

  insert into aop_output (output_blob, filename, mime_type, last_update_date)
  values (l_return, l_output_filename, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', sysdate);
end call_aop_api3_pkg;


-- procedure which can be scheduled with dbms_scheduler
-- to automatically receive a PDF with a specific Interactive Report
-- debugging is set to Yes
-- set dbms_output or htp output on
-- view the debug output with: select * from apex_debug_messages;
-- view the JSON with: select clob001 from apex_collections where collection_name = 'AOP_DEBUG';
procedure schedule_aop_api3_pkg
as
  l_binds           wwv_flow_plugin_util.t_bind_list;
  l_return          blob;
  l_output_filename varchar2(100) := 'output';
  l_id              number;
begin
  aop_api3_pkg.create_apex_session(
    p_app_id       => 232,
    --p_user_name    => 'DIMI',
    p_page_id      => 5,
    p_enable_debug => 'Yes');

  apex_util.set_session_state('P5_CUSTOMER_ID','2');

  l_return := aop_api3_pkg.plsql_call_to_aop (
                p_data_type       => aop_api3_pkg.c_source_type_rpt,
                p_data_source     => 'ir1|PRIMARY',
                p_template_type   => aop_api3_pkg.c_source_type_apex,
                p_template_source => 'aop_interactive.docx',
                p_output_type     => 'pdf',
                p_output_filename => l_output_filename,
                p_binds           => l_binds,
                p_aop_url         => 'http://www.apexofficeprint.com/api/',
                p_api_key         => '1C511A58ECC73874E0530100007FD01A',
                p_app_id          => 232,
                p_page_id         => 5);

  l_id := apex_mail.send(
            p_to => 'support@apexofficeprint.com',
            p_from => 'support@apexofficeprint.com',
            p_subj => 'Mail from APEX with attachment PLSQL 2',
            p_body => 'Please review the attachment.',
            p_body_html => '<b>Please</b> review the attachment.') ;
  apex_mail.add_attachment(
      p_mail_id    => l_id,
      p_attachment => l_return,
      p_filename   => l_output_filename,
      p_mime_type  => aop_api3_pkg.c_mime_type_pdf) ;
  apex_mail.push_queue;
end schedule_aop_api3_pkg;


--
-- REST example (call this procedure from ORDS)
--
function get_file(p_customer_id   in number,
                  p_output_type   in varchar2)
return blob
as PRAGMA AUTONOMOUS_TRANSACTION;
  l_binds           wwv_flow_plugin_util.t_bind_list;
  l_template        varchar2(100);
  l_output_filename varchar2(100);
  l_return          blob;
begin
  if p_output_type = 'xlsx'
  then
    l_template := 'aop_IR_template.xlsx';
  else
    l_template := 'aop_interactive.docx';
  end if;
  l_return := aop_api3_pkg.plsql_call_to_aop (
                p_data_type       => aop_api3_pkg.c_source_type_rpt,
                p_data_source     => 'ir1|PRIMARY',
                p_template_type   => aop_api3_pkg.c_source_type_apex,
                p_template_source => l_template,
                p_output_type     => p_output_type,
                p_output_filename => l_output_filename,
                p_binds           => l_binds,
                p_aop_url         => 'http://www.apexofficeprint.com/api/',
                p_api_key         => '1C511A58ECC73874E0530100007FD01A',
                p_app_id          => 232,
                p_page_id         => 5,
                p_user_name       => 'ADMIN',
                p_init_code       => q'[apex_util.set_session_state('P5_CUSTOMER_ID',']'|| to_char(p_customer_id) || q'[');]',
                p_aop_remote_debug=> 'No');
  -- we have to do a commit in order to call this function from a SQL statement
  commit;
  return l_return;
end get_file;


--
-- write to filesystem
-- MAKE SURE YOU CREATE A DIRECTORY FIRST CALLED AOP_OUTPUT
-- CREATE DIRECTORY AOP_OUTPUT AS '/tmp';
--
procedure write_filesystem
as
  -- aop
  l_binds           wwv_flow_plugin_util.t_bind_list;
  l_output_filename varchar2(100) := 'output';
  -- file
  l_file      UTL_FILE.FILE_TYPE;
  l_buffer    RAW(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_blob      BLOB;
  l_blob_len  INTEGER;
begin
  -- loop over records
  l_binds(1).name := 'p_id';
  for r in (select 1 as id from dual union all select 2 as id from dual)
  loop
    l_pos := 1;
    l_binds(1).value := r.id;
    -- call AOP
    l_blob := aop_api3_pkg.plsql_call_to_aop (
                p_data_type       => 'SQL',
                p_data_source     => q'[
                  select
                    'file1' as "filename",
                    cursor(
                      select
                        c.cust_first_name as "cust_first_name",
                        c.cust_last_name as "cust_last_name",
                        c.cust_city as "cust_city",
                        cursor(select o.order_total as "order_total",
                                      'Order ' || rownum as "order_name",
                                  cursor(select p.product_name as "product_name",
                                                i.quantity as "quantity",
                                                i.unit_price as "unit_price", APEX_WEB_SERVICE.BLOB2CLOBBASE64(p.product_image) as "image"
                                           from demo_order_items i, demo_product_info p
                                          where o.order_id = i.order_id
                                            and i.product_id = p.product_id
                                        ) "product"
                                 from demo_orders o
                                where c.customer_id = o.customer_id
                              ) "orders"
                      from demo_customers c
                      where customer_id = :p_id
                    ) as "data"
                  from dual
                ]',
                p_template_type   => 'APEX',
                p_template_source => 'aop_template_d01.docx',
                p_output_type     => 'pdf',
                p_output_filename => l_output_filename,
                p_binds           => l_binds,
                p_aop_url         => 'http://www.apexofficeprint.com/api/',
                p_api_key         => '1C511A58ECC73874E0530100007FD01A',
                p_app_id          => 232);

      l_output_filename := to_char(r.id)||'_'||l_output_filename;

      -- write to file system
      BEGIN
        l_blob_len := DBMS_LOB.getlength(l_blob);

        -- Open the destination file.
        l_file := UTL_FILE.fopen('AOP_OUTPUT', l_output_filename,'w', 32767);

        -- Read chunks of the BLOB and write them to the file
        -- until complete.
        WHILE l_pos < l_blob_len LOOP
          DBMS_LOB.read(l_blob, l_amount, l_pos, l_buffer);
          UTL_FILE.put_raw(l_file, l_buffer, TRUE);
          l_pos := l_pos + l_amount;
        END LOOP;

        -- Close the file.
        UTL_FILE.fclose(l_file);

      EXCEPTION
        WHEN OTHERS THEN
          -- Close the file if something goes wrong.
          IF UTL_FILE.is_open(l_file) THEN
            UTL_FILE.fclose(l_file);
          END IF;
          RAISE;
      END;
  end loop;
end write_filesystem;



--
-- view the tags that are used in a template (docx)
--
procedure get_tags_in_template
as
  l_output varchar2(100);
  l_blob   blob;
  l_clob clob;
begin
  l_blob := aop_api3_pkg.plsql_call_to_aop(
              p_data_source           => q'[
                  select
                    'file1' as "filename",
                    cursor(
                      select sysdate from dual
                    ) as "data"
                  from dual
                ]',
              p_template_source       => 'aop_template_d01.docx',
              p_output_type           => 'count_tags',
              p_output_filename       => l_output,
              p_aop_url               => 'http://www.apexofficeprint.com/api/',
              p_api_key               => '1C511A58ECC73874E0530100007FD01A',
              p_app_id                => 232
            );

  l_clob := aop_api3_pkg.blob2clob(l_blob);
  sys.htp.p(l_clob);
  -- returns: {"{cust_last_name}":1,"{cust_first_name}":2,"{cust_city}":1,"{#orders}":2,"{#product}":2,"{product_name}":2,"{/product}":2,"{order_total}":2,"{/orders}":2,"{%image}":1,"{unit_price}":1,"{#quantity<3}":1,"{quantity}":2,"{/quantity<3}":2,"{^quantity<3}":1,"{ unit_price*quantity }":1}

end get_tags_in_template;


--
-- all possible options for Excel cell styling
--
function test_excel_styles
return clob
as
begin
   return '[{"data": [{
            "tag1": "Lorem ipsum",
            "info1":"in bold and arial",
            "tag1_font_bold":"y",
            "tag1_font_name":"Arial",
            "tag2": "Lorem ipsum",
            "info2":"arial font",
            "tag2_font_name":"Arial",
            "tag3": "Lorem ipsum",
            "info3":"font 20",
            "tag3_font_size":"20",
            "tag4": "Lorem ipsum",
            "info4":"font color #1782A6",
            "tag4_font_color":"#1782A6",
            "tag5": "Lorem ipsum",
            "info5":"underline single",
            "tag5_font_underline":"single",
            "tag6": "Lorem ipsum",
            "info6":"underline double double",
            "tag6_font_underline":"double",
            "tag7": "Lorem ipsum",
            "info7":"underline single financieel",
            "tag7_font_underline":"single-financial",
            "tag8": "Lorem ipsum",
            "info8":"underline dubbel financieel",
            "tag8_font_underline":"double-financial",
            "tag9": "Lorem ipsum",
            "info9":"left:thin, top:medium, right:thick, bottom:hair",
            "tag9_border_left":"thin",
            "tag9_border_top":"medium",
            "tag9_border_right":"thick",
            "tag9_border_bottom":"hair",
            "tag10": "Lorem ipsum",
            "info10":"left:dotted, top:medium-dashed, right:dash-dot, bottom:medium-dash-dot",
            "tag10_border_left":"dotted",
            "tag10_border_top":"medium-dashed",
            "tag10_border_right":"dash-dot",
            "tag10_border_bottom":"medium-dash-dot",
            "tag11": "Lorem ipsum",
            "info11":"left:dash-dot-dot, top:medium-dash-dot-dot, right:slash-dash-dot, bottom:double",
            "tag11_border_left":"dash-dot-dot",
            "tag11_border_top":"medium-dash-dot-dot",
            "tag11_border_right":"slash-dash-dot",
            "tag11_border_bottom":"double",
            "tag29": "Lorem ipsum",
            "info29":"diagonal border, up-wards",
            "tag29_border_diagonal":"dash-dot-dot",
            "tag29_border_diagonal_direction":"up-wards",
            "tag29_border_diagonal_color":"#FFFFFF",
            "tag30": "Lorem ipsum",
            "info30":"diagonal border, down-wards, colored",
            "tag30_border_diagonal":"dotted",
            "tag30_border_diagonal_direction":"down-wards",
            "tag30_border_diagonal_color":"4E8A0E",
            "tag31": "Lorem ipsum",
            "info31":"diagonal border, both",
            "tag31_border_diagonal":"slash-dash-dot",
            "tag31_border_diagonal_direction":"both",
            "tag31_border_diagonal_color":"ED4043",
            "tag12": "Lorem ipsum",
            "info12":"background green, font color blue",
            "tag12_cell_background":"1DF248",
            "tag12_font_color":"020EB8",
            "tag13": "Lorem ipsum",
            "info13":"pattern: dark-gray, pattern green, background yellow",
            "tag13_cell_pattern":"dark-gray",
            "tag13_cell_color":"FF17881D",
            "tag13_background_color":"FFE9E76B",
            "tag14": "Lorem ipsum",
            "info14":"pattern: medium-gray",
            "tag14_cell_pattern":"medium-gray",
            "tag15": "Lorem ipsum",
            "info15":"pattern: light-gray",
            "tag15_cell_pattern":"light-gray",
            "tag16": "Lorem ipsum",
            "info16":"pattern: gray-0625",
            "tag16_cell_pattern":"",
            "tag17": "Lorem ipsum",
            "info17":"pattern: dark-horizontal",
            "tag17_cell_pattern":"dark-horizontal",
            "tag18": "Lorem ipsum",
            "info18":"pattern: dark-vertical",
            "tag18_cell_pattern":"dark-vertical",
            "tag19": "Lorem ipsum",
            "info19":"pattern: dark-down",
            "tag19_cell_pattern":"dark-down",
            "tag20": "Lorem ipsum",
            "info20":"pattern: dark-up",
            "tag20_cell_pattern":"dark-up",
            "tag21": "Lorem ipsum",
            "info21":"pattern: dark-grid",
            "tag21_cell_pattern":"dark-grid",
            "tag22": "Lorem ipsum",
            "info22":"pattern: dark-trellis",
            "tag22_cell_pattern":"dark-trellis",
            "tag23": "Lorem ipsum",
            "info23":"pattern: light-horizontal",
            "tag23_cell_pattern":"light-horizontal",
            "tag24": "Lorem ipsum",
            "info24":"pattern: light-vertical",
            "tag24_cell_pattern":"light-vertical",
            "tag25": "Lorem ipsum",
            "info25":"pattern: light-down",
            "tag25_cell_pattern":"light-down",
            "tag26": "Lorem ipsum",
            "info26":"pattern: light-up",
            "tag26_cell_pattern":"light-up",
            "tag27": "Lorem ipsum",
            "info27":"pattern: light-grid",
            "tag27_cell_pattern":"light-grid",
            "tag28": "Lorem ipsum",
            "info28":"pattern: light-trellis",
            "tag28_cell_pattern":"light-trellis",
            "tag32": "Lorem ipsum",
            "info32":"horizonal alignment: center",
            "tag32_text_h_alignment":"center",
            "tag33": "Lorem ipsum",
            "info33":"horizonal alignment: right",
            "tag33_text_h_alignment":"right",
            "tag34": "Lorem ipsum",
            "info34":"horizonal alignment: fill",
            "tag34_text_h_alignment":"fill",
            "tag35": "Lorem ipsum",
            "info35":"horizonal alignment: justify",
            "tag35_text_h_alignment":"justify",
            "tag36": "Lorem ipsum",
            "info36":"horizonal alignment: center-continous",
            "tag36_text_h_alignment":"center-continous",
            "tag37": "Lorem ipsum",
            "info37":"horizonal alignment: distributed",
            "tag37_text_h_alignment":"distributed",
            "tag38": "Lorem ipsum",
            "info38":"horizonal alignment: left (was right)",
            "tag38_text_h_alignment":"left",
            "tag39": "Lorem ipsum",
            "info39":"vertical alignment: top",
            "tag39_text_v_alignment":"top",
            "tag40": "Lorem ipsum",
            "info40":"vertical alignment: center",
            "tag40_text_v_alignment":"center",
            "tag41": "Lorem ipsum",
            "info41":"vertical alignment: justify",
            "tag41_text_v_alignment":"justify",
            "tag42": "Lorem ipsum",
            "info42":"vertical alignment: distributed",
            "tag42_text_v_alignment":"distributed",
            "tag43": "Lorem ipsum",
            "info43":"vertical alignment: bottom (was top)",
            "tag43_text_v_alignment":"bottom",
            "tag44": "Lorem ipsum",
            "info44":"text rotation: 90",
            "tag44_text_rotation":"90",
            "tag45": "Lorem ipsum",
            "info45":"text rotation: 45",
            "tag45_text_rotation":"45",
            "tag46": "Lorem ipsum",
            "info46":"text rotation: 0",
            "tag46_text_rotation":"0",
            "tag47": "Lorem ipsum",
            "info47":"text rotation: -45",
            "tag47_text_rotation":"-45",
            "tag48": "Lorem ipsum",
            "info48":"text rotation: -180",
            "tag48_text_rotation":"-180",
            "tag49": "Lorem ipsum",
            "info49":"text rotation: aligned-vertically",
            "tag49_text_rotation":"aligned-vertically",
            "tag50": "Lorem ipsum",
            "info50":"text indent: (Number of spaces to indent = indent value * 3)",
            "tag50_text_indent":"2",
            "tag51": "Lorem ipsum Lorem ipsumLorem ipsum",
            "info51":"text wrap: y",
            "tag51_text_wrap":"y",
            "tag52": "Lorem ipsum Lorem ipsumLorem ipsum",
            "info52":"text shrink: y",
            "tag52_text_shrink":"y",
            "tag53": "Lorem ipsum",
            "info53":"cell locked: y",
            "tag53_cell_locked":"y",
            "tag54": "Lorem ipsum",
            "info54":"cell hidden: y",
            "tag54_cell_hidden":"y"
            }],
            "filename": "file1"}]';
end test_excel_styles;


end aop_sample3_pkg;
/
create or replace package aop_test3_pkg as

/* Copyright 2017 - APEX RnD
*/

-- AOP Version
c_aop_version            constant varchar2(5) := '3.0';


-- Run automated tests in table AOP_AUTOMATED_TEST; if p_id is null, all tests will be ran
procedure run_automated_tests(
  p_id     in aop_automated_test.id%type,
  p_app_id in number);


-- to convert base64 you can use http://base64converter.com

end aop_test3_pkg;
/
create or replace package body aop_test3_pkg as

-- Run automated tests in table AOP_AUTOMATED_TEST; if p_id is null, all tests will be ran
procedure run_automated_tests(
  p_id     in aop_automated_test.id%type,
  p_app_id in number)
as
  l_return blob;
  l_error  varchar2(4000);
  l_start  date;
  l_end    date;
  l_output_filename varchar2(150);
  --
  l_aop_url          varchar2(1000);
  l_api_key          varchar2(40);
  l_aop_remote_debug varchar2(10);
  l_output_converter varchar2(100);
begin
  -- note that session state needs to be set manually for the items (see pre-rendering page 8)

  -- read plugin settings
  select attribute_01 as aop_url, attribute_02 as api_key, attribute_03 as aop_remote_debug, attribute_04 as output_converter
    into l_aop_url, l_api_key, l_aop_remote_debug, l_output_converter
    from APEX_APPL_PLUGIN_SETTINGS
   where application_id = p_app_id
     and plugin_code = 'PLUGIN_BE.APEXRND.AOP';

  -- reset tests
  update aop_automated_test
    set received_bytes     = null,
        output_blob        = null,
        result             = null,
        processing_seconds = null,
        run_date           = sysdate
   where id = p_id
      or p_id is null;

  -- loop over reports
  for r in (select id, data_type, data_source,
                   template_type, template_source,
                   output_type, output_filename, output_to, output_type_item_name,
                   filename, special, procedure_, app_id, page_id
              from aop_automated_test
             where (id = p_id
                or p_id is null)
               and app_id = p_app_id
             order by seq_nr
           )
  loop
    begin
      l_start := sysdate;
      l_output_filename := nvl(r.output_filename,'output');
      l_return := aop_api3_pkg.plsql_call_to_aop (
                    p_data_type       => r.data_type,
                    p_data_source     => r.data_source,
                    p_template_type   => r.template_type,
                    p_template_source => r.template_source,
                    p_output_type     => r.output_type,
                    p_output_filename => l_output_filename,
                    p_output_type_item_name => r.output_type_item_name,
                    p_output_to             => r.output_to,
                    p_procedure             => r.procedure_,
                    --p_binds               in t_bind_table default c_binds,
                    p_special               => r.special,
                    p_aop_remote_debug      => l_aop_remote_debug,
                    p_output_converter      => l_output_converter,
                    p_aop_url               => l_aop_url,
                    p_api_key               => l_api_key,
                    p_app_id                => r.app_id,
                    p_page_id               => r.page_id
                  );
      l_end := sysdate;

      update aop_automated_test
         set received_bytes = dbms_lob.getlength(l_return),
             output_blob = l_return,
             result = 'ok',
             processing_seconds = round((l_end-l_start)*60*60*24,2)
       where id = r.id;

     exception
       when others
       then
         l_end := sysdate;
         l_error := substr(SQLERRM, 1, 4000);
         update aop_automated_test
            set received_bytes = null,
                output_blob = null,
                result = l_error,
                processing_seconds = round((l_end-l_start)*60*60*24,2)
          where id = r.id;
     end;
  end loop;
end run_automated_tests;


end aop_test3_pkg;
/

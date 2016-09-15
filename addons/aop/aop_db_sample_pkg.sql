create or replace package aop_sample2_pkg as

/* Copyright 2016 - APEX R&D
*/

-- AOP Version
c_aop_version  constant varchar2(5)   := '2.2';

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
procedure call_aop_plsql2_pkg;


--
-- AOP_API2_PKG example
--
procedure call_aop_api2_pkg;


end aop_sample2_pkg;
/
create or replace package body aop_sample2_pkg as


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
-- AOP_PLSQL2_PKG example
--
procedure call_aop_plsql2_pkg
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
   
  l_output_file := aop_plsql2_pkg.make_aop_request(
                     p_json        => '[{ "filename": "file1", "data": [{ "cust_first_name": "APEX Office Print" }] }]',
                     p_template    => l_template,
                     p_output_type => 'docx',
                     p_aop_remote_debug => 'Yes');
                     
  insert into aop_output (output_blob, filename, mime_type, last_update_date)
  values (l_output_file, 'output.docx', c_mime_type_docx, sysdate);
end call_aop_plsql2_pkg;  


--
-- AOP_API2_PKG example
--
procedure call_aop_api2_pkg
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
      
  l_return := aop_api2_pkg.plsql_call_to_aop (
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
end call_aop_api2_pkg;

end aop_sample2_pkg;
/
create or replace package aop_test2_pkg as

/* Copyright 2016 - APEX R&D
*/

-- AOP Version  
c_aop_version            constant varchar2(5) := '2.2';     


-- Run automated tests in table AOP_AUTOMATED_TEST; if p_id is null, all tests will be ran
procedure run_automated_tests(
  p_id     in aop_automated_test.id%type, 
  p_app_id in number);

end aop_test2_pkg;
/
create or replace package body aop_test2_pkg as

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
  l_aop_remote_debug varchar2(3);
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
      l_return := aop_api2_pkg.plsql_call_to_aop (
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

end aop_test2_pkg;
/

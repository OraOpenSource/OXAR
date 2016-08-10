CREATE TABLE "AOP_AUTOMATED_TEST" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(4000), 
	"DATA_TYPE" VARCHAR2(20), 
	"TEMPLATE_TYPE" VARCHAR2(20), 
	"OUTPUT_TYPE" VARCHAR2(20), 
	"OUTPUT_FILENAME" VARCHAR2(200), 
	"OUTPUT_BLOB" BLOB, 
	"EXPECTED_BYTES" NUMBER, 
	"RECEIVED_BYTES" NUMBER, 
	"RESULT" VARCHAR2(4000), 
	"PROCESSING_SECONDS" NUMBER, 
	"SEQ_NR" NUMBER, 
	"DATA_SOURCE" VARCHAR2(4000), 
	"TEMPLATE_SOURCE" VARCHAR2(4000), 
	"FILENAME" VARCHAR2(221) GENERATED ALWAYS AS ("OUTPUT_FILENAME"||'.'||"OUTPUT_TYPE") VIRTUAL , 
	 CONSTRAINT "AOP_AUTOMATED_TEST_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   ) ;


CREATE TABLE "AOP_OUTPUT" 
   (	"ID" NUMBER, 
	"OUTPUT_BLOB" BLOB, 
	"FILENAME" VARCHAR2(200), 
	"MIME_TYPE" VARCHAR2(200), 
	"LAST_UPDATE_DATE" DATE
   ) ;


CREATE TABLE "AOP_TEMPLATE" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"TEMPLATE_BLOB" BLOB, 
	"FILENAME" VARCHAR2(200), 
	"MIME_TYPE" VARCHAR2(200), 
	"LAST_UPDATE_DATE" DATE, 
	"TEMPLATE_TYPE" VARCHAR2(20), 
	"DESCRIPTION" VARCHAR2(4000), 
	 CONSTRAINT "AOP_TEMPLATE_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   ) ;


CREATE SEQUENCE  "AOP_TEMPLATE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 201;


CREATE OR REPLACE  TRIGGER "AOP_AUTOMATED_TEST_IUTRG" 
before insert on AOP_AUTOMATED_TEST
for each row 
begin  
   if :new.id is null 
   then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
   end if; 
end;
/


ALTER TRIGGER "AOP_AUTOMATED_TEST_IUTRG" ENABLE;


CREATE OR REPLACE  TRIGGER "AOP_OUTPUT_IUTRG" 
before insert on AOP_OUTPUT
for each row 
begin  
   if :new.id is null 
   then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
   end if; 
end;
/


ALTER TRIGGER "AOP_OUTPUT_IUTRG" ENABLE;

CREATE OR REPLACE  TRIGGER "AOP_TEMPLATE_IUTRG" 
  before insert ON aop_template FOR EACH ROW
BEGIN
  if :new.id is null 
  then 
  select aop_template_seq.nextval
    INTO :new.id
    FROM dual;
  end if;     
END;

/


ALTER TRIGGER "AOP_TEMPLATE_IUTRG" ENABLE;


create or replace procedure send_email_prc(
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2)
is
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
/

create or replace procedure aop_store_document(
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2)
is
begin                
  insert into aop_output (output_blob, filename, mime_type, last_update_date)
  values (p_output_blob, p_output_filename, p_output_mime_type, sysdate);
  
  commit;
end aop_store_document;
/
                                   

SET DEFINE OFF;

Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values ('1','aop_template_d01.docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',to_date('26/06/15','DD/MM/RR'),'docx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values ('2','aop_template_p01.pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation',to_date('26/06/15','DD/MM/RR'),'pptx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values ('3','aop_template_x01.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',to_date('02/08/15','DD/MM/RR'),'xlsx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values ('4','aop_template_p02.pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation',to_date('02/08/15','DD/MM/RR'),'pptx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values ('5','aop_template_p03.pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation',to_date('02/08/15','DD/MM/RR'),'pptx',null);

commit;

update aop_template t
   set t.template_blob = (select a.blob_content
                            from apex_application_files a 
                           where a.filename = t.filename
                             and rownum < 2
                         )
 where t.template_blob is null;
 
commit; 

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print One Page per Customer','SQL','APEX','docx','one_page_per_customer','239048','239048','ok','0','14','select
    ''file1'' as "filename",
    cursor
    (select 
       cursor(select
                  c.cust_first_name as "cust_first_name",
                  c.cust_last_name as "cust_last_name",
                  c.cust_city as "cust_city"
                from demo_customers c) as "customers"
       from dual) as "data"
from dual','aop_new_page_per_customer.docx');

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print Simple List','SQL','APEX','xlsx','simple_list','77279','77279','ok','1','20','select
    ''file1'' as "filename",
    cursor
    (select 
       cursor(select
                  c.cust_first_name as "cust_first_name",
                  c.cust_last_name as "cust_last_name",
                  c.cust_city as "cust_city"
                from demo_customers c) as "customers"
       from dual) as "data"
from dual','aop_simple_list.xlsx');

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print pptx','SQL','APEX','pptx','output','275919','275919','ok','2','4','select
  ''file1'' as "filename", 
  cursor(
    select
      c.cust_first_name as "cust_first_name",
      c.cust_last_name as "cust_last_name",
      c.cust_city as "cust_city",
      cursor(select o.order_total as "order_total", 
                    ''Order '' || rownum as "order_name",
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
    where customer_id = 1
  ) as "data"
from dual','aop_template_p01.pptx');

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print xlsx','SQL','APEX','xlsx','output','101955','101955','ok','0','3','select
  ''file1'' as "filename", 
  cursor(
    select
      c.cust_first_name as "cust_first_name",
      c.cust_last_name as "cust_last_name",
      c.cust_city as "cust_city",
      cursor(select o.order_total as "order_total", 
                    ''Order '' || rownum as "order_name",
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
    where customer_id = 1
  ) as "data"
from dual','aop_template_x01.xlsx');

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print docx (interactive)','SQL','SQL','docx','output','233590','233590','ok','1','10','select
                    ''file1'' as "filename", 
                    cursor(
                      select
                        c.cust_first_name as "cust_first_name",
                        c.cust_last_name as "cust_last_name",
                        c.cust_city as "cust_city",
                        cursor(select o.order_total as "order_total", 
                                      ''Order '' || rownum as "order_name",
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
                      where customer_id = 1
                    ) as "data"
                  from dual','select template_type, template_blob
  from aop_template  
 where id = 1');
 
Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print pdf','SQL','APEX','pdf','output','90848','90848','ok','1','5','select
  ''file1'' as "filename", 
  cursor(
    select
      c.cust_first_name as "cust_first_name",
      c.cust_last_name as "cust_last_name",
      c.cust_city as "cust_city",
      cursor(select o.order_total as "order_total", 
                    ''Order '' || rownum as "order_name",
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
    where customer_id = 1
  ) as "data"
from dual','aop_template_d01.docx');

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print AOP doc','SQL',null,'docx','output','83608','83608','ok','1','1','select
  ''file1'' as "filename", 
  cursor(
    select
      c.cust_first_name as "cust_first_name",
      c.cust_last_name as "cust_last_name",
      c.cust_city as "cust_city",
      cursor(select o.order_total as "order_total", 
                    ''Order '' || rownum as "order_name",
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
    where customer_id = 1
  ) as "data"
from dual',null);

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print Simple Letter','SQL','APEX','docx','simple_letter','127625','127625','ok','1','11','select
    ''file1'' as "filename",
    cursor
    (select 
         c.cust_first_name as "cust_first_name",
         c.cust_last_name as "cust_last_name",
         c.cust_city as "cust_city"
       from demo_customers c
      where c.customer_id = 1 
    ) as "data"
from dual','aop_simple_letter.docx');

Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print Simple QR Codes','SQL','APEX','docx','qr_codes','114846','114846','ok','0','12','select
    ''file1'' as "filename",
    cursor
    (select
        cursor
        (select
            product_name      as "product_name" ,
            category          as "category"     ,
            list_price        as "list_price"   ,
            ''QR''|| product_id as "qrcode"       ,
            ''qrcode''          as "qrcode_type"  ,
            ''60''              as "qrcode_width" ,
            ''60''              as "qrcode_height"
          from
            demo_product_info
          order by 1
        ) as "products"
      from
        dual
    ) as "data"
  from
    dual','aop_simple_qr.docx');
    
Insert into AOP_AUTOMATED_TEST (DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE) values ('Print docx','SQL','APEX','docx','output','233590','233590','ok','1','2','select
  ''file1'' as "filename", 
  cursor(
    select
      c.cust_first_name as "cust_first_name",
      c.cust_last_name as "cust_last_name",
      c.cust_city as "cust_city",
      cursor(select o.order_total as "order_total", 
                    ''Order '' || rownum as "order_name",
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
    where customer_id = 1
  ) as "data"
from dual','aop_template_d01.docx');

commit;

                                   
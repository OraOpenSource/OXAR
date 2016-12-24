--------------------------------------------------------
--  DDL for Table AOP_AUTOMATED_TEST
--------------------------------------------------------

  CREATE TABLE "AOP_AUTOMATED_TEST" 
   (	"ID" NUMBER, 
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
	"OUTPUT_TYPE_ITEM_NAME" VARCHAR2(100), 
	"OUTPUT_TO" VARCHAR2(100), 
	"SPECIAL" VARCHAR2(100), 
	"PROCEDURE_" VARCHAR2(100), 
	"CREATED_DATE" DATE DEFAULT sysdate, 
	"RUN_DATE" DATE, 
	"APP_ID" NUMBER, 
	"PAGE_ID" NUMBER
   ) ;
--------------------------------------------------------
--  DDL for Table AOP_OUTPUT
--------------------------------------------------------

  CREATE TABLE "AOP_OUTPUT" 
   (	"ID" NUMBER, 
	"OUTPUT_BLOB" BLOB, 
	"FILENAME" VARCHAR2(200), 
	"MIME_TYPE" VARCHAR2(200), 
	"LAST_UPDATE_DATE" DATE
   ) ;
--------------------------------------------------------
--  DDL for Table AOP_TEMPLATE
--------------------------------------------------------

  CREATE TABLE "AOP_TEMPLATE" 
   (	"ID" NUMBER, 
	"TEMPLATE_BLOB" BLOB, 
	"FILENAME" VARCHAR2(200), 
	"MIME_TYPE" VARCHAR2(200), 
	"LAST_UPDATE_DATE" DATE, 
	"TEMPLATE_TYPE" VARCHAR2(20), 
	"DESCRIPTION" VARCHAR2(4000)
   ) ;


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

CREATE OR REPLACE  TRIGGER "AOP_TEMPLATE_IUTRG" 
  before insert ON aop_template FOR EACH ROW
BEGIN
  if :new.id is null 
  then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
  end if;     
END;
/

CREATE OR REPLACE TRIGGER "AOP_AUTOMATED_TEST_IUTRG" 
before insert on AOP_AUTOMATED_TEST
 for each row begin  
   if :new.id is null 
   then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
   end if; 
end;
/

SET DEFINE OFF;   


Insert into AOP_AUTOMATED_TEST (ID,DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE,OUTPUT_TYPE_ITEM_NAME,OUTPUT_TO,SPECIAL,PROCEDURE_,CREATED_DATE,RUN_DATE,APP_ID,PAGE_ID) values (79154343032776274722465249329506393396,'Page:   25: Print Column Chart (multi-serie) Pptx','SQL','APEX','pptx','p25_output_multiple_charts',33925,33925,'ok',0,41,'with both_lines as
(
SELECT 
   ''line 1'' line_name, 
   NULL    AS LINK,
       rownum        AS x,
       o.order_total AS y
        FROM demo_customers c,
          demo_orders o
        WHERE c.customer_id = o.customer_id
union all
SELECT 
  ''line 2'' line_name, 
   NULL                AS LINK,
    rownum                    AS x,
    o.order_total*1.21/rownum AS y
  FROM demo_customers c,
    demo_orders o
  WHERE c.customer_id = o.customer_id
),
lines as (select ''line 1'' line_name from dual
          union all
          select  ''line 2'' line_name from dual),
both_columns as
(
SELECT 
   ''column 1'' column_name, 
                    c.cust_first_name || '' '' || c.cust_last_name as x,
                    sum(o.order_total)                          as y
                  from demo_customers c, demo_orders o
                  where c.customer_id = o.customer_id
                  group by c.cust_first_name || '' '' || c.cust_last_name
union all
SELECT 
  ''column 2'' column_name, 
                    c.cust_first_name || '' '' || c.cust_last_name as x,
                    sum(o.order_total*1.21/rownum)                          as y
                  from demo_customers c, demo_orders o
                  where c.customer_id = o.customer_id
                  group by c.cust_first_name || '' '' || c.cust_last_name
    order by 2
),
columns as (select ''column 1'' column_name from dual
          union all
          select  ''column 2'' column_name from dual)          
SELECT ''file1'' AS "filename",
  CURSOR
  (SELECT CURSOR
    (SELECT ''line''                 AS "type",
      ''My Multi-Series Line Chart'' AS "name",
      CURSOR
      (SELECT line_name AS "name",
        CURSOR
        (select link, x as "x", y as "y"
           from both_lines bl 
          where bl.line_name = l.line_name
        ) AS "data"
      FROM lines l
      ) AS "lines"
    FROM dual
    ) AS "line_chart",
    cursor(select
            ''column'' as "type",
            ''My Column Chart'' as "name",   
            cursor
            (select
                576     as "width" ,
                336     as "height",
                ''Title'' as "title in chart" ,
                ''true''  as "grid"  ,
                ''true''  as "border"
              from dual
            ) as "options",
            cursor(select
                column_name as "name",
                cursor
                (select null as link, x as "x", y as "y"
           from both_columns bl 
          where bl.column_name = l.column_name                
                ) as "data"
              from columns l
                  ) as "columns"
          from dual) as "column_chart"
  FROM dual
  ) AS "data"
FROM dual
','aop_template_multiple_charts.pptx',null,null,null,null,to_date('02/09/16','DD/MM/RR'),to_date('06/09/16','DD/MM/RR'),232,25);
Insert into AOP_AUTOMATED_TEST (ID,DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE,OUTPUT_TYPE_ITEM_NAME,OUTPUT_TO,SPECIAL,PROCEDURE_,CREATED_DATE,RUN_DATE,APP_ID,PAGE_ID) values (79154343032777483648284863958681099572,'Page:   16: Print Column Chart (multi-serie) PDF','SQL','APEX','pdf','p16_output_column_chart_multi',64623,64623,'ok',2,42,'select
    ''file1'' as "filename",
    cursor(select
        cursor(select
            c.cust_first_name || '' '' || c.cust_last_name as "customer",
            c.cust_city                                  as "city"    ,
            o.order_total                                as "total"   ,
            o.order_timestamp                            as "timestamp"
          from demo_customers c, demo_orders o
          where c.customer_id = o.customer_id
          order by c.cust_first_name || '' '' || c.cust_last_name               
        ) as "orders",
        cursor(select
            ''column'' as "type",
            ''My Column Chart'' as "name",   
            cursor
            (select
                576     as "width" ,
                336     as "height",
                ''Title'' as "title in chart" ,
                ''true''  as "grid"  ,
                ''true''  as "border"
              from dual
            ) as "options",
            cursor(select
                ''column '' || to_char(nbr) as "name",
                cursor
                (select
                    c.cust_first_name || '' '' || c.cust_last_name as "x",
                    sum(o.order_total) * nbr                          as "y"
                  from demo_customers c, demo_orders o
                  where c.customer_id = o.customer_id
                  group by c.cust_first_name || '' '' || c.cust_last_name
                  order by c.cust_first_name || '' '' || c.cust_last_name                 
                ) as "data"
              from (select 1 as nbr from dual union select 1.21 as nbr from dual)
                  ) as "columns"
          from dual) as "chart"
      from dual) as "data"
  from dual ','aop_template_chart_with_data.docx',null,null,null,null,to_date('02/09/16','DD/MM/RR'),to_date('06/09/16','DD/MM/RR'),232,16);
Insert into AOP_AUTOMATED_TEST (ID,DESCRIPTION,DATA_TYPE,TEMPLATE_TYPE,OUTPUT_TYPE,OUTPUT_FILENAME,EXPECTED_BYTES,RECEIVED_BYTES,RESULT,PROCESSING_SECONDS,SEQ_NR,DATA_SOURCE,TEMPLATE_SOURCE,OUTPUT_TYPE_ITEM_NAME,OUTPUT_TO,SPECIAL,PROCEDURE_,CREATED_DATE,RUN_DATE,APP_ID,PAGE_ID) values (79154343032778692574104478587855805748,'Page:   25: Print Column Chart (multi-serie) Docx','SQL','APEX','docx','p25_output_multiple_charts',86800,86800,'ok',0,43,'with both_lines as
(
SELECT 
   ''line 1'' line_name, 
   NULL    AS LINK,
       rownum        AS x,
       o.order_total AS y
        FROM demo_customers c,
          demo_orders o
        WHERE c.customer_id = o.customer_id
union all
SELECT 
  ''line 2'' line_name, 
   NULL                AS LINK,
    rownum                    AS x,
    o.order_total*1.21/rownum AS y
  FROM demo_customers c,
    demo_orders o
  WHERE c.customer_id = o.customer_id
),
lines as (select ''line 1'' line_name from dual
          union all
          select  ''line 2'' line_name from dual),
both_columns as
(
SELECT 
   ''column 1'' column_name, 
                    c.cust_first_name || '' '' || c.cust_last_name as x,
                    sum(o.order_total)                          as y
                  from demo_customers c, demo_orders o
                  where c.customer_id = o.customer_id
                  group by c.cust_first_name || '' '' || c.cust_last_name
union all
SELECT 
  ''column 2'' column_name, 
                    c.cust_first_name || '' '' || c.cust_last_name as x,
                    sum(o.order_total*1.21/rownum)                          as y
                  from demo_customers c, demo_orders o
                  where c.customer_id = o.customer_id
                  group by c.cust_first_name || '' '' || c.cust_last_name
    order by 2
),
columns as (select ''column 1'' column_name from dual
          union all
          select  ''column 2'' column_name from dual)          
SELECT ''file1'' AS "filename",
  CURSOR
  (SELECT CURSOR
    (SELECT ''line''                 AS "type",
      ''My Multi-Series Line Chart'' AS "name",
      CURSOR
      (SELECT line_name AS "name",
        CURSOR
        (select link, x as "x", y as "y"
           from both_lines bl 
          where bl.line_name = l.line_name
        ) AS "data"
      FROM lines l
      ) AS "lines"
    FROM dual
    ) AS "line_chart",
    cursor(select
            ''column'' as "type",
            ''My Column Chart'' as "name",   
            cursor
            (select
                576     as "width" ,
                336     as "height",
                ''Title'' as "title in chart" ,
                ''true''  as "grid"  ,
                ''true''  as "border"
              from dual
            ) as "options",
            cursor(select
                column_name as "name",
                cursor
                (select null as link, x as "x", y as "y"
           from both_columns bl 
          where bl.column_name = l.column_name                
                ) as "data"
              from columns l
                  ) as "columns"
          from dual) as "column_chart"
  FROM dual
  ) AS "data"
FROM dual
','aop_template_multiple_charts.docx',null,null,null,null,to_date('02/09/16','DD/MM/RR'),to_date('06/09/16','DD/MM/RR'),232,25);

commit;

Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values (1,'aop_template_d01.docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',to_date('26/06/15','DD/MM/RR'),'docx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values (2,'aop_template_p01.pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation',to_date('26/06/15','DD/MM/RR'),'pptx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values (3,'aop_template_x01.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',to_date('09/12/15','DD/MM/RR'),'xlsx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values (4,'aop_template_p02.pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation',to_date('02/08/15','DD/MM/RR'),'pptx',null);
Insert into AOP_TEMPLATE (ID,FILENAME,MIME_TYPE,LAST_UPDATE_DATE,TEMPLATE_TYPE,DESCRIPTION) values (5,'aop_template_p03.pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation',to_date('02/08/15','DD/MM/RR'),'pptx',null);

commit;

update aop_template t
   set t.template_blob = (select a.blob_content
                            from apex_application_files a 
                           where a.filename = t.filename
                             and rownum < 2
                         )
 where t.template_blob is null;
 
commit; 

CREATE TABLE "AOP_USER_TEST" 
   (	"ID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOT NULL ENABLE, 
	"API_KEY" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"JSON_CLOB" CLOB, 
	"DEBUG_DATE" DATE DEFAULT sysdate, 
	"USER_ID" NUMBER, 
	"TEMPLATE_BLOB" BLOB, 
	"TEMPLATE_FILENAME" VARCHAR2(200 BYTE), 
	"TEMPLATE_MIME_TYPE" VARCHAR2(200 BYTE), 
	"OUTPUT_BLOB" BLOB, 
	"OUTPUT_FILENAME" VARCHAR2(200 BYTE), 
	"OUTPUT_MIME_TYPE" VARCHAR2(200 BYTE), 
	"RESULT" VARCHAR2(4000 BYTE), 
	"EXPECTED_BYTES" NUMBER, 
	"RECEIVED_BYTES" NUMBER, 
	"RUN_DATE" DATE, 
	"PROCESSING_SECONDS" NUMBER, 
	"DESCRIPTION" CLOB, 
	 CONSTRAINT "AOP_USER_TEST_PK" PRIMARY KEY ("ID")
);

CREATE OR REPLACE TRIGGER "AOP_USER_TEST_ITRG" before
  insert
      on aop_user_test for each row begin 
if :new.user_id is null then
  select
      user_id
    into
      :new.user_id
    from
      aop_subscription
    where
      api_key = :new.api_key;
end if;
end;
/	 
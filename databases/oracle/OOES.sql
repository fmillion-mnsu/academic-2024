/*
Drop type person3 force;
Drop type emp4 force;
Drop type cust_orders_arr force;
Drop type cust3 force;
Drop type address3 force;
Drop type address_tab force;
*/

create type person3 as object
(
LNAME VARCHAR2 (12),
FNAME VARCHAR2 (12),
DOB DATE,
MEMBER FUNCTION age RETURN NUMBER,
PRAGMA RESTRICT_REFERENCES(age, WNDS)
)
NOT FINAL;
/

create or replace type emp4 under person3
(
SEX CHAR(1),
POSITION VARCHAR2(15),
RATE NUMBER,
COMMISSION NUMBER,
START_DATE DATE,
MEMBER FUNCTION tenyear RETURN varchar2,
PRAGMA RESTRICT_REFERENCES(tenyear, WNDS));
/

CREATE TYPE CUST_ORDERS_ARR AS VARRAY(4)
OF NUMBER (38);
/

create or replace type CUST3 under person3
(
ORDERS CUST_ORDERS_ARR,
CREDIT_LIMIT NUMBER
);
/

CREATE OR REPLACE TYPE address3 AS OBJECT
(address_type	varchar2(10),
STREET VARCHAR2(30),
CITY VARCHAR2 (15),
STATE VARCHAR2 (2),
ZIP NUMBER (10));
/

--***************************************************
CREATE TYPE address_tab AS TABLE OF
Address3;
/

create or replace type body person3 as
member function age return number
is
   v_age number;
   begin
      v_age := trunc((sysdate - self.dob)/365.25);
      return v_age;
   end;
end;
/

create or replace type body emp4 as
member function tenyear return varchar2
is
  v_years number;
  v_tenyear varchar2(3);
  begin
    v_tenyear := 'no';
    v_years := trunc((sysdate - self.start_date)/365.25);
    if v_years >= 10 then
      v_tenyear := 'yes';
    end if;
    return v_tenyear;
  end;

end;
/

create table BRANCH (
	BRANCH_NO NUMBER(38,0) not null,
	STREET VARCHAR2(30) null,
	CITY VARCHAR2(15) not null,
	STATE VARCHAR2(2) not null,
	ZIP NUMBER(5,0) null constraint BRANCH_ZIP_CHK check ( ZIP > 0 ) ,
	constraint BRANCH_BRANCHNO_PK primary key (BRANCH_NO) );

CREATE TABLE O_EMPLOYEE(
EMPLOYEE_NO NUMBER(38,0) not null,
END_DATE DATE,
EMPLOYEE emp4,
ADDRESS ADDRESS_TAB,
BRANCH_NO NUMBER(38,0) not null,
CONSTRAINT EMPLOYEE_BRANCH_NO_FK FOREIGN KEY (BRANCH_NO) REFERENCES BRANCH (BRANCH_NO),
CONSTRAINT EMPLOYEE_NO_PK PRIMARY KEY (EMPLOYEE_NO))
NESTED TABLE address STORE AS nested_address_table;

CREATE TABLE O_CUSTOMER(
CUSTOMER_NO NUMBER(38,0) not null,
TEL_NO VARCHAR2(15) null,
BALANCE NUMBER null,
BRANCH_NO NUMBER(38) null,
CUSTOMER CUST3,
ADDRESS ADDRESS_TAB,
CONSTRAINT CUST_NUM_PK PRIMARY KEY (CUSTOMER_NO),
CONSTRAINT CUSTOMER_BRANCH_NO_FK FOREIGN KEY (BRANCH_NO) REFERENCES BRANCH (BRANCH_NO))
NESTED TABLE address STORE AS nested_address_table1;

create table O_VENDOR (
	VENDOR_NO NUMBER(38,0) not null,
	NAME VARCHAR2(50) null,
	ADDRESS ADDRESS_TAB,
	TEL_NO VARCHAR2(12) null,
	constraint VENDOR_PK primary key (VENDOR_NO) )
        NESTED TABLE address STORE AS nested_address_table2;


create table TAX (
	TAX_NO NUMBER(38,0) not null,
	STATE CHAR(2) null,
	TAX_RATE NUMBER null,
	constraint TAX_PK primary key (TAX_NO) );

create table PRODVENDOR (
    	PO_NO NUMBER (38,0) not null,
	VENDOR_NO NUMBER(38,0) null,
	PRODUCT_NO NUMBER(38,0) not null,
	ORDER_DATE DATE null,
	EXPECTED_RECVD_DATE DATE null,
	ACTUAL_RECVD_DATE DATE null,
	VEND_QTY NUMBER(38,0) null,
	DPRICE CHAR(10) null,
	CONSTRAINT PRODVENDOR_PO_NO_PK PRIMARY KEY (PO_NO));

create table QTYDISCOUNT (
	QTYDISCOUNT_NO NUMBER(38,0) not null,
	D_PRICE NUMBER(38,0) null,
	MIN_QTY NUMBER(38,0) null,
	MAX_QTY CHAR(10) null,
	PRODUCT_NO NUMBER(38,0) null,
	constraint QTYDISCOUNT_PK primary key (QTYDISCOUNT_NO) );

create table RETURNPROD (
	RETURN_ID NUMBER(38,0) not null,
	DATE_RETURNED DATE not null,
	RETR_QTY NUMBER(38,0) null,
	AMOUNT_REFUNDED NUMBER null,
	PROD_CONDITION VARCHAR2(12) null,
	ORDERLINE_NO NUMBER(38,0) null,
	constraint RETURNPROD_RETURNID_PK primary key (RETURN_ID));

create table PRODUCT (
	PRODUCT_NO NUMBER(38,0) not null,
	BRAND VARCHAR2(15) null,
	CLASS VARCHAR2(20) null,
	PRODUCT_DESCRIPTION VARCHAR2(50) null,
	UNIT_PRICE NUMBER null,
	UNIT_COST NUMBER null,
	PRODUCT_CATEGORY VARCHAR2(15) null,
	QOH NUMBER(38,0) null,
	ORDER_LEVEL NUMBER(38,0) null,
	ORDER_QTY NUMBER(38,0) null,
	BACK_ORDER NUMBER(38,0) null,
	AVAIL_DATE DATE null,
	DAMAGED_QTY NUMBER(38,0) null,
	constraint PRODUCT_PRODUCTNO_PK primary key (PRODUCT_NO) );

create table ORDERS (
	ORDER_NO NUMBER(38,0) not null,
	ORDER_DATE DATE not null,
	SHIP_DATE DATE null,
	SHIPPING_METHOD VARCHAR2(12) null,
	TAX_STATUS CHAR(1) null,
	SUBTOTAL NUMBER null,
	TAX_AMT NUMBER null,
	SHIPPING_CHARGE NUMBER null,
	TOTAL_AMT NUMBER null,
	CUSTOMER_NO NUMBER(38,0) null,
	EMPLOYEE_NO NUMBER(38,0) null,
	BRANCH_NO NUMBER(38,0) null,
	constraint ORDERS_ORDERNO_PK primary key (ORDER_NO) );

create table ORDERLINE (
	ORDERLINE_NO NUMBER(38,0) not null,
	PRODUCT_NO NUMBER(38,0) null,
	QTY NUMBER(38,0) null,
	ORDER_NO NUMBER(38,0) null,
	constraint ORDERLINE_ORDERLINENO_PK primary key (ORDERLINE_NO) );

create table PROMOTION (
	PROMOTION_NO NUMBER(38,0) not null,
	P_PRICE NUMBER(38,0) null,
	START_DATE DATE null,
	END_DATE DATE null,
	PRODUCT_NO NUMBER(38,0) null, constraint PROMOTION_PK primary key (PROMOTION_NO) );

create table PRODUCTSET (
	PRODUCT_NO NUMBER(38,0) not null,
	PRODUCTSET_NO NUMBER(38,0) not null,
	PROD_QTY NUMBER(38,0) null,
	constraint PRODUCTSET_PK primary key (PRODUCTSET_NO, PRODUCT_NO) );

create table VENDORPRICE (
	VPRICE_NO NUMBER(38,0) not null,
	VENDOR_NO NUMBER(38,0) not null,
	PRODUCT_NO NUMBER(38,0) not null,
	VPRICE NUMBER(10,2) not null,
	DISCOUNT NUMBER(10,2) null,
	START_DATE DATE null,
	END_DATE DATE null, constraint VENDORPRICE_PK primary key (VPRICE_NO) );

CREATE TABLE backorder(
	backorder_no NUMBER (38),
	product_no NUMBER (38),
	bo_qty NUMBER (38),
	bo_date date,
	CONSTRAINT backorder_backorderno_pk PRIMARY KEY (backorder_no));

insert into BRANCH VALUES (100,'Michigan Street', 'Chicago','IL',60659);
insert into BRANCH VALUES (101,'Lake Avenue', 'Manakto','MN',56001);
insert into BRANCH VALUES (102,'Straight Drive', 'St. Peter','MN',56002);
insert into BRANCH VALUES (103,'Lake Street', 'Dallas','TX',32609);
insert into BRANCH VALUES (7502,'1400 Warren Street', 'Rochester','MN',null);
insert into BRANCH VALUES (7503,'1400 Drive Street', 'Rochester','MN',null);
insert into BRANCH VALUES (7040,null, 'Chicago','IL',null);
insert into BRANCH VALUES (7200,null, 'MADISON','WI',null);


INSERT INTO TAX VALUES	(101,'NY',0.077306618);
INSERT INTO TAX VALUES	(102,'NH',0);
INSERT INTO TAX VALUES	(103,'LA',0.079650877);
INSERT INTO TAX VALUES	(104,'HI',0.04);
INSERT INTO TAX VALUES	(105,'TX',0.07117549);
INSERT INTO TAX VALUES	(106,'MP',0);
INSERT INTO TAX VALUES	(107,'MH',0);
INSERT INTO TAX VALUES	(108,'GA',0.067139394);
INSERT INTO TAX VALUES	(109,'AS',0);
INSERT INTO TAX VALUES	(110,'VI',0.04);
INSERT INTO TAX VALUES	(111,'MS',0.070011099);
INSERT INTO TAX VALUES	(112,'MA',0.05);
INSERT INTO TAX VALUES	(113,'KY',0.06);
INSERT INTO TAX VALUES	(114,'IA',0.058971444);
INSERT INTO TAX VALUES	(115,'MI',0.06);
INSERT INTO TAX VALUES	(116,'AZ',0.069162196);
INSERT INTO TAX VALUES	(117,'PW',0);
INSERT INTO TAX VALUES	(118,'VA',0.045);
INSERT INTO TAX VALUES	(119,'OH',0.061417864);
INSERT INTO TAX VALUES	(120,'AR',0.066257571);
INSERT INTO TAX VALUES	(121,'MN',0.065547315);
INSERT INTO TAX VALUES	(122,'CN',0.132776316);
INSERT INTO TAX VALUES	(123,'CT',0.06);
INSERT INTO TAX VALUES	(124,'FL',0.066248394);
INSERT INTO TAX VALUES	(125,'DE',0);
INSERT INTO TAX VALUES	(126,'WV',0.06);
INSERT INTO TAX VALUES	(127,'FM',0);
INSERT INTO TAX VALUES	(128,'MO',0.058960829);
INSERT INTO TAX VALUES	(129,'AK',0.011199143);
INSERT INTO TAX VALUES	(130,'OR',0);
INSERT INTO TAX VALUES	(131,'ND',0.051805556);
INSERT INTO TAX VALUES	(132,'PR',0);
INSERT INTO TAX VALUES	(133,'RI',0.07);
INSERT INTO TAX VALUES	(134,'AL',0.067099475);
INSERT INTO TAX VALUES	(135,'WY',0.052255521);
INSERT INTO TAX VALUES	(136,'ID',0.050258065);
INSERT INTO TAX VALUES	(137,'MD',0.05);
INSERT INTO TAX VALUES	(138,'IL',0.067557027);
INSERT INTO TAX VALUES	(139,'WI',0.054117886);
INSERT INTO TAX VALUES	(140,'NM',0.060182292);
INSERT INTO TAX VALUES	(141,'NV',0.070202068);
INSERT INTO TAX VALUES	(142,'PA',0.061258341);
INSERT INTO TAX VALUES	(143,'GU',0.04);
INSERT INTO TAX VALUES	(144,'NE',0.057342488);
INSERT INTO TAX VALUES	(145,'WA',0.081597636);
INSERT INTO TAX VALUES	(146,'ME',0.05);
INSERT INTO TAX VALUES	(147,'TN',0.09375);
INSERT INTO TAX VALUES	(148,'CO',0.049812327);
INSERT INTO TAX VALUES	(149,'SC',0.056406619);
INSERT INTO TAX VALUES	(150,'NJ',0.059375);
INSERT INTO TAX VALUES	(151,'NC',0.069769031);
INSERT INTO TAX VALUES	(152,'KS',0.063387345);
INSERT INTO TAX VALUES	(153,'DC',0.0575);
INSERT INTO TAX VALUES	(154,'IN',0.06);
INSERT INTO TAX VALUES	(155,'CA',0.077865543);
INSERT INTO TAX VALUES	(156,'OK',0.06390142);
INSERT INTO TAX VALUES	(157,'UT',0.062882353);
INSERT INTO TAX VALUES	(158,'MT',0);
INSERT INTO TAX VALUES	(159,'VT',0.05007335);
INSERT INTO TAX VALUES	(160,'SD',0.047024793);

INSERT INTO O_VENDOR(VENDOR_NO,NAME,ADDRESS,TEL_NO)
 VALUES	(1000,'Samsung',address_tab(address3('permanent','21 Roscoe Dr','Rochester','MN',52010)),'509 631 2121');

INSERT INTO O_VENDOR(VENDOR_NO,NAME,ADDRESS,TEL_NO)
 VALUES	(1001,'Sony',address_tab(address3('permanent','109 Shepard Dr','Madison','WI',68012)),'302 241 2121');

INSERT INTO O_VENDOR(VENDOR_NO,NAME,ADDRESS,TEL_NO)
 VALUES	(1002,'Microsoft',address_tab(address3('permanent','310 Simpson Ave','New York','NY',78012)),'631 241 2121');

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1059,'',1000,NULL,CUST3('Jake','Roerig','12-SEP-1975',CUST_ORDERS_ARR(100,200,101,300),NULL),
 address_tab(address3('permanent','16 Skyline Drive','Mankato','MN','56001')));

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1000,'',2500,NULL,CUST3('Case','Steve','12-AUG-1970',CUST_ORDERS_ARR(1,2,101,300),5000),
 address_tab(address3('permanent','101 michigan','New Ulm','MN','56023')));

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1003,'',NULL,NULL,CUST3('Aslam','Kashif','10-AUG-1964',CUST_ORDERS_ARR(12,20,101,30),NULL),
address_tab(address3('permanent','762 Stadium Rd','Mankato','MN','56001')));

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1006,'',NULL,NULL,CUST3('Brin','Laral','10-JAN-1980',CUST_ORDERS_ARR(1,20,101,300),NULL),
address_tab(address3('permanent','52 Wacker','Chicago','IL','60626')));

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1024,'',9000,NULL,CUST3('Aslam','Muhammad','2-JUN-1972',CUST_ORDERS_ARR(100,2,1,300),NULL),
address_tab(address3('permanent','12 stadium','Madison','WI','54003')));

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1025,'',0,NULL,CUST3('George','Colony','12-AUG-1973',CUST_ORDERS_ARR(101,20,1,300),NULL),
address_tab(address3('permanent','314 Maywood','Mankato','MI','20000')));

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1029,'',60000,NULL,CUST3('Jake','Lara','15-DEC-1968',CUST_ORDERS_ARR(1005,2,1006,300),NULL),
address_tab(address3('permanent','214 golf','New York','NY','72314')));

INSERT INTO O_CUSTOMER(CUSTOMER_NO,TEL_NO,BALANCE,BRANCH_NO,CUSTOMER,ADDRESS)
VALUES (1023,'',2500,NULL,CUST3('Maria','Jensen','12-AUG-1969',CUST_ORDERS_ARR(1,2,1005,3000),5000),
address_tab(address3('permanent','10 State','New Ulm','MN','56023')));

INSERT INTO O_EMPLOYEE(EMPLOYEE_NO,End_Date,EMPLOYEE,BRANCH_NO,ADDRESS)
VALUES (1001,'15-DEC-2002',EMP4('Johnson','john','22-March-1970',
 '','Assistant',null,8000,'10-NOV-1990'),100,address_tab(address3('permanent','Michigan Street','Chicago','IL',null)));

INSERT INTO O_EMPLOYEE(EMPLOYEE_NO,End_Date,EMPLOYEE,BRANCH_NO,ADDRESS)
VALUES (1000,'12-May-2001',EMP4('Wilson','jake','12-May-1980',
'','Sales Rep',null,6000,'15-JUL-1992'),101,address_tab(address3('permanent','Lake Avenue','Boston','BN',null)));

INSERT INTO O_EMPLOYEE(EMPLOYEE_NO,End_Date,EMPLOYEE,BRANCH_NO,ADDRESS)
VALUES (1002,'15-DEC-2003',EMP4('Wilson','Mary','01-January-1960',
'','Assistant',null,10000,'01-jan-1980'),7040,address_tab(address3('permanent','Michigan Street','Minneapolis','MN',null)));

insert into ORDERS VALUES 	(1066,'	7-May-2003	','12-May-2003','ground','n',155088,0,0,155088,1059,null,null);
insert into ORDERS VALUES 	(100,'	15-Apr-2003	','13-Apr-2003','ground-air','y',62042,4067,3102,69211,1000,1000,null);
insert into ORDERS VALUES 	(110,'	3-Jan-2003	','13-Jan-2003','2day','y',156150,10235,12492,178877,1000,1001,null);
insert into ORDERS VALUES 	(1008,'	5-Jul-2003	','10-Jul-2003','2day-air','n',34650,0,2772,37422,1029,1000,null);
insert into ORDERS VALUES 	(1023,'	3-Mar-2003	','23-Mar-2003','2day-air','y',7130,467,570,8168,1000,1002,null);
insert into ORDERS VALUES 	(1005,'	7-Jul-2003	','10-Jul-2003','1day-air','y',284500,17070,28450,330020,1025,1000,null);
insert into ORDERS VALUES 	(1006,'	21-Apr-2003	','26-Apr-2003','1day-air','y',30000,1966,3000,34966,1023,1001,null);
insert into ORDERS VALUES 	(1007,'	27-Apr-2003	','29-Apr-2003','ground','n',39600,0,1980,41580,1003,1000,null);
insert into ORDERS VALUES 	(1032,'	1-May-2003	','10-May-2003','1day-air','y',103600,6791,10360,120751,1023,1001,null);
insert into ORDERS VALUES 	(1026,'	30-Apr-2003	','30-Apr-2003','ground','n',79875,0,0,79875,1029,1002,null);
insert into ORDERS VALUES 	(1025,'	29-Apr-2003	','29-Apr-2003','1day-air','y',165120,10823,16512,192455,1000,1000,null);
insert into ORDERS VALUES 	(1027,'	6-Apr-2003	','11-Apr-2003','ground','n',17820,0,0,17820,1029,1001,null);
insert into ORDERS VALUES 	(1028,'	7-Apr-2003	','11-Apr-2003','ground','n',64750,0,0,64750,1029,1000,null);
insert into ORDERS VALUES 	(1029,'	30-Apr-2003	','30-Apr-2003','ground','n',95750,0,0,95750,1000,1002,null);
insert into ORDERS VALUES 	(1065,'	2-May-2003	','12-May-2003','1day-air','y',690,8,69,767,1058,1000,null);
insert into ORDERS VALUES 	(1064,'	2-May-2003	','4-May-2003','1day','y',4970,56,497,5523,1058,1000,null);

INSERT INTO PRODUCT VALUES(120,'Microsoft','Xbox','Xbox',200,150,'Game',-202,30,20,0,null,0);
INSERT INTO PRODUCT VALUES(140,'Samsung','Memory Card','Xbox Memeory Card',50,25,'Game',-326,50,35,null,null,0);
INSERT INTO PRODUCT VALUES(130,'Microsoft','Controller','Xbox controller',55,25,'Game',-308,60,40,null,null,0);
INSERT INTO PRODUCT VALUES(110,'Microsoft','Xbox Set','Xbox,2 controller, 1 Mario game,2 memory cards',400,275,'Game',0,0,0,0,null,0);
INSERT INTO PRODUCT VALUES(150,'Sony','Mario Game','Mario Game for Xbox',50,25,'Game',-163,35,20,0,'29-Apr-2003',0);

INSERT INTO BACKORDER  VALUES	(1114,120,451,'	7-May-2003	');
INSERT INTO BACKORDER  VALUES	(1115,130,902,'	7-May-2003	');
INSERT INTO BACKORDER  VALUES	(1116,140,902,'	7-May-2003	');
INSERT INTO BACKORDER  VALUES	(1117,150,451,'	7-May-2003	');
INSERT INTO BACKORDER  VALUES	(1118,130,2,'	7-May-2003	');

INSERT INTO PROMOTION VALUES (	100,345,'	12-Apr-2003	','	12-Jun-2003	',	110);
INSERT INTO PROMOTION VALUES (	101,42,'	1-Apr-2003	','	30-Apr-2003	',	140);
INSERT INTO PROMOTION VALUES (	102,44,'	1-Apr-2003	','	30-May-2003	',	130);

INSERT INTO QTYDISCOUNT VALUES	(100,375,2,5,110);
INSERT INTO QTYDISCOUNT VALUES	(101,350,6,10,110);
INSERT INTO QTYDISCOUNT VALUES	(102,310,16,null,110);
INSERT INTO QTYDISCOUNT VALUES	(103,330,11,15,110);
INSERT INTO QTYDISCOUNT VALUES	(104,190,10,30,120);
INSERT INTO QTYDISCOUNT VALUES	(105,185,31,null,120);
INSERT INTO QTYDISCOUNT VALUES	(106,45,5,10,140);
INSERT INTO QTYDISCOUNT VALUES	(107,40,11,null,140);

INSERT INTO ORDERLINE VALUES	(1089,110,500,1066);
INSERT INTO ORDERLINE VALUES	(1090,130,2,1066);
INSERT INTO ORDERLINE VALUES	(100,110,200,100);
INSERT INTO ORDERLINE VALUES	(1004,140,25,110);
INSERT INTO ORDERLINE VALUES	(1005,140,1,100);
INSERT INTO ORDERLINE VALUES	(1006,130,130,110);
INSERT INTO ORDERLINE VALUES	(1007,120,800,110);
INSERT INTO ORDERLINE VALUES	(1027,130,900,1007);
INSERT INTO ORDERLINE VALUES	(1028,130,630,1008);
INSERT INTO ORDERLINE VALUES	(1024,110,500,1005);
INSERT INTO ORDERLINE VALUES	(1026,140,750,1006);
INSERT INTO ORDERLINE VALUES	(1041,110,23,1023);
INSERT INTO ORDERLINE VALUES	(1053,120,560,1032);
INSERT INTO ORDERLINE VALUES	(1043,110,500,1025);
INSERT INTO ORDERLINE VALUES	(1025,120,700,1005);
INSERT INTO ORDERLINE VALUES	(1044,130,230,1025);
INSERT INTO ORDERLINE VALUES	(1045,140,355,1026);
INSERT INTO ORDERLINE VALUES	(1046,120,355,1026);
INSERT INTO ORDERLINE VALUES	(1048,130,405,1027);
INSERT INTO ORDERLINE VALUES	(1049,120,350,1028);
INSERT INTO ORDERLINE VALUES	(1050,120,350,1029);
INSERT INTO ORDERLINE VALUES	(1051,110,100,1029);
INSERT INTO ORDERLINE VALUES	(1087,140,2,1064);
INSERT INTO ORDERLINE VALUES	(1088,110,2,1065);
INSERT INTO ORDERLINE VALUES	(1085,110,2,1064);
INSERT INTO ORDERLINE VALUES	(1086,120,22,1064);

INSERT INTO PRODVENDOR VALUES (1093,1002,120,	'	7-May-2003	','	14-May-2003	',null,471,148.8);
INSERT INTO PRODVENDOR VALUES (1094,1002,130,	'	7-May-2003	','	14-May-2003	',null,942,31.5);
INSERT INTO PRODVENDOR VALUES (1095,1000,140,	'	7-May-2003	','	14-May-2003	',null,937,31.5);
INSERT INTO PRODVENDOR VALUES (1096,1001,150,	'	7-May-2003	','	14-May-2003	',null,471,30.03);
INSERT INTO PRODVENDOR VALUES (1097,1002,130,	'	7-May-2003	','	14-May-2003	',null,42,31.5);

INSERT INTO VENDORPRICE VALUES	(103,1002,130,35,0.1,'	1-Jan-2003	','	1-Jan-2004	');
INSERT INTO VENDORPRICE VALUES	(104,1000,140,35,0.1,'	20-Feb-2002	','	3-Mar-2005	');
INSERT INTO VENDORPRICE VALUES	(105,1001,150,33,0.09,'	1-Jan-2002	','	1-Jan-2006	');
INSERT INTO VENDORPRICE VALUES	(100,1002,120,160,0.07,'5-Apr-2003	','	5-Apr-2004	');
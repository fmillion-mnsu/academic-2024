-- This script drops and recreates all table for SP database

DROP TABLE S CASCADE CONSTRAINTS;
DROP TABLE P CASCADE CONSTRAINTS;
DROP TABLE SP2 CASCADE CONSTRAINTS;


CREATE TABLE S(
S# VARCHAR(2) NOT NULL,
SNAME VARCHAR(5),
STATUS NUMBER(2),
CITY VARCHAR(6),
CONSTRAINT S_S#_PK PRIMARY KEY (S#));


CREATE TABLE P(
P# VARCHAR(2) NOT NULL,
PNAME VARCHAR(5),
COLOR VARCHAR(5),
WEIGHT number(2),
CITY VARCHAR(6),
CONSTRAINT P_P#_PK PRIMARY KEY(P#));


CREATE TABLE SP2(
S# VARCHAR(2) NOT NULL,
P# VARCHAR(2) NOT NULL,
QTY NUMBER(3),
ship_date Date,
CONSTRAINT SP2_S#_P#_PK PRIMARY KEY (S#, P#, ship_date) ,
CONSTRAINT SP2_S#_FK FOREIGN KEY (S#) REFERENCES S(S#),
CONSTRAINT SP2_P#_FK FOREIGN KEY (P#) REFERENCES P(P#)
);

grant select on S to public;
grant select on P to public;
grant select on SP2 to public;

insert into s values (	'S1','Smith',20,'London');
insert into s values (	'S2','Jones',10,'Paris');
insert into s values (	'S3','Black',30,'Paris');
insert into s values (	'S4','Clark',20,'London');
insert into s values (	'S5','Adams',30,'Athens');


insert into p values (	'P1','Nut','Red',12,'London');
insert into p values (	'P2','Bolt','Green',17,'Paris');
insert into p values (	'P3','Screw','Blue',17,'Rom');
insert into p values (	'P4','Screw','Red',14,'London');
insert into p values (	'P5','Cam','Blue',12,'Paris');
insert into p values (	'P6','Cog','Red',19,'London');



insert into SP2 values(	'S1','P1',300,'	17-Jan-2018	');
insert into SP2 values(	'S1','P2',200,'	12-Feb-2018	');
insert into SP2 values(	'S1','P3',400,'	18-Mar-2018	');
insert into SP2 values(	'S1','P4',200,'	1-Apr-2018	');
insert into SP2 values(	'S1','P5',100,'	10-May-2018	');
insert into SP2 values(	'S1','P6',100,'	16-Jun-2018	');
insert into SP2 values(	'S2','P1',300,'	13-Apr-2018	');
insert into SP2 values(	'S2','P2',400,'	10-May-2018	');
insert into SP2 values(	'S3','P2',200,'	6-Jun-2018	');
insert into SP2 values(	'S3','P2',100,'	1-Jan-2018	');
insert into SP2 values(	'S3','P2',100,'	11-Feb-2018	');
insert into SP2 values(	'S3','P2',300,'	18-Mar-2018	');
insert into SP2 values(	'S3','P2',400,'	13-Apr-2018	');
insert into SP2 values(	'S3','P2',200,'	10-May-2018	');
insert into SP2 values(	'S3','P2',100,'	6-Jun-2018	');
insert into SP2 values(	'S3','P2',100,'	9-Jul-2018	');
insert into SP2 values(	'S3','P2',300,'	14-Aug-2018	');
insert into SP2 values(	'S3','P2',400,'	9-Sep-2018	');
insert into SP2 values(	'S3','P2',200,'	2-Oct-2018	');
insert into SP2 values(	'S3','P2',100,'	5-Nov-2018	');
insert into SP2 values(	'S3','P2',100,'	11-Dec-2018	');
insert into SP2 values(	'S4','P2',200,'	14-Aug-2018	');
insert into SP2 values(	'S4','P4',300,'	10-May-2018	');
insert into SP2 values(	'S4','P5',400,'	18-Mar-2018	');


------------------------------------------------
-- Drop all schema.
-----------------------------------------------

alter session set recyclebin=off;

CREATE OR REPLACE
FUNCTION DROP_ALL_SCHEMA_OBJECTS RETURN NUMBER AS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	FOR OBJECT_REC IN (SELECT OBJECT_TYPE,'"'||OBJECT_NAME||'"'||DECODE(OBJECT_TYPE,'TABLE' ,' CASCADE CONSTRAINTS',NULL) OBJ_NAME
				      FROM USER_OBJECTS
				      WHERE OBJECT_TYPE IN ('TABLE','VIEW','PACKAGE','SEQUENCE','SYNONYM', 'MATERIALIZED VIEW')
				      ORDER BY OBJECT_TYPE) 
	LOOP
		EXECUTE IMMEDIATE ('DROP '||OBJECT_REC.OBJECT_TYPE||' ' ||OBJECT_REC.OBJ_NAME);
	END LOOP;          
	FOR OBJECT_REC IN (SELECT OBJECT_TYPE, '"'||OBJECT_NAME||'"' OBJ_NAME
				      FROM USER_OBJECTS  
				      WHERE OBJECT_TYPE NOT IN ('TYPE') 
				      AND OBJECT_NAME<>'DROP_ALL_SCHEMA_OBJECTS')
	LOOP
		EXECUTE IMMEDIATE ('DROP '||OBJECT_REC.OBJECT_TYPE||' ' ||OBJECT_REC.OBJ_NAME);
	END LOOP;
	FOR OBJECT_REC IN (SELECT OBJECT_TYPE, '"'||OBJECT_NAME||'"' OBJ_NAME
				      FROM USER_OBJECTS
				      WHERE OBJECT_TYPE IN ('TYPE'))
	LOOP
		EXECUTE IMMEDIATE ('DROP '||OBJECT_REC.OBJECT_TYPE||' ' ||OBJECT_REC.OBJ_NAME || ' FORCE');
	END LOOP;
RETURN 0;
END DROP_ALL_SCHEMA_OBJECTS;
/

SELECT DROP_ALL_SCHEMA_OBJECTS FROM DUAL;

--
-- Schema 
CREATE TABLE address
(addr_id VARCHAR(15),
 apartment Number(5),
 house_number number(5),
 street VARCHAR(15),
 city varchar(15),
 country varchar(15),
 state VARCHAR(15),
 zipCode number(15),
 PRIMARY KEY (addr_id)
 );

CREATE TABLE reviewer
(rev_id VARCHAR(15),
 name VARCHAR(15),
 sname VARCHAR(15),
 email VARCHAR(25),
 PRIMARY KEY (rev_id)
 );

CREATE TABLE rev_address
(addr_id VARCHAR(15),
rev_id VARCHAR(15),
 type VARCHAR(15),
PRIMARY KEY (addr_id, rev_id, type),
FOREIGN KEY(addr_id) REFERENCES address(addr_id),
FOREIGN KEY(rev_id) REFERENCES reviewer(rev_id)
 );

CREATE TABLE bankinfo
(bankinfo_id VARCHAR(15),
accountID VARCHAR(15),
 name varchar(15),
str_address varchar(15),
 PRIMARY KEY (bankinfo_id)
 );

CREATE TABLE author
(au_id VARCHAR(15),
name VARCHAR(25),
sname VARCHAR(25),
phone_number VARCHAR(25),
photo_location VARCHAR(50),
biography VARCHAR2(4000),
email VARCHAR(25),
password VARCHAR(25),
bankinfo_id VARCHAR(15),
CONSTRAINT author_no_pk  PRIMARY KEY (au_id),
FOREIGN KEY(bankinfo_id) REFERENCES bankinfo(bankinfo_id)
 );

CREATE TABLE contract
(Contract_ID VARCHAR(15),
cont_date DATE,
monthly_minSale number(9, 2),
loyalityr NUMBER(7, 2),
au_id VARCHAR(15),
PRIMARY KEY (Contract_ID),
FOREIGN KEY(au_id) REFERENCES author(au_id)
 );

CREATE TABLE author_address
(au_id VARCHAR(15),
addr_id VARCHAR(15),
 type VARCHAR(15),
PRIMARY KEY (au_id, addr_id, type),
FOREIGN KEY(au_id) REFERENCES author(au_id),
FOREIGN KEY(addr_id) REFERENCES address(addr_id)
 );

CREATE TABLE cover
(cov_id VARCHAR(15),
font VARCHAR(35),
font_size NUMBER(5),
image_source VARCHAR(50),
 PRIMARY KEY (cov_id)
 );

CREATE TABLE genre
(genre_id VARCHAR(15),
name VARCHAR(15),
PRIMARY KEY (genre_id)
 );

CREATE TABLE manuscript
(manusc_id VARCHAR(15),
title VARCHAR(50),
description VARCHAR2(4000),
number_of_pages NUMBER(5),
creation_date DATE,
source_man VARCHAR(50),
genre_id VARCHAR(15),
PRIMARY KEY (manusc_id),
FOREIGN KEY(genre_id) REFERENCES genre(genre_id)
 );

CREATE TABLE Author_CoAuthor_Manusc
(au_id VARCHAR(15),
manusc_id VARCHAR(15),
 primary VARCHAR(15),
PRIMARY KEY (au_id, manusc_id),
FOREIGN KEY(au_id) REFERENCES author(au_id),
FOREIGN KEY(manusc_id) REFERENCES manuscript(manusc_id)
 );

CREATE TABLE lateorders
(late_id VARCHAR(15),
DateToBeShipped DATE,
orderDate DATE,
description VARCHAR(50),
emailDateToCust DATE,
PRIMARY KEY (late_id)
 );

CREATE TABLE ship_address
(ship_add_id VARCHAR(15),
ship_country VARCHAR(15),
ship_city VARCHAR(15),
ship_state VARCHAR(15),
ship_street VARCHAR(15),
ship_house NUMBER(5),
ship_flat NUMBER(5),
PRIMARY KEY (ship_add_id)
 );

CREATE TABLE customer
(cust_id VARCHAR(15),
name VARCHAR(15),
sname VARCHAR(15),
phone_number VARCHAR(15),
addr_country VARCHAR(15),
addr_city VARCHAR(15),
addr_house NUMBER(5),
addr_flat NUMBER(5),
email VARCHAR(25),
PRIMARY KEY (cust_id)
 );

CREATE TABLE Manus_SendPub
(manusc_id VARCHAR(15),
version VARCHAR(15),
au_id VARCHAR(15),
versionStatus VARCHAR(15),
PRIMARY KEY (manusc_id, version),
recievedDate DATE,
sentDate DATE,
FOREIGN KEY(au_id) REFERENCES author(au_id),
FOREIGN KEY(manusc_id) REFERENCES manuscript(manusc_id)
 );

CREATE TABLE book
(book_id VARCHAR(15),
book_source VARCHAR(50),
book_creat_date DATE,
ISBN NUMBER(20),
retail_price NUMBER(10, 2),
cov_id VARCHAR(15),
acceptStatus VARCHAR(15),
version VARCHAR(15),
manusc_id VARCHAR(15),
PRIMARY KEY (book_id),
FOREIGN KEY(cov_id) REFERENCES cover(cov_id),
FOREIGN KEY(version, manusc_id) REFERENCES Manus_SendPub(version, manusc_id)
 );


CREATE TABLE online_shop
(Onl_shop_id VARCHAR(15),
shop_name VARCHAR(20),
PRIMARY KEY (Onl_shop_id)
 );

CREATE TABLE return_type
(type_id VARCHAR(15),
description VARCHAR(50),
PRIMARY KEY (type_id)
 );

CREATE TABLE ShipmentMethod
(ShipMeth_id VARCHAR(15),
name VARCHAR(15),
ship_price NUMBER(15),
PRIMARY KEY (ShipMeth_id)
 );


CREATE TABLE book_send_shop
(contact_id VARCHAR(15),
Onl_shop_id VARCHAR(15),
descr VARCHAR2(200),
contractDate DATE,
book_id VARCHAR(15),
biography VARCHAR2(2000),
commissionPercent NUMBER(7, 2),
PRIMARY KEY (contact_id),
FOREIGN KEY(Onl_shop_id ) REFERENCES online_shop (Onl_shop_id ),
FOREIGN KEY(book_id ) REFERENCES book(book_id)
 );

CREATE TABLE PromotionPrice
(sDate DATE,
contact_id VARCHAR(15),
endDate DATE,
discount_per NUMBER(7, 2),
PRIMARY KEY (sDate, contact_id),
FOREIGN KEY(contact_id) REFERENCES book_send_shop(contact_id)
 );

CREATE TABLE orderr
(order_id VARCHAR(15),
order_date DATE,
actualShip_date DATE,
planned_date DATE,
ship_add_id VARCHAR(15),
cust_id VARCHAR(15),
book_id VARCHAR(15),
late_id VARCHAR(15),
Onl_shop_id VARCHAR(15),
quantity NUMBER(7),
ShipMeth_id VARCHAR(15),
PRIMARY KEY (order_id),
FOREIGN KEY(ship_add_id) REFERENCES ship_address(ship_add_id),
FOREIGN KEY(cust_id) REFERENCES customer(cust_id),
FOREIGN KEY(book_id) REFERENCES book(book_id),
FOREIGN KEY(late_id) REFERENCES lateorders(late_id),
FOREIGN KEY(Onl_shop_id) REFERENCES online_Shop(Onl_shop_id),
FOREIGN KEY(ShipMeth_id) REFERENCES ShipmentMethod(ShipMeth_id)
 );

CREATE TABLE Returned_product
(type_id VARCHAR(15),
order_id VARCHAR(15),
datte DATE,
quantity NUMBER(7),
PRIMARY KEY (type_id, order_id, datte),
FOREIGN KEY(type_id) REFERENCES Return_type(type_id),
FOREIGN KEY(order_id) REFERENCES orderr(order_id)
 );


CREATE TABLE Monthly_Sale
(year NUMBER(5),
month NUMBER(5),
order_id VARCHAR(15),
payment NUMBER(7,2),
credit NUMBER(7,2),
PRIMARY KEY (year, month, order_id),
FOREIGN KEY(order_id) REFERENCES orderr(order_id)
 );

CREATE TABLE bookreview
(
rev_id VARCHAR(15),
manusc_id VARCHAR(15),
version VARCHAR(15),
sourceFile VARCHAR(50),
creation_date DATE,
PRIMARY KEY (rev_id, manusc_id, version),
FOREIGN KEY(rev_id) REFERENCES reviewer(rev_id),
FOREIGN KEY(manusc_id, version) REFERENCES Manus_SendPub(manusc_id, version)
 );



insert into Customer values	('cu1', 'Ara', 'Arakelyan', '234234', 'Armenia', 'Tsakhadzor',67,12, 'Ara@gmail.com');
insert into Customer values	('cu2', 'Stiop', 'Manukyan', '234235', 'Armenia', 'Goris',123,13, 'Stiop@gmail.com');
insert into Customer values	('cu20', 'Hakob', 'Paronyan', '27367263', 'Armenia', 'Yerevan',212,2, 'hak@sdh.ru');
insert into Customer values	('cu21', 'Kirakos', 'Tapoyan', '3767298', 'Armenia', 'Yerevan',37,2, 'kir@am.am');
insert into Customer values	('cu22', 'Tigran', 'Nazaryan', '2121212', 'Armenia', 'Yerevan',2112,1, 'tigran@gmail.com');
insert into Customer values	('cu23', 'Grigor', 'Bayrakdayan', '232323', 'Armenia', 'Yerevan',3,3, 'grigor@aua.am');
insert into Customer values	('cu24', 'Ani', 'Apresyan', '2423232', 'Armenia', 'Yerevan',2312,4, 'ani@gmail.com');
insert into Customer values	('cu25', 'Lina', 'Hovhannesyan', '2323232', 'Armenia', 'Yerevan',14,5, 'lina@aua.am');
insert into Customer values	('cu26', 'Sahar', 'Mojdahedi', '232323', 'Armenia', 'Yerevan',42,3, 'sahar@aua.am');
insert into Customer values	('cu27', 'Hovhannes', 'Zardayan', '2546556', 'Armenia', 'Yerevan',4,53, 'hovo@gmail.com');
insert into Customer values	('cu28', 'Narbeh', 'Dzja', '4545454', 'Armenia', 'Yerevan',23,54, 'narbeh@hacker.com');
insert into Customer values	('cu29', 'Syuzanna', 'Manucharyan', '98776454', 'Armenia', 'Yerevan',23,53, 'syzka@gmail.com');
insert into Customer values	('cu30', 'Nazeh', 'Nazlumi', '5323235', 'Armenia', 'Yerevan',23,64, 'nazeh@gmail.com');
insert into Customer values	('cu31', 'Sona', 'Poghosyan', '64049548', 'Armenia', 'Yerevan',23,34, 'sona@aua.am');



insert into bankinfo values	('bi1', 'ac1111', 'unibank', 'Vagharshian 11');
insert into bankinfo values	('bi10', 'ac1120', 'ABB', 'Abovyan 15');
insert into bankinfo values	('bi11', 'ac1121', 'unibank', 'Gulbengyan 59');
insert into bankinfo values	('bi12', 'ac1122', 'ABB', 'Malatiya 199');
insert into bankinfo values	('bi13', 'ac1123', 'Armeconom', 'Azatutyan 34');
insert into bankinfo values	('bi14', 'ac1124', 'Areksimbank', 'Amiryan 65');
insert into bankinfo values	('bi15', 'ac1125', 'ACBA', 'Artsakh 5');
insert into bankinfo values	('bi16', 'ac1126', 'HSBC', 'Komitas');
insert into bankinfo values	('bi17', 'ac1127', 'Artsakh', 'Njdeh 10');
insert into bankinfo values	('bi18', 'ac1128', 'Econom', 'Amiryan 28');
insert into bankinfo values	('bi19', 'ac1129', 'Anelik', 'Baghramyan 39');
insert into bankinfo values	('bi2', 'ac1112', 'HSBC', 'Tumanyan 12');
insert into bankinfo values	('bi20', 'ac1130', 'Anelik', 'Baghramyan 39');
insert into bankinfo values	('bi21', 'ac1131', 'ASHIB', 'Lousavorich 19');
insert into bankinfo values	('bi22', 'ac1131', 'ASHIB', 'Komitas');
insert into bankinfo values	('bi23', 'ac1132', 'Armeconom', 'Nzhdeh');
insert into bankinfo values	('bi24', 'ac1133', 'ACBA', 'Bagratunyats');
insert into bankinfo values	('bi25', 'ac1134', 'Areksimbank', 'Saryan');
insert into bankinfo values	('bi26', 'ac1135', 'Anelik', 'Baghramyan');
insert into bankinfo values	('bi27', 'ac1136', 'ProCredit', 'Sayat Nova');
insert into bankinfo values	('bi28', 'ac1137', 'Ararat', 'Mashtots');
insert into bankinfo values	('bi29', 'ac1138', 'ADB', 'Proshyan');
insert into bankinfo values	('bi3', 'ac1113', 'Ararat Bank', 'Gayi 5');
insert into bankinfo values	('bi30', 'ac1139', 'ABB', 'Proshyan');
insert into bankinfo values	('bi31', 'ac1140', 'ACBA', 'Bagratunyats');
insert into bankinfo values	('bi32', 'ac1141', 'ADB', 'Proshyan');
insert into bankinfo values	('bi33', 'ac1142', 'ADB', 'Proshyan');
insert into bankinfo values	('bi34', 'ac1143', 'ACBA', 'Bagratunyats');
insert into bankinfo values	('bi35', 'ac1144', 'ABB', 'Araratyan 7');
insert into bankinfo values	('bi36', 'ac1145', 'Artsakh', 'Charentsi 1');
insert into bankinfo values	('bi37', 'ac1146', 'America', 'Lousavorich 11');
insert into bankinfo values	('bi38', 'ac1147', 'ASHIB', 'Lousavorich23');
insert into bankinfo values	('bi39', 'ac1148', 'Armeconom', 'Artsakh 12');
insert into bankinfo values	('bi4', 'ac1114', 'ABB', 'Abovyan 15');
insert into bankinfo values	('bi5', 'ac1115', 'ProCredit', 'Sayat Nova 10');
insert into bankinfo values	('bi6', 'ac1116', 'ACBA', 'Charentsi 5');
insert into bankinfo values	('bi7', 'ac1117', 'ASHIB', 'Azatutyan 26');
insert into bankinfo values	('bi8', 'ac1118', 'Armeconom', 'Khandjyan 4');
insert into bankinfo values	('bi9', 'ac1119', 'Agricol', 'Tumanyan 4');




insert into address values 	('add1', 11, 12, 'Gyulbekyan', 'Yerevan', 'Armenia', 'n/a', 123);
insert into address values 	('add10', 31, 75, 'Kochar', 'Yerevan', 'Armenia', 'n/a', 58);
insert into address values 	('add11', 2, 88, 'Tichina', 'Yerevan', 'Armenia', 'n/a', 887);
insert into address values 	('add12', 58, 1, 'Damadedova', 'Moscow', 'Russia', 'n/a', 25);
insert into address values 	('add13', 7, 95, 'Lomonosov', 'Nijny Novgorod', 'Russia', 'n/a', 79);
insert into address values 	('add14', 41, 56, 'Armstrong', 'LosAngeles', 'USA', 'California', 33);
insert into address values 	('add15', 4, 11, 'A.khachatryan', 'Yerevan', 'Armenia', 'n/a', 23);
insert into address values 	('add16', 7, 89, 'Orbeli', 'Yerevan', 'Armenia', 'n/a', 45);
insert into address values 	('add17', 56, 89, 'Charents', 'Abovyan', 'Armenia', 'n/a', 122);
insert into address values 	('add18', 6, 58, 'Hambardzumyan', 'Charenstavan', 'Armenia', 'n/a', 145);
insert into address values 	('add19', 1, 1, 'Hill', 'Abovyan', 'Armenia', 'n/a', 124);
insert into address values 	('add2', 22, 122, 'Proshyan', 'Yerevan', 'Armenia', 'n/a', 123);
insert into address values 	('add20', 32, 356, 'Kutuzov', 'Vardenis', 'Armenia', 'n/a', 5454);
insert into address values 	('add21', 35, 24, 'Babajanyan', 'Martuni', 'Armenia', 'n/a', 456);
insert into address values 	('add22', 24, 5, 'Erkanyan', 'Yerevan', 'Armenia', 'n/a', 122);
insert into address values 	('add23', 25, 5, 'Banavan', 'Yerevan', 'Armenia', 'n/a', 1325);
insert into address values 	('add24', 5, 1, 'Kutuzov', 'Yerevan', 'Armenia', 'n/a', 4155);
insert into address values 	('add25', 45, 5, 'Moskovyan', 'Yerevan', 'Armenia', 'n/a', 1455);
insert into address values 	('add26', 45, 5, 'Tichina', 'Yerevan', 'Amenia', 'n/a', 1144);
insert into address values 	('add27', 98, 24, 'Arabo', 'Yerevan', 'Armenia', 'n/a', 1555);
insert into address values 	('add28', 12, 23, 'Narekatsi', 'Yerevan', 'Armenia', 'n/a', 22);
insert into address values 	('add29', 12, 23, 'Sebastia', 'Yerevan', 'Armenia', 'n/a', 7517);
insert into address values 	('add3', 131, 14, 'Gyulbekyan', 'Gyumri', 'Armenia', 'n/a', 125);
insert into address values 	('add30', 12, 13, 'Erevanyan', 'Yerevan', 'Armenia', 'n/a', 1212);
insert into address values 	('add31', 77, 9, 'Moskovyan', 'Yerevan', 'Armenia', 'n/a', 219);
insert into address values 	('add32', 88, 9, 'Nalbandyan', 'Yerevan', 'Armenia', 'n/a', 3123);
insert into address values 	('add33', 99, 27, 'Teryan', 'Yerevan', 'Armenia', 'n/a', 2123);
insert into address values 	('add34', 11, 1, 'Mazmanyan', 'Yerevan', 'Armenia', 'n/a', 1212);
insert into address values 	('add35', 45, 12, 'Nar Dos', 'Yerevan', 'Armenia', 'n/a', 1299);
insert into address values 	('add36', 121, 12, 'Abovyan', 'Yerevan', 'Armenia', 'n/a', 6479);
insert into address values 	('add37', 273, 4, 'North', 'New York', 'USA', 'NY', 28238);
insert into address values 	('add38', 211, 24, 'Michigan', 'Chicago', 'USA', 'IL', 25372);
insert into address values 	('add39', 34, 4, 'ONail', 'Indianapolis', 'USA', 'IN', 2828);
insert into address values 	('add4', 1341, 7, 'Gyulbekyan', 'Vanadzor', 'Armenia', 'n/a', 126);
insert into address values 	('add40', 23, 22, 'Bznuni', 'Yerevan', 'Aremnia', 'n/a', 122);
insert into address values 	('add41', 323, 45, 'Hayrapetyan', 'Yerevan', 'Aremnia', 'n/a', 423);
insert into address values 	('add42', 23, 53, 'Kiyevyan', 'Yerevan', 'Aremnia', 'n/a', 232);
insert into address values 	('add43', 4, 3, 'Teryan', 'Yerevan', 'Aremnia', 'n/a', 1212);
insert into address values 	('add44', 23, 2, 'vagharshyan', 'Yerevan', 'Armenia', 'n/a', 2627);
insert into address values 	('add45', 23, 2, 'Moskovyan', 'Yerevan', 'Armenia', 'n/a', 767);
insert into address values 	('add46', 23, 3, 'Leningradyan', 'Yerevan', 'Armenia', 'n/a', 2323);
insert into address values 	('add47', 12, 3, 'Alaverdyan', 'Yerevan', 'Armenia', 'n/a', 12);
insert into address values 	('add48', 12, 3, 'Kochar', 'Yerevan', 'Armenia', 'n/a', 2122);
insert into address values 	('add49', 44, 2, 'Ervanduni', 'Yerevan', 'Armenia', 'n/a', 2629);
insert into address values 	('add5', 121, 112, 'Shvili', 'Tbilisi', 'Georgia', 'n/a', 127);
insert into address values 	('add50', 12, 1, 'Baghramyan', 'Yerevan', 'Armenia', 'n/a', 1259);
insert into address values 	('add51', 12, 1, 'Isahakyan', 'Yerevan', 'Armenia', 'n/a', 2368);
insert into address values 	('add6', 25, 148, 'Baghramyan', 'Yerevan', 'Armenia', 'n/a', 123);
insert into address values 	('add7', 13, 28, 'Avetisyan', 'Yerevan', 'Armenia', 'n/a', 126);
insert into address values 	('add8', 4, 259, 'Lvovyan', 'Yerevan', 'Armenia', 'n/a', 442);
insert into address values 	('add9', 68, 4, 'Komitas', 'Yerevan', 'Armenia', 'n/a', 12);





insert into Reviewer  values	('rev1', 'Ando', 'Aloyan' , 'pis@yandex.ru');
insert into Reviewer  values	('rev10', 'Vahan', 'Minasyan' , 'vahik@google.com');
insert into Reviewer  values	('rev11', 'Karp', 'Khachvanqyan' , 'karp@karpich.am');
insert into Reviewer  values	('rev12', 'Aram', 'Khanjyan' , 'aram@hayastan.com');
insert into Reviewer  values	('rev2', 'Monika', 'Sargsyan' , 'sss@he2.ru');
insert into Reviewer  values	('rev3', 'Gohar', 'Asatryan' , 'asd@mail.ru');
insert into Reviewer  values	('rev4', 'Gagik', 'Gaprielyan' , 'gg@hotmail.com');
insert into Reviewer  values	('rev5', 'Gagik', 'Tsarukyan' , 'dod@gmail.com');
insert into Reviewer  values	('rev6', 'Siranush', 'Ankapyan' , 'sirik@gmail.com');
insert into Reviewer  values	('rev7', 'Adibek', 'Sudibekyan' , 'adib@sut.am');
insert into Reviewer  values	('rev8', 'Paruyr', 'Hayrikyan' , 'paruyr@hayrikyan.com');
insert into Reviewer  values	('rev9', 'Artashes', 'Geghamyan' , 'black@mail.com');



insert into Rev_Address values	('add3', 'rev1', 'work');
insert into Rev_Address values	('add45', 'rev10', 'work');
insert into Rev_Address values	('add47', 'rev11', 'home');
insert into Rev_Address values	('add50', 'rev12', 'work');
insert into Rev_Address values	('add4', 'rev2', 'work');
insert into Rev_Address values	('add5', 'rev3', 'work');
insert into Rev_Address values	('add15', 'rev4', 'work');
insert into Rev_Address values	('add16', 'rev5', 'work');
insert into Rev_Address values	('add22', 'rev6', 'home');
insert into Rev_Address values	('add34', 'rev7', 'work');
insert into Rev_Address values	('add35', 'rev8', 'work');
insert into Rev_Address values	('add36', 'rev9', 'work');




insert into author values 	('au1', 'Vahe', 'Abrahamyan', '234132', '/loc/auph1.jpg', 'sdfadsf', 'vahe@yahoo.com', '1111', 'bi1');
insert into author values 	('au10', 'Natasha', 'Ivanovna', '732578954', '/loc/auph10.jpg', 'This tallented atuhor…..', 'natashik@mail.ru', '1120', 'bi10');
insert into author values 	('au11', 'Cyrus', 'Azarbod', '1818542698', '/loc/auph11.jpg', 'He is a well known Professor in USA…', 'ca1959@gmail.com', '1121', 'bi11');
insert into author values 	('au12', 'Sam', 'Nikol', '1818545896', '/loc/auph54.jpg', 'Born in Dubai, this Polish author…', 'Sam@yahoo.com', '1122', 'bi12');
insert into author values 	('au13', 'Nikoghos', 'Abajan', '12455', '/loc/auph55.jpg', 'Non very famous author for Armenian publis…', 'nikogh@gmail.com', '1124', 'bi13');
insert into author values 	('au14', 'Vachagan', 'Haroyan', '22356', '/loc/auph56.jpg', 'Vachagan Haroyan is a famous Armenian scientist…', 'vacho@aes.com', '1125', 'bi14');
insert into author values 	('au15', 'Kirakos', 'Ghaltaghchyan', '45699', '/loc/auph57.jpg', 'Poems and lyrics are written…', 'kirakos@hotmail.com', '1126', 'bi15');
insert into author values 	('au16', 'Madagaskar', 'Sargsyan', '45678', '/loc/auph58.jpg', 'Geography versus culture…', 'mado@gmail.com', '1127', 'bi16');
insert into author values 	('au17', 'Narek', 'Simonyan', '4444477', '/loc/auph10.jpg', 'Short story refers to a work of fiction that is usually written in prose, usually in narrative format. This format or medium tends to be more pointed than longer work', 'nmarek@freenet.am', '1128', 'bi17');
insert into author values 	('au18', 'Narine', 'Nushikyan', '4454574', '/loc/auph11.jpg', 'Many short story writers define their work through a combination of creative, personal expression and artistic integrity. As a result, many attempt to resist categorization by genre', 'nanar@gmail.com', '4455', 'bi18');
insert into author values 	('au19', 'Karine', 'Muradyan', '487878', '/loc/auph12.jpg', 'Many short story writers define their work through a combination of creative, personal expression and artistic integrity. As a result, many attempt to resist categorization by genre', 'kara@google.com', '4475', 'bi19');
insert into author values 	('au2', 'Hakob', 'Poghosyan', '234133', '/loc/auph2.jpg', 'sdfs', 'hak@yahoo.com', '1112', 'bi2');
insert into author values 	('au20', 'Arthur', 'Araratyan', '478887', '/loc/auph13.jpg', 'As a result, definitions of the short story based upon length splinter even more when the writing process is taken into consideration.', 'arthur@yahoo.com', '54545', 'bi20');
insert into author values 	('au21', 'Iskuhi', 'Hayrapetyan', '447889', '/loc/auph14.jpg', 'Short stories have their origins in oral story-telling traditions and the prose anecdote, a swiftly-sketched situation that quickly comes to its point.', 'iska@gmail.com', '5457556', 'bi21');
insert into author values 	('au22', 'Aram', 'Hayrapetyan', '353647', '/loc/auph90.jpg', 'he opera premiered at the Opera-Comique of Paris on 3 March 1875, but its opening run was denounced by the majority of critics.[4] It was almost withdrawn after its fourth or fifth performance, and although this was avoided, ultimately having 48 pe', 'aram@yahoo.com', '128127', 'bi22');
insert into author values 	('au23', 'Grigor', 'Barseghyan', '3836202', '/loc/auph91.jpg', 'he opera premiered at the Opera-Comique of Paris on 3 March 1875, but its opening run was denounced by the majority of critics.[4] It was almost withdrawn after its fourth or fifth performance, and although this was avoided, ultimately having 48 pe', 'grig@gmail.com', '38643', 'bi23');																															
insert into author values 	('au24', 'Hajk', 'Abrahamyan', '292870', '/loc/auph92.jpg', 'Since the 1880s it has been one of the worlds most performed operas[7] and a staple of the operatic repertoire. ', 'haykanaz@gmail.com', '2937832', 'bi24');
insert into author values 	('au25', 'Eranuhi', 'Grigoryan', '388890', '/loc/auph92.jpg', 'Within a few years, the traditional distinction between opera (serious, heroic and declamatory) and opera comique ', 'eran_grig@freenet.am', '276276', 'bi25');
insert into author values 	('au26', 'Mesrop', 'Avetisyan', '121277', '/loc/auph93.jpg', 'The early death of Bizet and the negligence of his immediate heirs and publisher led, as with most of Bizets operas, to major textual problems for which scholars and performers only began to find solutions since the 1960s.[10]', 'mosos@sticmail.com', '2992829', 'bi26');
insert into author values 	('au27', 'Hajk', 'Saghatelyan', '283828', '/loc/auph92.jpg', 'The early death of Bizet and the negligence of his immediate heirs and publisher led, as with most of Bizets operas, to major textual problems for which scholars and performers only began to find solutions since the 1960s.[10]', 'sgho@gmail.com', '26382382', 'bi27');
insert into author values 	('au28', 'Aram', 'Hajyan', '212656', '/loc/auph93.jpg', 'Mathematics is the study of quantity, structure, space, and change. Mathematicians seek out patterns.[2][3]They formulate new conjectures', 'aram@aua.am', '8382328', 'bi28');
insert into author values 	('au29', 'Souren', 'Khachatryan', '277377', '/loc/auph94.jpg', 'here is debate over whether mathematical objects such as numbers and points really exist or whether they are manmade. The mathe', 'suren@aua.am', '2378239', 'bi29');
insert into author values 	('au3', 'Vahan', 'Minasyan', '652525', '/loc/auph3.jpg', 'Was born in Armenia…', 'vah@yahoo.com', '1113', 'bi3');
insert into author values 	('au30', 'Gurgen', 'Khachatryan', '626167', '/loc/auph95.jpg', 'Today, mathematics is used throughout the world as an essential tool in many fields, including natural science, engineering, medicine', 'gurgen@aua.am', '128371827', 'bi30');
insert into author values 	('au31', 'Saro', 'Lernikyan', '2736273', '/loc/auph96.jpg', '509–1564) was an influential French theologian and pastor during the Protestant Reformation.', 'saro@rm.ru', '2737263', 'bi31');
insert into author values 	('au32', 'Karen', 'Darbinyan', '237278', '/loc/auph97.jpg', 'Calvin was mainly based in Geneva where he promoted reforms in the church. He introduced', 'karen@mail.ru', '3232', 'bi32');
insert into author values 	('au33', 'Levon', 'Shahinyan', '233234', '/loc/auph98.jpg', 'ms of church government and liturgy, despite the opposition of several powerful families in the city. Calvins writing and preaching provided the seeds for the branch of theology', 'levon@yandex.ru', '23213', 'bi33');
insert into author values 	('au34', 'Karo', 'Astvatsatryan', '453454', '/loc/auph99.jpg', 'Calvin fled to Basel, Switzerland, where in 1536 he published the first edition of his seminal work Institutes of the Christian Religion.', 'karo@gmail.com', '31232', 'bi34');
insert into author values 	('au35', 'Never', 'Mnacakanyan', '373739', '/loc/auph789.jpg', 'Never is Armenian tv anchor.', 'never@gmail.com', '7676', 'bi35');
insert into author values 	('au36', 'Karapet', 'Hayrapetyan', '1736287', '/loc/auph799.jpg', 'Karapet Hayrapetyan was born in 1967.', 'karapet@hh.am', '32637', 'bi36');
insert into author values 	('au37', 'Vardges', 'Petrosyan', '3732689', '/loc/auph780.jpg', 'Armenian writer whose primary aim to discuss problems of youth..', 'vard@rose.ru', '72632', 'bi37');
insert into author values 	('au38', 'Arthur', 'Asaduryan', '221298', '/loc/auph800.jpg', 'Very talented writer…', 'arti@gmail.com', '118281', 'bi38');
insert into author values 	('au39', 'Ara', 'Gharagebakyan', '2387237', '/loc/auph200.jpg', 'Memories and bittersweet life…', 'ara@gmail.com', '236818', 'bi39');
insert into author values 	('au4', 'Gerasim', 'Petrosyan', '271465', '/loc/auph4.jpg', '…. Is unique Armenian writer….', 'geras@gmail.com', '1114', 'bi4');
insert into author values 	('au5', 'Sona', 'Poghosyan', '648514', '/loc/auph5.jpg', 'Was born in….', 'son@rambler.ru', '1115', 'bi5');
insert into author values 	('au6', 'Arevik', 'Muradyan', '482684', '/loc/auph6.jpg', 'Outstanding writer….', 'arevsun@gmail.com', '1116', 'bi6');
insert into author values 	('au7', 'Sioneh', 'Nazary', '225974', '/loc/auph7.jpg', 'This author has a very extraordinary type of writing….', 'siu@yahoo.com', '1117', 'bi7');
insert into author values 	('au8', 'Janibek', 'Saribekyan', '723349', '/loc/auph8.jpg', 'He is just 12 years old,but…', 'jan_sar@gmail.com', '1118', 'bi8');
insert into author values 	('au9', 'Valodia', 'Paskevich', '732655887', '/loc/auph9.jpg', 'he is russian handsome …', 'valodik@mail.ru', '1119', 'bi9');





insert into Contract values	('co10', '5-Mar-2009',200,8, 'au12');	
insert into Contract values	('co11', '1-Jan-209',120,15, 'au13');	
insert into Contract values	('co12', '2-Jan-2009',150,20, 'au14');	
insert into Contract values	('co13', '1-Feb-2009',100,20, 'au15');	
insert into Contract values	('co14', '1-Feb-2009',120,25, 'au16');	
insert into Contract values	('co15', '1-Jan-209',100,15, 'au17');	
insert into Contract values	('co16', '1-Feb-2009',150,20, 'au18');	
insert into Contract values	('co17', '1-Mar-2009',120,20, 'au19');	
insert into Contract values	('co18', '1-Apr-2009',130,25, 'au20');	
insert into Contract values	('co19', '20-Jan-2009',200,15, 'au21');	
insert into Contract values	('co20', '5-Jan-2009',400,20, 'au22');	
insert into Contract values	('co21', '5-Feb-2009',230,23, 'au23');	
insert into Contract values	('co22', '1-Feb-2009',120,10, 'au24');	
insert into Contract values	('co23', '12-Jan-2009',100,8, 'au25');	
insert into Contract values	('co24', '14-Feb-2009',300,20, 'au26');	
insert into Contract values	('co25', '12-Jan-2009',250,18, 'au27');	
insert into Contract values	('co26', '2-Feb-2002',200,10, 'au28');	
insert into Contract values	('co27', '13-Oct-2006',129,14, 'au29');	
insert into Contract values	('co28', '11-Dec-2008',120,12, 'au30');	
insert into Contract values	('co29', '10-Jan-2009',234,13, 'au31');	
insert into Contract values	('co30', '10-Jan-2009',434,12, 'au32');	
insert into Contract values	('co31', '10-Jan-2009',380,13, 'au33');	
insert into Contract values	('co32', '10-Jan-2009',233,12, 'au34');	
insert into Contract values	('co33', '15-Dec-2008',200,30, 'au35');	
insert into Contract values	('co36', '10-Jan-2005',130,14, 'au36');	
insert into Contract values	('co37', '12-Jul-2008',129,12, 'au37');	
insert into Contract values	('co38', '12-Aug-2008',140,12, 'au38');	
insert into Contract values	('co39', '10-May-2007',230,12, 'au39');	
insert into Contract values	('co9', '12-May-2007',500,20, 'au11');	
insert into Contract values	('con1', '11-Nov-2008',100,0.7, 'au1');	
insert into Contract values	('con2', '12-Nov-2008',150,0.8, 'au2');	
insert into Contract values	('con3', '5-May-2009',80,0.5, 'au5');	
insert into Contract values	('con4', '23-Jun-2007',200,1.3, 'au6');	
insert into Contract values	('con5', '7-Jul-209',50,2.8, 'au7');	
insert into Contract values	('con6', '29-Mar-2009',100,1.5, 'au8');	
insert into Contract values	('con7', '9-Feb-2008',145,2.1, 'au9');	
insert into Contract values	('con8', '14-Apr-2005',110,15, 'au10');	




insert into Author_Address values 	('au1', 'add1', 'home');
insert into Author_Address values 	('au10', 'add13', 'work');
insert into Author_Address values 	('au11', 'add14', 'home');
insert into Author_Address values 	('au12', 'add16', 'home');
insert into Author_Address values 	('au13', 'add17', 'home');
insert into Author_Address values 	('au14', 'add18', 'work');
insert into Author_Address values 	('au15', 'add20', 'work');
insert into Author_Address values 	('au16', 'add21', 'home');
insert into Author_Address values 	('au17', 'add23', 'home');
insert into Author_Address values 	('au18', 'add24', 'work');
insert into Author_Address values 	('au19', 'add25', 'work');
insert into Author_Address values 	('au2', 'add2', 'home');
insert into Author_Address values 	('au20', 'add26', 'home');
insert into Author_Address values 	('au21', 'add27', 'work');
insert into Author_Address values 	('au22', 'add28', 'work');
insert into Author_Address values 	('au23', 'add29', 'work');
insert into Author_Address values 	('au24', 'add30', 'work');
insert into Author_Address values 	('au25', 'add31', 'work');
insert into Author_Address values 	('au26', 'add32', 'work');
insert into Author_Address values 	('au27', 'add33', 'work');
insert into Author_Address values 	('au28', 'add37', 'work');
insert into Author_Address values 	('au29', 'add38', 'work');
insert into Author_Address values 	('au3', 'add6', 'home');
insert into Author_Address values 	('au30', 'add39', 'work');
insert into Author_Address values 	('au31', 'add40', 'home');
insert into Author_Address values 	('au32', 'add41', 'home');
insert into Author_Address values 	('au33', 'add42', 'home');
insert into Author_Address values 	('au34', 'add43', 'home');
insert into Author_Address values 	('au35', 'add44', 'work');
insert into Author_Address values 	('au36', 'add46', 'work');
insert into Author_Address values 	('au37', 'add48', 'home');
insert into Author_Address values 	('au38', 'add49', 'work');
insert into Author_Address values 	('au39', 'add51', 'work');
insert into Author_Address values 	('au4', 'add7', 'home');
insert into Author_Address values 	('au5', 'add8', 'home');
insert into Author_Address values 	('au6', 'add9', 'home');
insert into Author_Address values 	('au7', 'add10', 'home');
insert into Author_Address values 	('au8', 'add11', 'home');
insert into Author_Address values 	('au9', 'add12', 'home');




insert into Cover values	('cv1', 'arial',12, '/loc/cv1.jpg');
insert into Cover values	('cv2', 'arial am',13, '/loc/cv2.jpg');
insert into Cover values	('cv23', 'arial',16, '/loc/cv23.jpg');
insert into Cover values	('cv24', 'San Serif',14, '/loc/cv24.jpg');
insert into Cover values	('cv25', 'Verdana',12, '/loc/cv25.jpg');
insert into Cover values	('cv26', 'Verdana',14, '/loc/cv26.jpg');
insert into Cover values	('cv27', 'Times Armenian',16, '/loc/cv27.jpg');
insert into Cover values	('cv28', 'Artaromian',14, '/loc/cv28.jpg');
insert into Cover values	('cv29', 'Baltica Cyrilic',20, '/loc/cv29.jpg');
insert into Cover values	('cv30', 'SanSerif',18, '/loc/cv30.jpg');


insert into Genre values	('gnr1', 'Romance');
insert into Genre values	('gnr2', 'Drama');
insert into Genre values	('gnr3', 'Triller');
insert into Genre values	('gnr4', 'Historical');
insert into Genre values	('gnr5', 'Science');



insert into Manuscript values	('man1', 'kku', 'asdfa', 123, '14-Jan-2009', '/loc/mn1.doc', 'gnr1');																							
insert into Manuscript values	('man10', 'Soil types of Armenia', 'It is broad resarch about soil quality…', 150, '11-Nov-2001', '/loc/mn10.doc', 'gnr5');																							
insert into Manuscript values	('man11', 'Dreams', 'Fantastic ideas about space…', 350, '1-Dec-2009', '/loc/cmt6.doc', 'gnr3');																							
insert into Manuscript values	('man12', 'Emptiness', 'Boring feelingsabout different things…', 220, '2-Apr-2009', '/loc/cmt6.doc', 'gnr1');																							
insert into Manuscript values	('man13', 'Life beyond life', 'th the rise of the comparatively realistic novel, the short story evolved as a miniature version, with some of its first perfectly independent examples in the tales of E.T.A. Hoffmann. Othe', 455, '15-Feb-2009', '/loc/mn13.txt', 'gnr5');																							
insert into Manuscript values	('man14', 'White wolf', 'Some authors are known almost entirely for their short stories, either by choice (they wrote nothing else) or by critical regard (short-story writing is thought of as a challenging art).', 125, '15-Feb-2009', '/loc/mn14.txt', 'gnr3');																							
insert into Manuscript values	('man15', 'In the darkness', ' Wodehouse and Ernest Hemingway were highly accomplished writers of both short stories and novels.', 230, '15-Feb-2009', '/loc/mn15.txt', 'gnr2');																							
insert into Manuscript values	('man16', 'When you gone', ' Usually a short story focuses on only one incident, has a single plot, a single setting, a small number of characters, and covers a short period of time.', 456, '15-Feb-2009', '/loc/mn16.txt', 'gnr1');																							
insert into Manuscript values	('man17', 'Cryptoghraphy for beginners', ' Usually a short story focuses on only one incident, has a single plot, a single setting, a small number of characters, and covers a short period of time.', 589, '15-Feb-2009', '/loc/mn17.txt', 'gnr2');																							
insert into Manuscript values	('man18', 'Boundry', ' Perhaps the oldest and most direct ancestor of the short story is the anecdote and illustrative story, straight to the point.', 180, '15-Feb-2009', '/loc/mn18.txt', 'gnr5');																							
insert into Manuscript values	('man19', 'My wings', 'he story is set in Seville, Spain, c. 1830, and concerns the eponymous Carmen, a beautiful Gypsy with a fiery temper. Free with her love, she woos the corporal Don Jose, an inexperienced soldier. Their relationship leads to his rejection of his for', 450, '15-Feb-2009', '/loc/mn19.txt', 'gnr5');																							
insert into Manuscript values	('man2', 'abc', 'asdfasdfa', 121, '13-Mar-2008', '/loc/mn2.doc', 'gnr2');																							
insert into Manuscript values	('man20', 'Armenian kitchen', 'The librettists, for whom Carmen "had little importance" (they had four other operas on stage in Paris at that time), secretly tried to induce the singers to over-dramatis', 80, '28-Feb-2008', '/loc/mn20.txt', 'gnr3');																							
insert into Manuscript values	('man21', 'Concept of Mathemtics', 'Mathematics is the study of quantity, structure, space, and change. Mathematicians seek out patterns.[2][3]They formulate new conjectures and establish truth by rigorous deduction from appropriately chosen axioms and definitions', 300, '12-Feb-2009', '/loc/mn21.doc', 'gnr5');																							
insert into Manuscript values	('man22', 'New Era', 'There is debate over whether mathematical objects such as numbers and points really exist or whether they are manmade. The mathematician Benjamin Peirce called mathematics "the science that draws necessary conclusions', 600, '13-Mar-2009', '/loc/mn22.doc', 'gnr5');																							
insert into Manuscript values	('man23', 'Ararat', 'This book about nostaligie.', 300, '10-Oct-2008', '/loc/mn23.doc', 'gnr2');																							
insert into Manuscript values	('man24', 'Armenia and Turkey', 'About conflict of these two nations.', 500, '10-Oct-2008', '/loc/mn24.doc', 'gnr3');																							
insert into Manuscript values	('man25', 'Contemporary Armenia', 'Armenian question and its current status…', 340, '10-Oct-2008', '/loc/mn25.doc', 'gnr3');																							
insert into Manuscript values	('man26', 'Love in time ov cholera', 'Love story, inncreadibly nice story…', 267, '13-Oct-2006', '/loc/mn26.doc', 'gnr4');																							
insert into Manuscript values	('man27', 'Adorable', 'Whan you are tired of life…', 340, '11-Dec-2007', '/loc/mn27.doc', 'gnr3');																							
insert into Manuscript values	('man28', 'Gossip Girls', 'Life of American teenagers…', 678, '3-Sep-2008', '/loc/mn28.doc', 'gnr4');																							
insert into Manuscript values	('man29', 'Red roof', 'When sun arises…', 230, '22-Jul-2009', '/loc/mn29.doc', 'gnr2');																							
insert into Manuscript values	('man3', 'tsit', 'zaa', 324, '11-Jun-2009', '/loc/mn3.doc', 'gnr1');																							
insert into Manuscript values	('man30', 'Soft sofa', 'Last sentence of this database. I hope this work will end soon.', 140, '11-Jun-2009', '/loc/mn30.jpg', 'gnr4');																							
insert into Manuscript values	('man4', 'manc', 'asdfa', 100, '12-Jun-2009', '/loc/mn4.doc', 'gnr3');																							
insert into Manuscript values	('man5', 'Party time', 'this book is about night people of moscow…', 540, '10-Apr-2009', '/loc/mn5.docx', 'gnr2');																							
insert into Manuscript values	('man6', 'Heart in tears', 'This is a love story about….', 320, '25-Jul-2009', '/loc/mn6.doc', 'gnr2');																							
insert into Manuscript values	('man7', 'Concepts Of DataBase', 'This book is about basic structures of DB…', 289, '15-Aug-2008', '/loc/mn7.docx', 'gnr5');																							
insert into Manuscript values	('man8', 'My Life Story', 'Amazing Book about….', 144, '19-Sep-2009', '/loc/mn8.doc', 'gnr3');																							
insert into Manuscript values	('man9', 'Without Title', 'Short novels with Armenian perceptions of life.', 210, '10-Oct-2000', '/loc/mn9.txt', 'gnr3');																							




insert into Author_CoAuthor_Manusc values	('au1', 'man1', 'y');
insert into Author_CoAuthor_Manusc values	('au1', 'man2', 'n');
insert into Author_CoAuthor_Manusc values	('au1', 'man3', 'n');
insert into Author_CoAuthor_Manusc values	('au10', 'man6', 'y');
insert into Author_CoAuthor_Manusc values	('au11', 'man7', 'y');
insert into Author_CoAuthor_Manusc values	('au12', 'man8', 'y');
insert into Author_CoAuthor_Manusc values	('au13', 'man9', 'y');
insert into Author_CoAuthor_Manusc values	('au14', 'man10', 'y');
insert into Author_CoAuthor_Manusc values	('au15', 'man11', 'y');
insert into Author_CoAuthor_Manusc values	('au16', 'man12', 'y');
insert into Author_CoAuthor_Manusc values	('au17', 'man13', 'y');
insert into Author_CoAuthor_Manusc values	('au18', 'man14', 'y');
insert into Author_CoAuthor_Manusc values	('au19', 'man15', 'y');
insert into Author_CoAuthor_Manusc values	('au2', 'man2', 'y');
insert into Author_CoAuthor_Manusc values	('au20', 'man16', 'y');
insert into Author_CoAuthor_Manusc values	('au21', 'man17', 'y');
insert into Author_CoAuthor_Manusc values	('au22', 'man18', 'y');
insert into Author_CoAuthor_Manusc values	('au23', 'man18', 'n');
insert into Author_CoAuthor_Manusc values	('au24', 'man19', 'y');
insert into Author_CoAuthor_Manusc values	('au25', 'man19', 'n');
insert into Author_CoAuthor_Manusc values	('au26', 'man20', 'y');
insert into Author_CoAuthor_Manusc values	('au27', 'man20', 'n');
insert into Author_CoAuthor_Manusc values	('au28', 'man21', 'y');
insert into Author_CoAuthor_Manusc values	('au29', 'man21', 'n');
insert into Author_CoAuthor_Manusc values	('au30', 'man21', 'n');
insert into Author_CoAuthor_Manusc values	('au31', 'man22', 'y');
insert into Author_CoAuthor_Manusc values	('au32', 'man22', 'n');
insert into Author_CoAuthor_Manusc values	('au33', 'man22', 'n');
insert into Author_CoAuthor_Manusc values	('au34', 'man22', 'n');
insert into Author_CoAuthor_Manusc values	('au35', 'man23', 'y');
insert into Author_CoAuthor_Manusc values	('au35', 'man24', 'y');
insert into Author_CoAuthor_Manusc values	('au35', 'man25', 'y');
insert into Author_CoAuthor_Manusc values	('au36', 'man26', 'y');
insert into Author_CoAuthor_Manusc values	('au36', 'man27', 'y');
insert into Author_CoAuthor_Manusc values	('au37', 'man28', 'y');
insert into Author_CoAuthor_Manusc values	('au38', 'man29', 'y');
insert into Author_CoAuthor_Manusc values	('au39', 'man30', 'y');
insert into Author_CoAuthor_Manusc values	('au9', 'man5', 'y');



insert into Manus_SendPub values	('man1', 'v1', 'au1', 'n', '12-Jan-2009', '13-Jan-2009');				
insert into Manus_SendPub values	('man1', 'v2', 'au1', 'n', '13-Jan-2009', '14-Jan-2009');				
insert into Manus_SendPub values	('man1', 'v3', 'au1', 'y', '14-Jan-2009', '15-Jan-2009');				
insert into Manus_SendPub values	('man10', 'v1', 'au14', 'n', '5-Jun-2009', '5-Nov-2009');				
insert into Manus_SendPub values	('man10', 'v2', 'au14', 'y', '25-May-2009', '');				
insert into Manus_SendPub values	('man11', 'v1', 'au15', 'n', '3-Mar-2009', '3-May-2009');				
insert into Manus_SendPub values	('man11', 'v2', 'au15', '', '3-Jul-2009', '');				
insert into Manus_SendPub values	('man12', 'v1', 'au16', 'n', '2-Feb-2009', '2-Sep-2009');				
insert into Manus_SendPub values	('man12', 'v2', 'au16', '', '', '');				
insert into Manus_SendPub values	('man13', 'v1', 'au17', 'n', '5-Mar-2009', '12-Mar-2009');				
insert into Manus_SendPub values	('man13', 'v2', 'au17', 'n', '15-Mar-2009', '24-Mar-2009');				
insert into Manus_SendPub values	('man13', 'v3', 'au17', 'y', '25-Mar-2009', '');				
insert into Manus_SendPub values	('man14', 'v1', 'au18', 'n', '1-Apr-2009', '11-Apr-2009');				
insert into Manus_SendPub values	('man14', 'v2', 'au18', 'n', '15-Apr-2009', '22-Apr-2009');				
insert into Manus_SendPub values	('man14', 'v3', 'au18', 'y', '25-Apr-2009', '');				
insert into Manus_SendPub values	('man15', 'v1', 'au19', 'n', '4-Apr-2009', '9-Apr-2009');				
insert into Manus_SendPub values	('man15', 'v2', 'au19', 'n', '12-Apr-2009', '19-Apr-2009');				
insert into Manus_SendPub values	('man15', 'v3', 'au19', 'y', '20-Apr-2009', '');				
insert into Manus_SendPub values	('man16', 'v1', 'au20', 'n', '1-Mar-2009', '7-Mar-2009');				
insert into Manus_SendPub values	('man16', 'v2', 'au20', 'n', '10-Mar-2009', '17-Mar-2009');				
insert into Manus_SendPub values	('man16', 'v3', 'au20', 'y', '21-Mar-2009', '');				
insert into Manus_SendPub values	('man17', 'v1', 'au21', 'n', '2-Feb-2009', '7-Feb-2009');				
insert into Manus_SendPub values	('man17', 'v2', 'au21', 'n', '10-Feb-2009', '17-Feb-2009');				
insert into Manus_SendPub values	('man17', 'v3', 'au21', 'y', '20-Feb-2009', '');				
insert into Manus_SendPub values	('man2', 'v1', 'au2', 'n', '15-Jan-2009', '17-Jan-2009');				
insert into Manus_SendPub values	('man2', 'v2', 'au2', 'y', '18-Jan-2009', '20-Jan-2009');				
insert into Manus_SendPub values	('man23', 'v1', 'au35', 'n', '12-Dec-2008', '20-Dec-2008');				
insert into Manus_SendPub values	('man23', 'v2', 'au35', 'y', '22-Dec-2008', '25-Dec-2008');				
insert into Manus_SendPub values	('man24', 'v1', 'au35', 'n', '12-Dec-2008', '20-Dec-2008');				
insert into Manus_SendPub values	('man24', 'v2', 'au35', 'y', '22-Dec-2008', '25-Dec-2008');				
insert into Manus_SendPub values	('man25', 'v1', 'au35', 'n', '12-Dec-2008', '20-Dec-2008');				
insert into Manus_SendPub values	('man25', 'v2', 'au35', 'y', '22-Dec-2008', '25-Dec-2008');				
insert into Manus_SendPub values	('man26', 'v1', 'au36', 'n', '11-Dec-2008', '11-Jan-2009');				
insert into Manus_SendPub values	('man26', 'v2', 'au36', 'n', '15-Jan-2007', '30-Jan-2007');				
insert into Manus_SendPub values	('man26', 'v3', 'au36', 'y', '1-Feb-2007', '12-Feb-2007');				
insert into Manus_SendPub values	('man27', 'v1', 'au36', 'n', '11-Nov-2004', '11-Dec-2004');				
insert into Manus_SendPub values	('man27', 'v2', 'au36', 'y', '17-Dec-2004', '23-Dec-2004');				
insert into Manus_SendPub values	('man28', 'v1', 'au37', 'n', '14-Apr-2005', '20-Apr-2005');				
insert into Manus_SendPub values	('man28', 'v2', 'au37', 'y', '21-Apr-2005', '21-Apr-2005');				
insert into Manus_SendPub values	('man29', 'v1', 'au38', 'n', '11-Apr-2009', '22-Apr-2009');				
insert into Manus_SendPub values	('man29', 'v2', 'au38', 'n', '27-Apr-2009', '5-May-2009');				
insert into Manus_SendPub values	('man29', 'v3', 'au39', 'n', '12-May-2009', '15-May-2009');				
insert into Manus_SendPub values	('man29', 'v4', 'au39', 'y', '20-May-2009', '25-May-2009');				
insert into Manus_SendPub values	('man3', 'v1', 'au1', 'n', '22-Jan-2009', '12-Apr-2009');				
insert into Manus_SendPub values	('man30', 'v1', 'au39', 'n', '21-Sep-2009', '26-Sep-2009');				
insert into Manus_SendPub values	('man30', 'v2', 'au39', 'y', '29-Sep-2009', '5-Oct-2009');				
insert into Manus_SendPub values	('man7', 'v1', 'au11', 'n', '9-Sep-2009', '9-Dec-2009');				
insert into Manus_SendPub values	('man8', 'v1', 'au12', 'n', '9-Sep-2009', '13-Sep-2009');				
insert into Manus_SendPub values	('man9', 'v1', 'au13', 'n', '5-May-2009', '5-Oct-2009');				


insert into Book values	('b1', 'B2', '21-Jan-2009',1211111,8000,'cv1', 'n', 'v3', 'man1');
insert into Book values	('b2', 'B2', '22-Jan-2009',1211112,8020,'cv2', 'y', 'v2', 'man2');
insert into Book values	('b23', 'B2', '30-Dec-2008',1111123,100,'cv23', 'y', 'v2', 'man23');
insert into Book values	('b24', 'B2', '30-Dec-2008',1111124,120,'cv24', 'y', 'v2', 'man24');
insert into Book values	('b25', 'B2', '30-Dec-2008',1111125,130,'cv25', 'y', 'v2', 'man25');
insert into Book values	('b26', 'B2', '1-Dec-2005',1111126,150,'cv26', 'y', 'v3', 'man26');
insert into Book values	('b27', 'B2', '14-Feb-2005',1111127,123,'cv27', 'y', 'v2', 'man27');
insert into Book values	('b28', 'B2', '13-May-2006',1111128,150,'cv28', 'y', 'v2', 'man28');
insert into Book values	('b29', 'B2', '15-Jun-2009',1111109,160,'cv29', 'y', 'v4', 'man29');
insert into Book values	('b30', 'B2', '20-Oct-2009',1111129,300,'', 'y', 'v2', 'man30');



insert into bookreview values	('rev1', 'man1', 'v1', '/loc/cm1.doc', '13-Jan-2009');	
insert into bookreview values	('rev1', 'man13', 'v2', '/loc/cmt10.doc', '15-Mar-2009');	
insert into bookreview values	('rev1', 'man14', 'v1', '/loc/cmt11.doc', '5-Apr-2009');	
insert into bookreview values	('rev1', 'man14', 'v2', '/loc/cmt12.doc', '15-Apr-2009');	
insert into bookreview values	('rev2', 'man15', 'v1', '/loc/cmt13.doc', '2-Apr-2009');	
insert into bookreview values	('rev2', 'man15', 'v2', '/loc/cmt14.doc', '10-Apr-2009');	
insert into bookreview values	('rev3', 'man16', 'v1', '/loc/cmt15.doc', '5-Mar-2009');	
insert into bookreview values	('rev3', 'man16', 'v2', '/loc/cmt16.doc', '15-Mar-2009');	
insert into bookreview values	('rev4', 'man17', 'v1', '/loc/cmt17.doc', '2-Mar-2009');	
insert into bookreview values	('rev4', 'man17', 'v2', '/loc/cmt18.doc', '12-Mar-2009');	
insert into bookreview values	('rev10', 'man23', 'v1', '/loc/cmt19.doc', '19-Dec-2008');	
insert into bookreview values	('rev1', 'man1', 'v2', '/loc/cm2.doc', '14-Jan-2009');	
insert into bookreview values	('rev10', 'man24', 'v1', '/loc/cmt20.doc', '19-Dec-2009');	
insert into bookreview values	('rev10', 'man25', 'v1', '/loc/cmt21.doc', '19-Dec-2009');	
insert into bookreview values	('rev11', 'man26', 'v1', '/loc/cmt22.doc', '13-Mar-2004');	
insert into bookreview values	('rev11', 'man26', 'v2', '/loc/cmt23.doc', '14-Apr-2004');	
insert into bookreview values	('rev11', 'man27', 'v1', '/loc/cmt24.doc', '15-May-2005');	
insert into bookreview values	('rev3', 'man28', 'v1', '/loc/cmt25.doc', '16-Jun-2007');	
insert into bookreview values	('rev12', 'man29', 'v1', '/loc/cmt26.doc', '16-Apr-2009');	
insert into bookreview values	('rev12', 'man29', 'v2', '/loc/cmt27.doc', '8-May-2009');	
insert into bookreview values	('rev12', 'man29', 'v3', '/loc/cmt28.doc', '15-May-2009');	
insert into bookreview values	('rev2', 'man30', 'v1', '/loc/cmt29.doc', '1-Sep-2008');	
insert into bookreview values	('rev1', 'man1', 'v3', '/loc/cm3.doc', '15-Jan-2009');	
insert into bookreview values	('rev4', 'man7', 'v1', '/loc/cm4.docx', '11-Sep-2008');	
insert into bookreview values	('rev4', 'man8', 'v1', '/loc/cmt5.doc', '10-Sep-2009');	
insert into bookreview values	('rev5', 'man9', 'v1', '/loc/cmt6.doc', '5-Jul-2009');	
insert into bookreview values	('rev5', 'man10', 'v1', '/loc/cmt7.doc', '5-Aug-2009');	
insert into bookreview values	('rev6', 'man11', 'v1', '/loc/cmt8.doc', '3-Mar-2009');	
insert into bookreview values	('rev1', 'man13', 'v1', '/loc/cmt9.doc', '10-Mar-2009');	


insert into ShipmentMethod values	('shM1', 'ground',20);
insert into ShipmentMethod values	('shM2', 'train',30);


insert into Ship_Address values	('sha1', 'Albania', 'Tirana', 'n/a', 'Kalon', 54, 11);
insert into Ship_Address values	('sha2', 'France', 'Lille', 'n/a', 'Abaneh', 23, 1);
insert into Ship_Address values	('sha20', 'Armenia', 'Yerevan', 'n/a', 'Charents', null, null);
insert into Ship_Address values	('sha21', 'Armenia', 'Yerevan', 'n/a', 'Komitas', null, null);
insert into Ship_Address values	('sha22', 'Armenia', 'Yerevan', 'n/a', 'Erebuni', null, null);
insert into Ship_Address values	('sha23', 'Armenia', 'Masis', 'n/a', 'Eghvard', null, null);
insert into Ship_Address values	('sha24', 'Armenia', 'Abbovyan', 'n/a', 'Duryan', null, null);
insert into Ship_Address values	('sha25', 'Armenia', 'Hrazdan', 'n/a', 'Teryan', null, null);
insert into Ship_Address values	('sha26', 'Armenia', 'Charentsavan', 'n/a', 'Sargsyan', null, null);
insert into Ship_Address values	('sha27', 'Armenia', 'Sevan', 'n/a', 'Alaverdyan', null, null);
insert into Ship_Address values	('sha28', 'Armenia', 'Qjavar', 'n/a', 'Tibilsiyan', null, null);
insert into Ship_Address values	('sha29', 'Armenia', 'Martuni', 'n/a', 'Moskovyan', null, null);
insert into Ship_Address values	('sha30', 'Armenia', 'Masis', 'n/a', 'Abovyan', null, null);
insert into Ship_Address values	('sha31', 'Armenia', 'Yerevan', 'n/a', 'Sayat Nova', null, null);


insert into LateOrders values	('l26', '', '', '', '');
insert into LateOrders values	('lt1', '11-Nov-2009', '14-Nov-2009', 'asdfads', '12-Nov-2009');
insert into LateOrders values	('lt20', '', '', '', '');
insert into LateOrders values	('lt21', '', '', '', '');
insert into LateOrders values	('lt22', '', '', '', '');
insert into LateOrders values	('lt23', '', '', '', '');
insert into LateOrders values	('lt24', '', '', '', '');
insert into LateOrders values	('lt25', '', '', '', '');
insert into LateOrders values	('lt27', '', '', '', '');
insert into LateOrders values	('lt28', '', '', '', '');
insert into LateOrders values	('lt29', '', '', '', '');
insert into LateOrders values	('lt30', '', '', '', '');
insert into LateOrders values	('lt31', '', '', '', '');


insert into Online_Shop values	('onsh1', 'Amazon');
insert into Online_Shop values	('onsh2', 'Volga');


insert into Return_Type values	('t1', 'It was not proper book');
insert into Return_Type values	('t2', 'It was present.');
insert into Return_Type values	('t3', 'Too many books.');

insert into Orderr values	('ord1', '12-Nov-2009', '1-Jan-2010', '1-Jan-2010', 'sha1', 'cu1', 'b2', '', 'onsh1', 3, 'shM1');		
insert into Orderr values	('ord20', '10-Jan-2009', '12-Jan-2009', '10-Jan-2009', 'sha20', 'cu20', 'b23', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord21', '10-Jan-2009', '12-Jan-2009', '10-Jan-2009', '', 'cu21', 'b23', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord22', '11-Jan-2009', '12-Jan-2009', '10-Jan-2009', '', 'cu22', 'b23', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord23', '11-Jan-2009', '12-Jan-2009', '12-Jan-2009', '', 'cu23', 'b23', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord24', '11-Jan-2009', '12-Jan-2009', '12-Jan-2009', '', 'cu24', 'b24', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord25', '21-Jan-2009', '22-Jan-2009', '22-Jan-2009', '', 'cu25', 'b24', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord26', '21-Jan-2009', '22-Jan-2009', '22-Jan-2009', '', 'cu26', 'b24', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord27', '29-Jan-2009', '30-Jan-2009', '30-Jan-2009', '', 'cu27', 'b23', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord28', '29-Jan-2009', '30-Jan-2009', '30-Jan-2009', '', 'cu28', 'b25', '', 'onsh1', 1, 'shM1');		
insert into Orderr values	('ord29', '29-Jan-2009', '30-Jan-2009', '30-Jan-2009', '', 'cu29', 'b25', '', 'onsh1', 2, 'shM1');		
insert into Orderr values	('ord30', '30-Jan-2009', '2-Feb-2009', '1-Feb-2009', '', 'cu30', 'b25', '', 'onsh1', 2, 'shM1');		
insert into Orderr values	('ord31', '30-Jan-2009', '2-Feb-2009', '2-Feb-2009', '', 'cu31', 'b23', '', 'onsh1', 2, 'shM1');		


insert into Returned_product values	('t1', 'ord1', '11-Nov-2011',2);

insert into Monthly_Sale values	(2009,1, 'ord20',100,60);
insert into Monthly_Sale values	(2009,2, 'ord21',200,60);
insert into Monthly_Sale values	(2009,2, 'ord31',300,120);
insert into Monthly_Sale values	(2010,1, 'ord1',100,100);
insert into Monthly_Sale values	(2010,2, 'ord1',200,150);

--tworzenie sekwencji

CREATE SEQUENCE seq_produkt 
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

CREATE SEQUENCE seq_typ_produktu
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

CREATE SEQUENCE seq_zamowienie 
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

CREATE SEQUENCE seq_klient
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

CREATE SEQUENCE seq_pracownik
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

CREATE SEQUENCE seq_adres 
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

CREATE SEQUENCE seq_rachunek_naglowek
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

CREATE SEQUENCE seq_rachunek_detale
increment by 1  start with 1 
maxvalue 9999999999 minvalue 1 cache 20;

--tworzenie tabel

CREATE TABLE bd_Produkt (
    nr_produktu NUMBER(4) NOT NULL,
    nazwa VARCHAR2(20) NOT NULL,
    cena NUMBER(4) NOT NULL,
    nr_typu NUMBER(4) NOT NULL,
    CONSTRAINT Produkt_PK PRIMARY KEY(nr_produktu)
);


CREATE TABLE bd_Typ_produktu(
    nr_typu NUMBER(4)  NOT NULL,
    nazwa VARCHAR2(20)  NOT NULL,
    CONSTRAINT Typ_produktu_PK PRIMARY KEY (nr_typu)
);


CREATE TABLE bd_Zamowienie(
    nr_zamowienia NUMBER(4)  NOT NULL,
    data_zamowienia date  NOT NULL,
    status VARCHAR2(20)  NOT NULL,
    nr_pracownika NUMBER(3) NOT NULL,
    nr_klienta NUMBER(4) NOT NULL,
    CONSTRAINT Zamowienie_PK PRIMARY KEY (nr_zamowienia)
);

CREATE TABLE bd_produkt_zamowienie(
    nr_produktu NUMBER(4)  NOT NULL,
    nr_zamowienia NUMBER(4)  NOT NULL,
    ilosc NUMBER(2)  NOT NULL,
    CONSTRAINT produkt_zamowienie_PK PRIMARY KEY (nr_produktu,nr_zamowienia)
);


CREATE TABLE bd_Klient(
    nr_klienta NUMBER(4)  NOT NULL,
    imie VARCHAR2(20)  NOT NULL,
    nazwisko VARCHAR2(20)  NOT NULL,
    email VARCHAR2(20)  NOT NULL,
    id_adresu NUMBER(4) NOT NULL,
    CONSTRAINT Klient_PK PRIMARY KEY (nr_klienta)
);

CREATE TABLE bd_Pracownik(
    nr_pracownika NUMBER(3)  NOT NULL,
    pensja NUMBER(4) NOT NULL,
    data_zatrudnienia date  NOT NULL,
    CONSTRAINT Pracownik_PK PRIMARY KEY (nr_pracownika)
);

CREATE TABLE bd_Adres(
    id_adresu NUMBER(4)  NOT NULL,
    miasto VARCHAR(20) NOT NULL,
    ulica VARCHAR(20)  NOT NULL,
    nr_budynku NUMBER(3)  NOT NULL,
    nr_mieszkania NUMBER(3)  NULL,
    wojewodztwo VARCHAR(20) NOT NULL,
    CONSTRAINT Adres_PK PRIMARY KEY (id_adresu)
);


CREATE TABLE bd_rachunek_naglowek(
    nr_rachunku NUMBER(4) NOT NULL,
    wartosc NUMBER(5) NOT NULL,
    data_wystawienia date NOT NULL,
    nr_klienta NUMBER(4) NOT NULL,
    CONSTRAINT Rachunek_naglowke_PK PRIMARY KEY (nr_rachunku)
);

        
CREATE TABLE bd_rachunek_detale(
    poz_rachunku NUMBER(4) NOT NULL,
    ilosc NUMBER(3) NOT NULL,
    cena NUMBER(5) NOT NULL,
    nr_rachunku NUMBER(4) NOT NULL,
    nr_produktu NUMBER(4) NOT NULL,
    CONSTRAINT Rachunek_detale_PK PRIMARY KEY(poz_rachunku, nr_rachunku)
);


--dodawanie kluczy obcych

ALTER TABLE bd_Produkt ADD CONSTRAINT Produkt_Typ_produktu_FK
    FOREIGN KEY ( nr_typu )
    REFERENCES bd_Typ_produktu ( nr_typu );

ALTER TABLE bd_Zamowienie ADD CONSTRAINT Zamowienie_Klient_FK
    FOREIGN KEY ( nr_klienta )
    REFERENCES bd_Klient ( nr_klienta );

ALTER TABLE bd_Zamowienie ADD CONSTRAINT Zamowienie_Pracownik_FK
    FOREIGN KEY ( nr_pracownika )
    REFERENCES bd_Pracownik ( nr_pracownika );
    
ALTER TABLE bd_produkt_zamowienie ADD CONSTRAINT produkt_zamowienie_Produkt_FK
    FOREIGN KEY ( nr_produktu )
    REFERENCES bd_Produkt ( nr_produktu );

ALTER TABLE bd_produkt_zamowienie ADD CONSTRAINT produkt_zamowienie_Zamowienie_FK
    FOREIGN KEY ( nr_zamowienia )
    REFERENCES bd_Zamowienie ( nr_zamowienia );

ALTER TABLE bd_Klient ADD CONSTRAINT Klient_Adres_FK
    FOREIGN KEY ( id_adresu )
    REFERENCES bd_Adres ( id_adresu );
    
ALTER TABLE bd_Rachunek_naglowek ADD CONSTRAINT Rachunek_naglowek_Klient_FK
    FOREIGN KEY ( nr_klienta )
    REFERENCES bd_Klient ( nr_klienta );
    
ALTER TABLE bd_Rachunek_detale ADD CONSTRAINT Rachunek_detale_Rachunek_naglowek_FK
    FOREIGN KEY ( nr_rachunku )
    REFERENCES bd_Rachunek_naglowek ( nr_rachunku );
    
ALTER TABLE bd_Rachunek_detale ADD CONSTRAINT Rachunek_naglowek_Produkt_FK
    FOREIGN KEY ( nr_produktu )
    REFERENCES bd_Produkt ( nr_produktu );
    
--tworzenie perspektyw


CREATE OR REPLACE VIEW miesieczny_obrot as
select to_char(data_wystawienia, 'YYYY/MM') data,
to_char(to_date(extract(month from(data_wystawienia)), 'MM'), 'month') Miesiac,
sum(wartosc) Suma
from bd_Rachunek_naglowek
group by extract(month from(data_wystawienia)), to_char(data_wystawienia, 'YYYY/MM')
order by extract(month from(data_wystawienia))
;


CREATE OR REPLACE VIEW historia_sprzedazy as
select  bd_Rachunek_naglowek.nr_rachunku, imie, nazwisko,  wartosc
from bd_Rachunek_naglowek, bd_Klient, bd_Rachunek_detale
where bd_Rachunek_detale.nr_rachunku = bd_Rachunek_naglowek.nr_rachunku 
and bd_Rachunek_naglowek.nr_klienta = bd_Klient.nr_klienta
;


CREATE OR REPLACE VIEW najpopularniejszy_typ as
select bd_Typ_produktu.nr_typu, bd_Typ_produktu.nazwa,
SUM(bd_produkt_zamowienie.ilosc) as ilosc_sprzedanych_sztuk 
from bd_Typ_produktu, bd_produkt_zamowienie, bd_Zamowienie, bd_Produkt
where bd_produkt_zamowienie.nr_zamowienia =bd_Zamowienie.nr_zamowienia 
and bd_produkt_zamowienie.nr_produktu=bd_Produkt.nr_produktu
and bd_Produkt.nr_typu = bd_Typ_produktu.nr_typu 
group by bd_Typ_produktu.nazwa, bd_Typ_produktu.nr_typu
order by ilosc_sprzedanych_sztuk DESC
;


CREATE OR REPLACE VIEW oferta as
select bd_Produkt.nazwa, bd_Typ_produktu.nazwa nazwa_typu, bd_Produkt.cena
from bd_Produkt, bd_Typ_produktu
where bd_Produkt.nr_typu = bd_Typ_produktu.nr_typu
;

--roczna sprzedaz poszczegolnych produktow
CREATE OR REPLACE VIEW roczna_sprzedaz as
select bd_Produkt.nazwa, extract(year from(data_wystawienia)) Rok,
sum(wartosc) Suma
from bd_Produkt, bd_Rachunek_naglowek, bd_Rachunek_detale
where bd_Rachunek_detale.nr_produktu = bd_Produkt.nr_produktu
and bd_Rachunek_detale.nr_rachunku = bd_Rachunek_naglowek.nr_rachunku 
group by bd_Produkt.nazwa, extract(year from(data_wystawienia))
order by Suma DESC
;


--ktory klient wydal w sklepie najwiecej pieniedzy
CREATE OR REPLACE VIEW najlepszy_klient as
select imie ||' '|| nazwisko as "Imie i nazwisko", sum(wartosc) Wydane_pieniadze
from bd_Klient, bd_Rachunek_naglowek
where bd_Rachunek_naglowek.nr_klienta = bd_Klient.nr_klienta
group by imie ||' '|| nazwisko
order by Wydane_pieniadze DESC
;

--z ktorego wojewodztwa pochodzi najwiecej zamowien
CREATE OR REPLACE VIEW wojewodztwa as
select wojewodztwo, COUNT (*) ilosc_zamowien
from bd_Adres, bd_Klient, bd_Zamowienie
where bd_Zamowienie.nr_klienta = bd_Klient.nr_klienta
and bd_Klient.id_adresu = bd_Adres.id_adresu
group by wojewodztwo
order by ilosc_zamowien DESC
;

--dodawanie danych

--produkty
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'skrzypce', 5000, 1);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'altowka', 5050, 1);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'wiolonczela', 7000, 1);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'kontrabas', 9000, 1);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'felt', 3000, 2);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'klarnet', 4500, 2);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'oboj', 6400, 2);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'gitara', 1100, 3);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'gitara elektryczna', 2600, 3);
INSERT INTO bd_Produkt 
VALUES(seq_produkt.nextval, 'mandolina', 850, 3);

--typ produktu
INSERT INTO bd_Typ_produktu 
VALUES(seq_typ_produktu.nextval,'smyczkowe');
INSERT INTO bd_Typ_produktu 
VALUES(seq_typ_produktu.nextval,'dete drewniane');
INSERT INTO bd_Typ_produktu 
VALUES(seq_typ_produktu.nextval,'strunowe');

--klient
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Jan', 'Kowalski', 'jkowalski@onet.pl',1);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Anna', 'Kowalska', 'akowalski@onet.pl',1);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Adam', 'Nowak', 'anowak@gmail.com',2);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Aleksandra', 'Wojcik', 'olkaw@gmail.com',3);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Marta', 'Markowicz', 'm@student.wat.edu.pl',4);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Malgorzata', 'Pekala', 'gosiapekala@wp.pl',5);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Olga', 'Ostasz', 'olgaosti@onet.pl',6);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Jakub', 'Koziarz', 'jakubkoziz@gmail.com',7);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Aleksander', 'Drzymala', 'olekdrzymala@onet.pl',8);
INSERT INTO bd_Klient
VALUES(seq_klient.nextval, 'Kinga', 'Dudiarz', 'kdud@wp.pl',9);

--pracownik
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 5000, '2019-01-03');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 3000, '2020-02-03');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 3500, '2020-03-20');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 2500, '2021-12-01');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 4000, '2021-06-20');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 4500, '2021-04-15');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 5000, '2018-07-01');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 3200, '2021-07-29');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 5500, '2018-03-29');
INSERT INTO bd_Pracownik
VALUES(seq_pracownik.nextval, 3100, '2021-11-29');

--adresy
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'warszawa', 'warszawska', 10, 2, 'mazowieckie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'kielce', 'kielecka', 21, 8, 'swietokrzyskie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'rzeszow', 'jalowego', 22, 17, 'podkarpackie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'stalowa wola', 'popieluszki', 5, 6, 'podkarpackie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'krakow', 'krakowska', 11, 28, 'malopolskie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'zakopane', 'zakopianska', 1, 2, 'malopolskie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'warszawa', 'marszalkowska', 14, 72, 'mazowieckie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'gdansk', 'fajna', 27, 32, 'pomorskie');
INSERT INTO bd_Adres
VALUES(seq_adres.nextval, 'wroclaw', 'ladna', 11, 22, 'dolnoslaskie');

--zamowienia
INSERT INTO bd_Zamowienie
VALUES(seq_zamowienie.nextval, '2021-12-11', 'wyslane', 1, 1);
INSERT INTO bd_Zamowienie
VALUES(seq_zamowienie.nextval, '2021-11-01', 'zrealizowane', 2, 2);
INSERT INTO bd_Zamowienie
VALUES(seq_zamowienie.nextval, '2022-01-03', 'w realizacji', 3, 3);
INSERT INTO bd_Zamowienie
VALUES(seq_zamowienie.nextval, '2022-01-11', 'wyslane', 1, 4);
INSERT INTO bd_Zamowienie
VALUES(seq_zamowienie.nextval, '2021-10-10', 'zrealizowane', 4, 4);

--produkt_zamowienie
INSERT INTO bd_produkt_zamowienie
VALUES(1,1,1);
INSERT INTO bd_produkt_zamowienie
VALUES(2,2,2);
INSERT INTO bd_produkt_zamowienie
VALUES(3,3,1);
INSERT INTO bd_produkt_zamowienie
VALUES(4,4,1);
INSERT INTO bd_produkt_zamowienie
VALUES(5,5,1);

INSERT INTO bd_Rachunek_naglowek
VALUES(seq_rachunek_naglowek.nextval, 5000, '2021-12-11', 1); 
INSERT INTO bd_Rachunek_naglowek
VALUES(seq_rachunek_naglowek.nextval, 10100, '2021-11-01', 2); 
INSERT INTO bd_Rachunek_naglowek
VALUES(seq_rachunek_naglowek.nextval, 7000, '2022-01-03', 3); 
INSERT INTO bd_Rachunek_naglowek
VALUES(seq_rachunek_naglowek.nextval, 9000, '2022-01-11', 4); 
INSERT INTO bd_Rachunek_naglowek
VALUES(seq_rachunek_naglowek.nextval, 3000, '2021-10-10', 4); 

INSERT INTO bd_Rachunek_detale
VALUES(seq_rachunek_detale.nextval, 1, 5000, 1, 1); 
INSERT INTO bd_Rachunek_detale
VALUES(seq_rachunek_detale.nextval, 2, 5050, 2, 2); 
INSERT INTO bd_Rachunek_detale
VALUES(seq_rachunek_detale.nextval, 1, 7000, 3, 3); 
INSERT INTO bd_Rachunek_detale
VALUES(seq_rachunek_detale.nextval, 1, 9000, 4, 4); 
INSERT INTO bd_Rachunek_detale
VALUES(seq_rachunek_detale.nextval, 1, 3000, 5, 5); 
Skrypt usuwający:

-- usuwanie tabel
DROP TABLE bd_Adres CASCADE CONSTRAINTS;
DROP TABLE bd_Klient CASCADE CONSTRAINTS;
DROP TABLE bd_Pracownik CASCADE CONSTRAINTS;
DROP TABLE bd_Produkt CASCADE CONSTRAINTS;
DROP TABLE bd_produkt_zamowienie CASCADE CONSTRAINTS;
DROP TABLE bd_Typ_produktu CASCADE CONSTRAINTS;
DROP TABLE bd_Zamowienie CASCADE CONSTRAINTS;
DROP TABLE bd_Rachunek_detale CASCADE CONSTRAINTS;
DROP TABLE bd_Rachunek_naglowek CASCADE CONSTRAINTS;

--usuwanie sekwencji
DROP SEQUENCE seq_produkt;
DROP SEQUENCE seq_typ_produktu;
DROP SEQUENCE seq_zamowienie;
DROP SEQUENCE seq_klient;
DROP SEQUENCE seq_pracownik;
DROP SEQUENCE seq_adres;
DROP SEQUENCE seq_rachunek_naglowek;
DROP SEQUENCE seq_rachunek_detale;

--usuwanie perspetyw

drop view historia_sprzedazy;
drop view miesieczny_obrot;
drop view najpopularniejszy_typ;
drop view oferta;
drop view roczna_sprzedaz;
drop view najlepszy_klient;
drop view wojewodztwa;

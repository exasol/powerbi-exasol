CREATE SCHEMA TEST;
CREATE SCHEMA MORETESTS;
CREATE TABLE MORETESTS.MORETYPES (
	"varchar" VARCHAR(50),
	"longvarchar" LONG VARCHAR,
	"geometry" GEOMETRY(2000),
	"boolean" BOOLEAN,
	"char" CHAR(50),
	"date" DATE,
	"decimal" DECIMAL(24,2),
	"decimalwith0precision" DECIMAL(24,0),
	"doubleprecision" DOUBLE PRECISION,
	"float" FLOAT,
	"integer" INTEGER,
	"tinyint" TINYINT,
	"smallint" SMALLINT,
	"bigint" BIGINT,
	"intervaldaytosecond" INTERVAL DAY TO SECOND,
	"intervalyeartomonth" INTERVAL YEAR TO MONTH,
	"timestamp" TIMESTAMP,
	"timestampwithlocaltimezone" TIMESTAMP WITH LOCAL TIME ZONE,
	"hashtype" HASHTYPE(8192 BIT)
);

CREATE TABLE MORETESTS.TEXTCONVERSION (
"rowname" VARCHAR(100),
"varchar" VARCHAR(100),
"longvarchar" LONG VARCHAR,
"char" CHAR(100)
);

INSERT INTO MORETESTS.TEXTCONVERSION
("rowname", "varchar", "longvarchar", "char")
VALUES('vero','Véroniquë ç''est unne fémme uniquë', 'Véroniquë ç''est unne fémme uniquë', 'Véroniquë ç''est unne fémme uniquë');

INSERT INTO MORETESTS.TEXTCONVERSION
("rowname", "varchar", "longvarchar", "char")
VALUES('8balls','❽❽❽❽❽', '❽❽❽❽❽', '❽❽❽❽❽');

INSERT INTO MORETESTS.TEXTCONVERSION
("rowname", "varchar", "longvarchar", "char")
VALUES('umlauts','ÖÜÄ', 'ÖÜÄ', 'ÖÜÄ');

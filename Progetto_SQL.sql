-- NON SAPENDO COME CARICARE IL TUTTO, CARICO TUTTE LE QUERY IN QUESTO SCRIPT METTENDO LE DESCRIZIONI

-- TASK 2
CREATE DATABASE IF NOT EXISTS ToysGroup;

USE ToysGroup;

-- CATEGORY TABLE
CREATE Table Category (
CategoryID INT NOT NULL AUTO_INCREMENT
, Category VARCHAR(50) NOT NULL
, PRIMARY KEY (CategoryID)
);

-- SALES REGION TABLE
CREATE Table SalesRegion (
RegionID INT NOT NULL AUTO_INCREMENT
, Region VARCHAR(50) NOT NULL
, PRIMARY KEY (RegionID)
);

-- PRODUTCT TABLE
CREATE Table Product (
ProductID INT NOT NULL AUTO_INCREMENT
,ProductName VARCHAR(50) NOT NULL
, CategoryID INT NOT NULL
, PRIMARY KEY (ProductID)
, CONSTRAINT FK_Product_Category
  FOREIGN KEY (CategoryID)
  REFERENCES Category(CategoryID)
  ON UPDATE Cascade
  ON DELETE Restrict
);
  
-- STATE TABLE
CREATE TABLE State (
StateID INT NOT NULL AUTO_INCREMENT
,State   VARCHAR(100) NOT NULL
,RegionID INT NOT NULL
, PRIMARY KEY (StateID)
, CONSTRAINT FK_State_SalesRegion
   FOREIGN KEY (RegionID)
   REFERENCES SalesRegion(RegionID)
   ON UPDATE Cascade
   ON DELETE Restrict
);
   
-- SALES TABLE
CREATE TABLE Sales (
OrderID   INT NOT NULL AUTO_INCREMENT
, OrderDate DATE NOT NULL
, Quantity  INT NOT NULL
, Amount    DECIMAL(10,2) NOT NULL
, ProductID INT NOT NULL
, StateID   INT NOT NULL
, PRIMARY KEY (OrderID)
, CONSTRAINT FK_Sales_Product
   FOREIGN KEY (ProductID)
   REFERENCES Product(ProductID)
   ON UPDATE Cascade
   ON DELETE Restrict
, CONSTRAINT FK_Sales_State
   FOREIGN KEY (StateID)
   REFERENCES State(StateID)
   ON UPDATE Cascade
   ON DELETE Restrict
);


-- TASK 3
USE ToysGroup;

-- CATEGORY
INSERT INTO Category (Category) VALUES
('Board Games')
, ('Educational Toys')
, ('LEGO')
;

-- SALES REGION
INSERT INTO salesregion (Region) VALUES
('Europe')
, ('America')
, ('Asia')
;

-- STATE, ipotizziamo che Europe 1, America 2 e Asia 3
INSERT INTO State (State, RegionID) VALUES
('Italy', 1)
, ('France', 1)
, ('USA', 2)
, ('Canada', 2)
, ('China', 3)
, ('Japan', 3)
;

-- PRODUCT, ipotizziamo che BoardGames 1, Educational Toys 2 e LEGO 3
INSERT INTO product (ProductName, CategoryID) VALUES
('Monopoly', 1)
, ('Exploding Kittens', 1)
, ('Science Kit', 2)
, ('Animal Picture Book', 2)
, ('StarWars', 3)
, ('Pokemon', 3)
, ('Harry Potter', 3)
;

-- SALES
INSERT INTO sales (OrderDate, Quantity, Amount, ProductID, StateID) VALUES
('2023-02-15', 2, 60.00, 1, 1)
, ('2023-08-10', 1, 35.00, 2, 2)
, ('2023-12-12', 3, 90.00, 3, 3)
, ('2024-01-15', 1, 25.00, 4, 4)
, ('2024-05-20', 2, 120.00, 5, 1)
, ('2024-10-05', 4, 160.00, 6, 2)
, ('2025-01-06', 1, 45.00, 1, 3)
, ('2025-05-05', 5, 150.00, 2, 4)
, ('2025-08-14', 2, 80.00, 5, 5)
, ('2025-10-10', 3, 120.00, 6, 6)
, ('2025-12-18', 1, 60.00, 5, 1)
;

-- TASK 4 PUNTO 1

-- CATEGORY
select CategoryID, count(CategoryID) AS Count_Category 
from category
group by CategoryID
having count(CategoryID) > 1
;

-- SALES REGION
select RegionID, count(RegionID) AS Count_Region
from salesregion
group by RegionID
having count(RegionID) > 1
;

-- STATE
select StateID, count(StateID) AS Count_State
from state
group by StateID
having count(StateID) > 1
;

-- PRODUCT
select ProductID, count(ProductID) AS Count_Product
from product
group by ProductID
having count(ProductID) > 1
;

-- SALES
select OrderID, count(OrderID) AS Count_Order
from sales
group by OrderID
having count(OrderID) > 1
;

-- Il ragionamento dietro questa query è che una PK deve essere univoca senza duplicati;
-- Quindi mettendo il filtro having count(*)>1 dovrebbe restituirmi le righe dove la PK si ripete più di 1 una volta; count(*) per dire count(PK) di quella tabella;
-- Invece i risultati sono empty set, quindi PK esiste e univoca;


-- TASK 4 PUNTO 2

SELECT
s.OrderID AS DocumentCode
, s.OrderDate
, p.ProductName
, c.Category
, st.State
, r.Region

, CASE
 WHEN DATEDIFF(
		(SELECT MAX(OrderDate) FROM Sales),
		s.OrderDate
         ) > 180
THEN TRUE
ELSE FALSE
END AS '>180Days'
FROM Sales AS s

JOIN Product AS p     
ON s.ProductID = p.ProductID

JOIN Category AS c    
ON p.CategoryID = c.CategoryID
JOIN State AS st      
ON s.StateID = st.StateID
JOIN SalesRegion AS r 
ON st.RegionID = r.RegionID

ORDER BY s.OrderDate, s.OrderID
;

-- CASE per creare una logica condizionale come if else;
-- Calcolato prima i giorni trascorsi tra la data più recente presente e la data della singola vendita, dove se diff >180 allora True;
-- Usato poi le INNER JOIN per collegare ogni vendita al prodotto venduto, risalire alla cateogoria del prodotto, sapere in quale stato è stato venduto e avere poi di conseguenza la regione alla quale appartiene lo stato;
-- ORDER BY per avere ordinamento cronologico;

-- TASK 4 PUNTO 3

SELECT
p.ProductID
, SUM(s.Quantity) AS TotalSold
FROM Product AS p

JOIN Sales AS s
ON s.ProductID = p.ProductID

GROUP BY p.ProductID
HAVING SUM(s.Quantity) >
(
  SELECT AVG(quantity_product) 
  FROM (
    SELECT
      s2.ProductID,
      SUM(s2.Quantity) AS quantity_product
    FROM Sales AS s2
    WHERE YEAR(s2.OrderDate) = (SELECT MAX(YEAR(OrderDate)) FROM Sales)
    GROUP BY s2.ProductID
  ) AS t
)
;

-- QUERY + COMPLESSA DELLA TASK 4:
-- Calcolato prima il Total Sold, cioè la quantità venduta per prodotto su tutte le vendite presenti, ottenendo solo risultati maggiori della media;
-- Dentro l'HAVING calcolo l'ultimo anno censito, quindi 2025. Poi calcolo tot per quell'anno, poi media di questi totali - quindi media delle quantità totali per prodotto nell'ultimo anno.

-- TASK 4 PUNTO 4

SELECT
YEAR(s.OrderDate) AS SalesYear
, p.ProductID
, p.ProductName
, SUM(s.Amount) AS TotalRevenue
FROM Sales AS s

JOIN Product AS p
ON s.ProductID = p.ProductID

GROUP BY
YEAR(s.OrderDate)
, p.ProductID
, p.ProductName
ORDER BY
SalesYear ASC
, TotalRevenue DESC
;

-- Built-in function YEAR per raggruppare per anno;
-- JOIN Sales e Product per avere solo i prodotti che hanno almeno una vendita;
-- SUM per avere poi il fatturato totale;
-- GROUP BY con il prodotto per avere la coppia prodotto e anno + tot fatturato;
-- Messo poi ORDER BY in base alla consegna, quindi ASC per anno di vendita e DESC per il tot fatturato.


-- TASK 4 PUNTO 5

SELECT
YEAR(s.OrderDate) AS SalesYear
, st.State
, SUM(s.Amount) AS TotalRevenue
FROM Sales AS s

JOIN State AS st
ON s.StateID = st.StateID

GROUP BY
YEAR(s.OrderDate)
, st.State
ORDER BY
SalesYear
, TotalRevenue DESC
;

-- Estratto prima anno con built-in function YEAR;
-- JOIN per unire Sales con State;
-- SUM per avere il totale vendite per ciascun gruppo;
-- GROUP BY con YEAR per avere un'unica riga con la coppia Anno e Stato + totale;
-- ORDER BY in ordinde decrescente con DESC.


-- TASK 4 PUNTO 6

SELECT
c.Category
, SUM(s.Quantity) AS TotalUnitsSold
FROM Sales AS s

JOIN Product AS p  
ON s.ProductID = p.ProductID

JOIN Category AS c 
ON p.CategoryID = c.CategoryID

GROUP BY c.Category
ORDER BY TotalUnitsSold DESC
LIMIT 1
;

-- JOIN delle tabelle prodotto e categoria da Sales;
-- Fatta un aggregazione con SUM per avere tutte le quantità vendute per categoria;
-- GROUP BY per avere una riga per ogni categoria con il numero unità tot vendute;
-- ORDER BY per avere ordine Decrescente con DESC;
-- LIMIT 1 per avere solo 1 risultato - visto su internet il LIMIT.


-- TASK 4 PUNTO 7

SELECT
p.ProductID
, p.ProductName
FROM Product AS p

LEFT JOIN Sales AS s
ON s.ProductID = p.ProductID
WHERE s.ProductID IS NULL;

SELECT
p.ProductID
, p.ProductName
FROM Product AS p
WHERE NOT EXISTS (
SELECT 1
FROM Sales AS s
WHERE s.ProductID = p.ProductID
)
;

-- APPROCCIO 1: LEFT JOIN per vedere eventuali vendite + IS NULL per avere proprio quelli invenduti;
-- APPROCCIO 2: NOT EXIST con la subquery, dove per ogni prodotto controlla se esiste una vendita e con NOT EXIST seleziona solo quelli che non compaiono in SALES.


-- TASK 4 PUNTO 8

CREATE OR REPLACE VIEW Product_List AS
SELECT 
p.ProductID
, p.ProductName
, c.Category
FROM Product  AS p

JOIN Category AS c
ON p.CategoryID = c.CategoryID
;

SELECT * 
FROM Product_List;

-- Creo view usando CREATE OR REPLACE (replace in caso esistessero già altre - bestpractice;
-- Nella Select metto i campi richiesti dalla consegna;
-- Faccio JOIN tra Product e Category, in quanto ogni prodotto appartiene a una sola categoria e la Join elimina la normalizzazione;


-- TASK 4 PUNTO 9

CREATE OR REPLACE VIEW Geography AS
SELECT
r.Region
, st.State
, COALESCE(SUM(s.Amount), 0) AS TotalAmount
FROM State AS st

JOIN SalesRegion AS r
ON st.RegionID = r.RegionID

LEFT JOIN Sales AS s
ON s.StateID = st.StateID

GROUP BY
r.Region
,st.State
;

SELECT *
FROM geography

-- Ho creato prima una vista chiamata Geography (messo OR REPLACE perhcè mi diceva esisteva già);
-- Messo poi nel SELECT la sum come da consegna + COALESCE in maniera tale che se uno stato non ha vendite, anzichè null esce 0;
-- Usata prima JOIN in quanto ogni stato appartiene ad una sola regione;
-- Fatto poi LEFT JOIN per avere anche gli stati senza senza vendite;
-- GROUP BY finale per avere una riga per ogni coppia Regione-Stato + total amount.
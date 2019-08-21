--LABORATORIO 01-
--1.1. Accediendo a la base de datos TSQL

use TSQL;

--1.2. Write a SELECT statement to return the productid, productname, supplierid, unitprice, and\r\ndiscontinued columns from the Production.Products table. Filter the results to include only products\r\nthat belong to the category Beverages (categoryid equals 1)",

DECLARE @beveragesid INT = 1;
SELECT productid,productname,supplierid,unitprice 
FROM Production.Products WHERE categoryid=@beveragesid

--1.3. Modify the T-SQL code to include the following supplied T-SQL statement. Put this statement before\r\nthe SELECT clause:

CREATE VIEW Production.ProductsBeverages AS select productid,productname,supplierid,unitprice from Production.Products where categoryid=1


--1.4. Write a SELECT statement to return the productid and productname columns from the\r\nProduction.ProductsBeverages view. Filter the results to include only products where supplierid equals\r\n1

DECLARE @supplierid INT = 1; SELECT productid,productname FROM Production.ProductsBeverages WHERE supplierid =@supplierid


--1.5. The IT department has written a T-SQL statement that adds an additional calculated column to the

ALTER VIEW Production.ProductsBeverages AS SELECT productid, productname, supplierid, unitprice, discontinued,
CASE WHEN unitprice > 100. THEN N'high' ELSE N'normal' END as pricetype
FROM Production.Products 
WHERE categoryid = 1;

--1.6. Apply the changes needed to get the T-SQL statement to execute properly


ALTER VIEW Production.ProductsBeverages AS SELECT productid, productname, supplierid, unitprice, discontinued,
CASE WHEN unitprice > 100. THEN N'high' ELSE N'normal' END as pricetype 
FROM Production.Products 
WHERE categoryid = 1;

--2.1. Write a SELECT statement against a derived

SELECT 
    p.productid,productname
FROM
    (
        SELECT 
            productid,productname,supplierid,unitprice,discontinued,
            CASE WHEN unitprice > 100. THEN N'high' ElSE N'normal' END AS pricetype
        FROM Production.Products
        WHERE categoryid=1
    )AS P
WHERE p.pricetype=N'high';


--2.2. Write a SELECT statement to retrieve the custid column and two calculated columns: totalsalesamount, which returns the total sales amount per customer, and avgsalesamount, which returns the average sales amount of orders per customer. To correctly calculate the average sales amount of orders per customer, you should first calculate the total sales amount per order. You can do so by defining a derived table based on a query that joins the Sales.Orders and Sales.OrderDetails tables. You can use the custid and orderid columns from the Sales.Orders table and the qty and unitprice columns from the Sales.OrderDetails table

select 
    c.custid,
    sum(c.totalsalesmountperorder) AS totalsalesmount,
    AVG(c.totalsalesmountperorder) AS avgsalesmount
FROM
    (
        SELECT
            o.custid,o.orderid, SUM(d.unitprice*d.qty) as totalsalesmountperorder
        FROM Sales.Orders as o
        inner join Sales.OrderDetails d on d.orderid=o.orderid
        Group by o.custid,o.orderid
    ) AS c
    GROUP BY c.custid;

--3.1. Write a SELECT statement like the one in exercise 2.1, but use a CTE instead of a derived table. Use inline column aliasing in the CTE query and name the CTE ProductBeverages.


WITH ProductsBeverages AS
(
    select 
        productid,productname,supplierid,unitprice,discontinued,
        case WHEN unitprice > 100. THEN N'high' ELSE N'normal' END AS pricetype
    FROM Production.Products
    WHERE categoryid=1
)
select productid,productname
FROM ProductsBeverages
WHERE pricetype=N'high'

--3.2. Write a SELECT statement against Sales.OrderValues to retrieve each customer’s ID and total sales amount for the year 2008. Define a CTE named c2008 based on this query, using the external aliasing form to name the CTE columns custid and salesamt2008. Join the Sales.Customers table and the c2008 CTE, returning the custid and contactname columns from the Sales.Customers table and the salesamt2008 column from the c2008 CTE.

WITH c2008 (custid,salesamt2008) as
(
    SELECT  
        custid,sum(val)
        FROM Sales.OrderValues
        WHERE YEAR(orderdate)=2008
        GROUP by custid
)
select 
    c.custid,c.contactname,c2008.salesamt2008
FROM Sales.Customers AS c
LEFT OUTER JOIN c2008 ON c.custid=c2008.custid;


--4.1. Write a SELECT statement against the Sales.OrderValues view and retrieve the custid and totalsalesamount columns as a total of the val column. Filter the results to include orders only for the year 2007.


select 
    custid,SUM(val) as totalsalesmount
FROM Sales.OrderValues
where year(orderdate)=2007
group by custid;
go

--4.2. Define an inline TVF using the following function header and add your previous query after the RETURN clause: Modify the query by replacing the constant year value 2007 in the WHERE clause with the parameter @orderyear


CREATE FUNCTION dbo.fnGetSalesByCustomer
(@orderyear AS INT) RETURNS TABLE
AS
RETURN
    select custid,SUM(val) as totalsalesmount
FROM Sales.OrderValues
where year(orderdate)=@orderyear
group by custid;
go


--4.3. Write a SELECT statement that retrieves the top three sold products based on the total sales value for the customer with ID 1. Return the productid and productname columns from the Production.Products table. Use the qty and unitprice columns from the Sales.OrderDetails table to compute each order line’s value, and return the sum of all values per product, naming the resulting column totalsalesamount. Filter the results to include only the rows where the custid value is equal to 1.

SELECT TOP(3)
    d.productid,
    MAX(p.productname) AS productname,
    SUM(d.qty*d.unitprice) AS totalsalesmount
FROM Sales.Orders AS o
inner join Sales.OrderDetails AS d on d.orderid=o.orderid
inner join Production.Products AS p on p.productid=d.productid
WHERE custid=1
GROUP BY d.productid
order by totalsalesmount DESC;
go


--4.4. Create an inline TVF based on the following function header, using the previous SELECT statement. Replace the constant custid value 1 in the query with the function’s input parameter @custid:

CREATE FUNCTION dbo.fnGetTop3ProductsForCustomer
(@custid AS INT) RETURNS TABLE
AS
RETURN
SELECT TOP(3)
    d.productid,
    MAX(p.productname) AS productname,
    SUM(d.qty*d.unitprice) AS totalsalesmount
FROM Sales.Orders AS o
inner join Sales.OrderDetails AS d on d.orderid=o.orderid
inner join Production.Products AS p on p.productid=d.productid
WHERE custid=@custid
GROUP BY d.productid
order by totalsalesmount DESC;
go


--4.5. Test the created inline TVF by writing a SELECT statement against it and use the value 1 for the customer ID parameter. Retrieve the productid, productname, and totalsalesamount columns, and use the alias “p” for the inline TVF

SELECT 
p.productid,
p.productname,
p.totalsalesmount
from dbo.fnGetTop3ProductsForCustomer(5) as p


--4.6. Escribir el código necesario para limpiar todos los cambios realizados


DROP VIEW Production.ProductsBeverages;
GO
DROP FUNCTION dbo.fnGetSalesByCustomer;
GO
DROP FUNCTION dbo.fnGetTop3ProductsForCustomer;
GO
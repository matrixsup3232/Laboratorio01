USE TSQL;

CREATE VIEW HR.EmpPhoneList AS SELECT empid, lastname, firstname, phone FROM HR.Employees;
GO

SELECT empid, lastname, firstname, phone FROM HR.EmpPhoneList;
GO

CREATE VIEW Sales.OrdersByEmployeeYear AS SELECT emp.empid AS employee, YEAR(ord.orderdate) AS orderyear, SUM(od.qty * od.unitprice) AS totalsales FROM HR.Employees AS emp JOIN Sales.Orders AS ord ON emp.empid = ord.empid JOIN Sales.OrderDetails AS od ON ord.orderid = od.orderid GROUP BY emp.empid, YEAR(ord.orderdate)
GO

SELECT employee, orderyear, totalsales FROM Sales.OrdersByEmployeeYear ORDER BY employee, orderyear;

DROP VIEW Sales.OrdersByEmployeeYear; DROP VIEW HR.EmpPhoneList;

SELECT * FROM dbo.GetNums(10,20);
GO

CREATE FUNCTION Sales.fn_LineTotal ( @orderid INT ) RETURNS TABLE AS RETURN SELECT  orderid, productid, unitprice, qty, discount, CAST(( qty * unitprice * ( 1 - discount ) ) AS DECIMAL(8, 2)) AS line_total   FROM    Sales.OrderDetails   WHERE   orderid = @orderid ; 
GO

SELECT orderid, productid, unitprice, qty, discount, line_total FROM Sales.fn_LineTotal(10252) AS LT; 
GO

DROP FUNCTION Sales.fn_LineTotal;
GO

SELECT orderyear, COUNT(DISTINCT custid) AS cust_count FROM (SELECT YEAR(orderdate) AS orderyear, custid FROM Sales.Orders) AS derived_year GROUP BY orderyear;

DECLARE @emp_id INT = 9; SELECT orderyear, COUNT(DISTINCT custid) AS cust_count FROM (SELECT YEAR(orderdate) AS orderyear, custid FROM Sales.Orders WHERE empid=@emp_id) AS derived_year GROUP BY orderyear;

SELECT orderyear, cust_count FROM  (SELECT  orderyear, COUNT(DISTINCT custid) AS cust_count FROM (SELECT YEAR(orderdate) AS orderyear ,custid        FROM Sales.Orders) AS derived_table_1 GROUP BY orderyear) AS derived_table_2 WHERE cust_count > 80;

SELECT orderyear, COUNT(DISTINCT custid) AS cust_count FROM (SELECT YEAR(orderdate) AS orderyear ,custid   FROM Sales.Orders) AS derived_table_1 GROUP BY orderyear HAVING COUNT(DISTINCT custid) > 80;

WITH CTE_year AS (SELECT YEAR(orderdate) AS orderyear, custid FROM Sales.Orders) SELECT orderyear, COUNT(DISTINCT custid) AS cust_count FROM CTE_year GROUP BY orderyear;


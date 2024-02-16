-- Intern level:
--•  How would you write a SQL query to find the total number of customers in the NORDWND database?
select count(CustomerID)
from Customers;
--•  How would you write a SQL query to find the names and prices of the products in the Beverages category?
select ProductName, UnitPrice
from Products p join Categories c on p.CategoryID=c.CategoryID
where CategoryName='Beverages'
order by productname;
--• How would you write a SQL query to find the names and countries of the customers who have placed orders in 1997?
select distinct ContactName, Country
from Orders o join Customers c on o.CustomerID=c.CustomerID
where year(OrderDate)='1997';
--•  How would you write a SQL query to find the names and contact titles of the employees who report to Andrew Fuller?
select concat(lastname,' ', firstname) as Employee_reports_to_Fuller, Title
from Employees
where ReportsTo=(select EmployeeID from Employees where LastName='Fuller' and FirstName='Andrew')
select * from Employees;
GO

--Fresher level:

--•  How would you write a SQL query to find the total sales order for each product category in 1997?
select CategoryName, count(o.OrderID) as SaleAmount1997
from Orders  o join [Order Details] d  on o.OrderID=d.OrderID
left join Products p on d.ProductID=p.ProductID
left join Categories c on c.CategoryID=p.CategoryID
where year(OrderDate)=1997
group by CategoryName
order by SaleAmount1997 desc
;
--•  How would you write a SQL query to find the names and phone numbers of the suppliers who supply products to the UK?
select distinct  s.CompanyName as Supplier_UK, s.Phone
from Orders  o join [Order Details] d  on o.OrderID=d.OrderID
left join Products p on d.ProductID=p.ProductID
left join Suppliers s on p.SupplierID=s.SupplierID
where shipcountry='UK'
;
--•  How would you write a SQL query to find the most expensive product ordered by each customer in 1997?
select CustomerID, ProductID
from(
select distinct CustomerID, ProductID, unitprice, rank() over (partition by customerID order by unitprice desc) as therank
from Orders  o join [Order Details] d  on o.OrderID=d.OrderID
where year(OrderDate)=1997
) as cte
where therank=1
;
--•  How would you write a SQL query to find the average orders for each employee in each quarter of 1997?
with cte as (select  EmployeeID,orderID,
case 
	when  month(orderdate) in (1,2,3) then 'Q1'
	when  month(orderdate) in (4,5,6) then 'Q2'
	when  month(orderdate) in (7,8,9) then 'Q3'
	else 'Q4'
end as Quater1997
from Orders
where year(OrderDate)=1997
)
select  EmployeeID,Quater1997, count(orderID) as OrderAmount
from cte
group by EmployeeID,Quater1997
order by Quater1997, OrderAmount desc
GO

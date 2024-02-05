-- Các câu query dựa trên dataset là NORDWND
--Question 1/ Write a query to find the total sales amount and the average order amount for each salesperson in each year. 
-- Order the results by year, salesperson name, and total sales amount in descending order.

with cte as (select EmployeeID, year(requireddate) as the_year,round(sum (unitprice*quantity*(1-discount)),1) as TotalSale
from [NORTHWND].[dbo].[Orders] o join [NORTHWND].[dbo].[Order Details] d on o.OrderID=d.OrderID
group by EmployeeID, year(requireddate))

select concat(firstname, ' ', lastname) as FullName, the_year, totalsale
from [NORTHWND].[dbo].[Employees] e join cte on e.EmployeeID=cte.EmployeeID
order by the_year, totalsale desc

-- 🤓 Sửa và nhận xét code
-- Dùng chữ hoa chữ thường thống nhất

-- Q2: Write a query to find the top three products in each category based on the total revenue.
--Order the results by category_id, quantity, and product_name in descending order.
with a1 as (select ProductID, round(sum (unitprice*quantity*(1-discount)),1) as revenue
from NORTHWND. [dbo].[Order Details]
group by ProductID)
,
a2 as (select categoryid, a1.ProductID, revenue, dense_rank() over (partition by categoryid order by revenue desc) as the_row
from a1 join NORTHWND.[dbo].[Products] p on a1.ProductID=p.ProductID)

select a2.CategoryID, Productname, revenue
from a2 join NORTHWND.[dbo].[Products] p on a2.ProductID=p.ProductID
where the_row <4

-- 🤓 Sửa và nhận xét code
-- Dùng dense_rank chứ không dùng rank (vì nhiều sản phẩm cùng doanh thu, rank sẽ đánh cùng số thứ tự nhưng sẽ bị nhảy số cách do hay rownumber (vì có thể có nhiều sản phẩm có cùng doanh thu).

-- Q3: Write a query to find the percentage of orders that were placed by customers from each country. 
-- Round the percentage to two decimal places. Order the results by percentage in descending order.
with a as (select o.OrderID, country
from [NORTHWND].[dbo].[Orders] o join [NORTHWND].[dbo].[Order Details] d on o.OrderID=d.OrderID 
	join [NORTHWND].[dbo].[Customers] c on o.CustomerID=c.CustomerID)
,
b as (select distinct country as the_country, cast(count(orderid) over (partition by country) as decimal) as c1, 
cast (count(orderid) over () as decimal) as c2
from a)

select the_country, cast(c1*100/c2 as decimal(5,3)) as Percentage
from b
order by Percentage desc

-- 👻 Chú ý: phải cast cả tử và mẫu trước thì kết quả mới thành decimal. Cast kết quả không có tác dụng.
-- 🤓 Sửa và nhận xét code
-- Lạm dụng CTE và window function trong khi chỉ cần dùng count và sum bình thường. Tham khỏa đoạn code dưới đây:
WITH cte AS (
  SELECT 
    [Country], 
    COUNT(OrderID) AS [OrderCount]
  FROM [NORTHWND].[dbo].[Orders] AS o
  JOIN [NORTHWND].[dbo].[Customers] AS c
    ON o.[CustomerID] = c.[CustomerID]
  GROUP BY [Country]
)
SELECT 
  [Country], 
  ROUND([OrderCount] * 100.0 / (SELECT SUM([OrderCount]) FROM cte), 2) AS [Percentage]
FROM cte
ORDER BY [Percentage] DESC;

-- Q4: Write a query to find the monthly growth rate of sales for each category in each year. 
-- Calculate the monthly growth rate as the percentage change in sales from the previous month to the current month, using the formula: (current_month_sales - previous_month_sales) / previous_month_sales * 100. 
-- Round the growth rate to two decimal places. 

with cte as (select distinct year(OrderDate) as Year, month(OrderDate) as Month, CategoryName as Category, 
sum(d.UnitPrice*quantity*(1-discount)) over (partition by year(OrderDate), month(OrderDate), CategoryName) as MonthSale
from [dbo].[Orders] o 
join [dbo].[Order Details] d on o.OrderID=d.OrderID 
join [dbo].[Products] p on d.ProductID=p.ProductID 
join [dbo].[Categories] c on p.CategoryID=c.CategoryID)
select *, ROUND((MonthSale - LAG(MonthSale) OVER (partition by category, year ORDER BY month)) / LAG(MonthSale) OVER (partition by category,year ORDER BY month) * 100, 2) AS growth
from cte
order by category, year, month

-- Ghi chú: Tư duy theo cách sau để partition cho đúng: để lấy lag thì trước tiên ta phải xếp lại theo Category, trong Category ta phải xếp lại theo Year.
-- Không ngăn tiếp theo month vì nếu thế lấy gì mà lag. Trong ngăn Category và Year xác định thì phải sắp xếp theo tháng thì mới lấy lag đúng.


-- Q5: Write a query to find the most popular product in each month based on the number of orders.
with cte as (select distinct year(OrderDate) as Year, month(OrderDate) as Month, ProductName as Product
, count(o.OrderID) over (partition by year(OrderDate), month(OrderDate), productname) as Number_of_Order
from [dbo].[Orders] o 
join [dbo].[Order Details] d on o.OrderID=d.OrderID 
join [dbo].[Products] p on d.ProductID=p.ProductID )
,
cte2 as (select Year, Month, Product, Number_of_Order
, rank() over (partition by year, month order by Number_of_Order desc) as TheRank
from cte)
-- Dùng Rank thay vì Row_number vì có thể có nhiều sản phẩm có số order bằng nhau và là cao nhất.

select year, month, product as MostPopularProduct
from cte2
where TheRank=1;

-- 🤓 Sửa và nhận xét code
-- Tham khảo cách dùng index dưới đây

-- Create a column for the year and month of the order date
alter table [dbo].[Orders] add OrderYearMonth as year(OrderDate) * 100 + month(OrderDate);
-- => Cách này khá hay. Đã tiếp thu.

-- Create indexes on the relevant columns.
-- Indexes are used to retrieve data from the database more quickly than otherwise. 
--The users cannot see the indexes, they are just used to speed up searches/queries.
--Updating a table with indexes takes more time than updating a table without (because the indexes also need an update). 
--So, only create indexes on columns that will be frequently searched against.
create index idx_OrderYearMonth on [dbo].[Orders] (OrderYearMonth);
create index idx_ProductName on [dbo].[Products] (ProductName);
create index idx_OrderID on [dbo].[Order Details] (OrderID);

-- Use CTEs and window functions to find the most popular product for each month and year
with cte as (
select OrderYearMonth, ProductName as Product, count(o.OrderID) as Number_of_Order
from [dbo].[Orders] o 
join [dbo].[Order Details] d on o.OrderID=d.OrderID 
join [dbo].[Products] p on d.ProductID=p.ProductID 
group by OrderYearMonth, ProductName
),
cte2 as (
select OrderYearMonth, Product, Number_of_Order,
rank() over (partition by OrderYearMonth order by Number_of_Order desc) as TheRank
from cte
)

-- Select the most popular product(s) for each month and year
select OrderYearMonth / 100 as Year, OrderYearMonth % 100 as Month, Product as MostPopularProduct
-- Đoạn select này khá hay. Chú ý rằng nếu không lấy decimal thì SQL tự cho ra interger. 
-- Điều này là do quan sát chứ chưa chắc chắn.
from cte2
where TheRank=1
-- •  Which country has the most loyal customers, measured by the average number of orders per customer?
select Country, cast(count(orderID)as decimal)/cast(count(distinct o.CustomerID)as decimal) as loyal
from orders o join Customers c on o.CustomerID=c.CustomerID
group by country
order by loyal desc

-- Q6 Which supplier has the most reliable delivery time, measured by the average difference between the order date and the shipped date?
-- Trên thực tế, có thể sử dụng 3 metrics sau:
-- 1. On-time delivery rate: This is the percentage of orders that are delivered on or before the required date.
with cte as (select s.SupplierID, OrderDate, RequiredDate, ShippedDate,
count(*) over (partition by s.SupplierID) as TotalOrder
from Orders o join [Order Details] d on o.OrderID=d.OrderID
join Products p on d.ProductID=p.ProductID
join Suppliers s on p.SupplierID=s.SupplierID
)
select distinct SupplierID, cast(count(SupplierID) over (partition by SupplierID) as decimal) / cast(TotalOrder as decimal) On_time_rate
from cte where datediff(day, ShippedDate, RequiredDate) > 0
order by On_time_rate desc

-- 2. Delivery lead time: This is the number of days between the order date and the shipped date. 
select s.SupplierID, avg(datediff(day,orderdate ,ShippedDate)) avg_datediff
from Orders o join [Order Details] d on o.OrderID=d.OrderID
join Products p on d.ProductID=p.ProductID
join Suppliers s on p.SupplierID=s.SupplierID
group by s.SupplierID
order by avg_datediff
;

-- 3. Delivery time variance: This is the standard deviation of the delivery lead time for a given shipper or a given period. A lower delivery time variance means a more consistent and reliable delivery time.
with cte as (select s.SupplierID, datediff(day,orderdate ,ShippedDate) as daydiff
from Orders o join [Order Details] d on o.OrderID=d.OrderID
join Products p on d.ProductID=p.ProductID
join Suppliers s on p.SupplierID=s.SupplierID)

select distinct SupplierID, STDEV(daydiff) over (partition by SupplierID) as SD_leadtime,
case when STDEV(daydiff) over (partition by SupplierID)  < 5 then 'Stable' else 'Not Stable'
end as Stability
from cte
order by SD_leadtime

-- Q7 Which product has the highest seasonal demand in 4 seasons in each year, measured by the standard deviation of the monthly sales quantity?
with cte as (
select distinct ProductName, year(orderdate) as Year, month(orderdate) as Month, 
sum(Quantity) as QtySold
from Orders o join [Order Details] d on o. OrderID=d. OrderID
join Products p on d.ProductID=p.ProductID
group by ProductName, year(orderdate), month(orderdate)
)
,
cte1 as (
select *, rank () over (partition by productname, year order by QtySold desc) the_rank
from cte
)
,
Season as (
select productname, year,
case when month in (1,2,3) then 'Spring'
when month in (4,5,6) then 'Summer'
when month in (7,8,9) then 'Autumn'
else 'Winter'
end as 'Season'
from cte1
where the_rank=1
)
,
SD as (
select distinct productname, year, stdev(qtysold) over (partition by year, productname) as SDQty 
from cte
)
,
summary as (select sd.ProductName, sd.Year, SDQty, s.Season,
rank () over (partition by sd.year, s.season order by SDQty desc) as therank2
from SD join Season s on sd.ProductName=s.ProductName and sd.Year=s.Year)

select ProductName, Year, Season
from summary
where therank2=1
;

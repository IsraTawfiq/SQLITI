use [ITI]
--1.	Retrieve number of students who have a value in their age. 
select count(St_id)
FROM Student
where St_age is not null 
--2.	Get all instructors Names without repetition
select distinct Ins_Name
from Instructor
--3.	Display student with the following Format (use isNull function)
--Student ID	Student Full Name	Department name

select St_id AS [Student ID], isnull(St_Fname+ ' ' +St_Lname, 'No data')  as [Student FullName] ,isnull( Dept_Name, '') as [Department name]
FROM student  s join Department d  on s.Dept_Id = d.Dept_Id 
--4.	Display instructor Name and Department Name 
--Note: display all the instructors if they are attached to a department or not

Select Ins_Name,Dept_Name
From Department D right join Instructor I on D.Dept_Id=I.Dept_Id
--5.Display student full name and the name of the course he is taking
--For only courses which have a grade 
Select St_Fname+ ' ' +St_Lname as fullname,Crs_Name,Grade
from Student S join Stud_Course C on S.St_Id=C.St_Id
JOIN Course  U on U.Crs_Id=C.Crs_Id AND Grade is not null

--6.Display number of courses for each topic name
SELECT COUNT(Crs_Id) as numofcourses,Top_Name
from Topic T join Course C ON T.Top_Id=C.Top_Id
Group by Top_Name
--7.Display max and min salary for instructors
SELECT MAX(salary) as max,Min(salary) as min
from Instructor
--8.Display instructors who have salaries less than the average salary of all 
instructors.
select Ins_Name, Salary
from Instructor
where salary < all (select avg(salary) from Instructor)

--9.Display the Department name that contains the instructor who receives
--the minimum salary.
Select Dept_Name
from Department D join Instructor I on D.Dept_Id=I.Dept_Id
where Salary = (select min(salary) from Instructor)

--10- Select max two salaries in instructor table. 
SELECT TOP 2 (salary)
from Instructor
ORDER BY SALARY DESC 

SELECT DISTINCT TOP 2 MAX(salary) AS max2
FROM Instructor
GROUP BY salary
ORDER BY max2 DESC
---
Select max(salary)
From instructor
Union ALL
Select max (salary)
From instructor 
Where salary not in(select max(salary) from instructor)
--11.Select instructor name and his salary but if there is no salary display
--instructor bonus. “use one of coalesce Function”

SELECT Ins_Name, COALESCE(CONVERT(VARCHAR(50), salary), Ins_Name)
FROM Instructor
--OR
SELECT Ins_Name, COALESCE(CAST(salary AS VARCHAR(50)), Ins_Name)
FROM Instructor
--12-Select Average Salary for instructors 
SELECT AVG(salary)
from Instructor
--13.Select Student first name and the data of his supervisor 
SELECT A.St_Fname AS STudentname, B.*
FROM student A,student B
where A.St_Id=B.St_Id
--or
SELECT A.St_Fname AS StudentName, B.*
FROM student A
JOIN student B ON A.St_Id = B.St_Id;

--14.Write a query to select the highest two salaries in Each Department for 
--instructors who have salaries. “using one of Ranking Functions”
Select salary,Dept_Id
from (select salary,Dept_Id,
      DENSE_RANK() over (partition by Dept_Id order by salary desc) as DN
	  FROM Instructor where salary is not null) AS newtable

WHERE DN <= 2

--15. Write a query to select a random student from each department. 
--“using one of Ranking Functions”

SELECT 
   St_Id,Dept_Id
FROM (
   SELECT St_Id,Dept_Id,
      ROW_NUMBER() OVER (PARTITION BY Dept_Id ORDER BY NEWID()) AS RN
   FROM  Student) AS newTABLE
WHERE RN = 1;
-------
 Use [AdventureWorks2012]
--1.Display the SalesOrderID, ShipDate of the SalesOrderHearder table (Sales schema)
--to designate SalesOrders that occurred within the period ‘7/28/2002’ and ‘7/29/2014’
select SalesOrderID, ShipDate from [Sales].[SalesOrderHeader]
where OrderDate between '7/28/2002' and '7/29/2014'
--2.Display only Products(Production schema) with a StandardCost
--below $110.00 (show ProductID, Name only)
select ProductID, [Name] from [Production].[Product]
where StandardCost < $110.00

--3.Display ProductID, Name if its weight is unknown
select ProductID, [Name] from [Production].[Product]
where Weight is null
--4.Display all Products with a Silver, Black, or Red Color
select * from [Production].[Product]
where color in ('Silver', 'Black', 'Red')
--5.Display any Product with a Name starting with the letter B
select Name from [Production].[Product]
where name like 'B%'
--6.Run the following Query
select * from Production.ProductDescription
UPDATE Production.ProductDescription
SET Description = 'Chromoly steel_High of defects'
WHERE ProductDescriptionID = 3
--Then write a query that displays any Product description 
--with underscore value in its description.
select description from Production.ProductDescription
where description like '%[_]%'

--7.Calculate sum of TotalDue for each OrderDate in Sales.SalesOrderHeader table 
--for the period between  '7/1/2001' and '7/31/2014'
select sum(TotalDue) from Sales.SalesOrderHeader
where OrderDate between  '7/1/2001' and '7/31/2014'
group by OrderDate
--8.Display the Employees HireDate (note no repeated values are allowed)
select distinct HireDate from [HumanResources].[Employee]
--9.Calculate the average of the unique ListPrices in the Product table
select avg(ListPrice) from [Production].[Product]
--10.Display the Product Name and its ListPrice within the values of 100 and 120 
--the list should has the following format "The [product name] is only! 
--[List price]" (the list will be sorted according to its ListPrice value
SELECT 'The ' + Name + ' is only! $' + convert(VARCHAR(10),ListPrice) 
FROM [Production].[Product]
WHERE ListPrice BETWEEN 100 AND 120
ORDER BY ListPrice

--11.	

--a)Transfer the rowguid ,Name, SalesPersonID, Demographics from Sales.Store table 
--in a newly created table named [store_Archive]
--Note: Check your database to see the new table and how many rows in it?
select rowguid ,Name, SalesPersonID, Demographics into [store_Archive]
from Sales.Store
select * from [store_Archive]
select * from Sales.Store

--b)Try the previous query but without transferring the data? <structure only >
select rowguid ,Name, SalesPersonID, Demographics into [store_Archive]
from Sales.Store where 1=0

--12.Using union statement, retrieve the today’s date in different styles
SELECT FORMAT(GETDATE(), 'MM/dd/yyyy') as styles
UNION
SELECT FORMAT(GETDATE(), 'yyyy-MM-dd')
UNION
SELECT FORMAT(GETDATE(), 'dd/MM/yyyy')
UNION
SELECT FORMAT(GETDATE(), 'MM-dd-yyyy')
UNION
SELECT FORMAT(GETDATE(), 'yyyy/MM/dd')
UNION
SELECT FORMAT(GETDATE(), 'MMMM dd, yyyy')


select getdate()
select day (getdate())
SELECT DATEPART(wk, GETDATE()) 

--Part-3: Bouns
--Display results of the following two statements and explain what is the meaning of @@AnyExpression
select @@VERSION serverversion
select @@SERVERNAME server name
select @@ROWCOUNT
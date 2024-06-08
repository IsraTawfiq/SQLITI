--lap7
use ITI
--Create a scalar function that takes date and returns Month name of that date.

CREATE OR ALTER FUNCTION getmonth (@date date)
returns  varchar(50)
BEGIN
	declare @month varchar(50)
	SELECT @month=DATENAME(month, @date) 
	return @month

END
GO
select dbo.getmonth ('12/12/2024') as month_name

--Create a multi-statements table-valued function that takes 2 integers
--and returns the values between them.

CREATE OR ALTER FUNCTION getsbetween (@x int, @y int)
RETURNS @t TABLE (
    list int
)
AS
BEGIN
    WHILE @x < @y -1
    BEGIN 
        SET @x = @x + 1
        INSERT INTO @t (list) VALUES (@x)
    END
    
    RETURN
END
GO
SELECT * FROM getsbetween(5, 10)
--Create a tabled valued function that takes Student No 
--and returns Department Name with Student full name.

create function getsDEPT(@stud_id int)
returns table
as 
return 
(
	select s.St_Fname+' ' +s.St_Lname As fullname,d.Dept_Name
    from Student s, Department d where s.Dept_Id=d.Dept_Id and s.St_Id=@stud_id 
)
go
	select * from getsDEPT(10)

--Create a scalar function that takes Student ID and returns a message to user 
--a.If first name and Last name are null then display 'First name & last name are null'
--b.If First name is null then display 'first name is null'
--c.If Last name is null then display 'last name is null'
--d.Else display 'First name & last name are not null'


create or alter function getsmsg (@std_id int)
returns varchar(100)

BEGIN
		declare @msg varchar(100)

SELECT @msg=CASE 
           WHEN St_Fname+St_Lname IS NULL THEN 'First name & last name are null' 
           WHEN St_Fname IS NULL THEN 'first name is null' 
           WHEN St_Lname IS NULL THEN 'last name is null' 
           ELSE 'First name & last name are not null' 
       END 
FROM Student where St_Id=@std_id 
RETURN @msg
END
go
select  dbo.getsmsg(1) as errormsg


--Create a function that takes integer which represents the format of the Manager
--hiring date and displays department name, Manager Name and hiring date with this format

CREATE or ALTER function getshiringdate (@format int)
returns @t table
(
deptname nvarchar(50),
mgrname nvarchar(50),
hiringdate nvarchar(50)
)
as 
BEGIN
   INSERT INTO @t
    SELECT 
        D.Dept_Name, 
        I.Ins_Name, 
        CONVERT(nvarchar(50), D.Manager_hiredate, @Format)
    FROM 
        Department D
     JOIN 
        Instructor I ON I.Dept_Id = D.Dept_Id

    RETURN
end
go
SELECT * FROM getshiringdate (106)

--Create multi-statements table-valued function that takes a string
--If string='first name' returns student first name
--If string='last name' returns student last name 
--If string='full name' returns Full Name from student table 
--Note: Use “ISNULL” function
create or alter function getsnames (@str nvarchar(50))
returns @names table 
(
st_name nvarchar(50)
)
as
begin

	insert into @names
	SELECT  
	 CASE 
            WHEN @str = 'first name' THEN ISNULL(St_Fname, '')
            WHEN @str = 'last name' THEN ISNULL(St_Lname, '')
            WHEN @str = 'full name' THEN ISNULL(CONCAT(St_Fname, ' ', St_Lname), '')
            ELSE ''
        END
    FROM student

	 
RETURN 
END
 GO
select * from getsnames ('full name')

--Write a query that returns the Student No and Student first name without the last char

create or alter function leftlastchar()
returns table 
as 
return 
(
SELECT st_id,left(St_Fname,len(st_fname)-1) as name
from student  
)
go
select * from leftlastchar()

--Write a query that takes the columns list and table name into variables 
--and then return the result of this query “Use exec command”

declare @col NVARCHAR(MAX) ='*'
declare @t NVARCHAR(100) ='student'

execute ('SELECT ' + @col + ' FROM ' + @t)

---- 
use [SD32-Company]
--Create function that takes project number and display all employees in this project


create or alter function getemp(@pno varchar(25))
returns table 
as
return 
(
   select e.* from [HR].[Employee] e  join dbo.[works_on] w on e.EmpNo=w.EmpNo
           join [Company].[Project] p on p.PNO=w.ProjectNo and PNO=@pno
)

select * from getemp ('p1')

--Bonus:
--Create a batch that inserts 3000 rows in the employee table.
--The values of the emp_no column should be unique and between 1 and 3000. 
--All values of the columns emp_lname, emp_fname, 
--and dept_no should be set to 'Jane', ' Smith', and ' d1',
--i will use a temptable 
CREATE TABLE ##employee_temp (
    emp_no INT,
    emp_lname NVARCHAR(50),
    emp_fname NVARCHAR(50),
    dept_no NVARCHAR(50)
)

DECLARE @empno INT = 1

WHILE @empno <= 3000
BEGIN
    INSERT INTO ##employee_temp (emp_no, emp_lname, emp_fname, dept_no) 
    VALUES (@empno, 'Jane', 'Smith', 'd1')

    SET @empno = @empno + 1
END
go
SELECT * FROM ##employee_temp
--Give an example for Hierarch id Data type

-- designed to represent hierarchical relationships, such as organizational charts or category trees
create database test
use test 
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    EmployeeName NVARCHAR(100),
    ManagerNode hierarchyid
)
INSERT INTO Employee (EmployeeID, EmployeeName, ManagerNode)
VALUES (1, 'John', NULL),            -- John is the CEO, so he has no manager
       (2, 'Alice', '/1/'),          -- Alice reports to John (EmployeeID 1)
       (3, 'Bob', '/1/'),            -- Bob reports to John (EmployeeID 1)
       (4, 'Carol', '/1/'),          -- Carol reports to John (EmployeeID 1)
       (5, 'David', '/1/2/'),        -- David reports to Alice (EmployeeID 2)
       (6, 'Eva', '/1/2/'),          -- Eva reports to Alice (EmployeeID 2)
       (7, 'Frank', '/1/3/'),        -- Frank reports to Bob (EmployeeID 3)
       (8, 'Gina', '/1/3/');         -- Gina reports to Bob (EmployeeID 3)

SELECT EmployeeID, EmployeeName
FROM Employee
WHERE ManagerNode is null --ceo 

who report to bob?
SELECT EmployeeID, EmployeeName
FROM Employee
WHERE ManagerNode = '/1/3/'

--or
SELECT EmployeeID, EmployeeName
FROM Employee
WHERE ManagerNode.IsDescendantOf('/1/3') = 1 -- immediate descendant
--=2 means  any descendant, including immediate and non-immediate descendants.





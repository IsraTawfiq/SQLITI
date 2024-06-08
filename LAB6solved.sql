--LAB-6
--Create the following database “visually” 
--Consists of 2 File Groups { SeconderyFG (has two data files) and ThirdFG (has two data files) } 
--Database Name	SD32-Company
--Location	(Default path)
--Initial size for mdf	25	MB
--File Group for mdf	Primary
--File Growth for mdf	           10%
--Max. File Size for mdf	400	MB
--Log File Name 	SD30-Company-Log
--Location for Log	(Default Path)
--Initial Size for Log	15	MB
--File Growth 	20%
--Log File Max. Size 	400 MB
CREATE DATABASE [SD32-Company]
ON 
PRIMARY
(
    NAME = N'SD32-Company', 
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SD32-Company.mdf', 
    SIZE = 25MB,
    MAXSIZE = 400MB,
    FILEGROWTH = 10%
)

LOG ON 
(
    NAME = N'SD30-Company-Log',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SD30-Company-Log.ldf',  
    SIZE = 15MB,
    MAXSIZE = 400MB,
    FILEGROWTH = 20%
)
ALTER DATABASE [SD32-Company]
ADD FILEGROUP SeconderyFG;

ALTER DATABASE [SD32-Company]
ADD FILE 
(
    NAME = N'SeconderyFG_Data1',
    FILENAME =N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SeconderyFG_Data1.ndf',
    SIZE = 25MB,
    MAXSIZE = 400MB,
    FILEGROWTH = 10%
);

ALTER DATABASE [SD32-Company]
ADD FILE 
(
    NAME = N'SeconderyFG_Data2',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SeconderyFG_Data2.ndf',  -- Change the path as needed
    SIZE = 25MB,
    MAXSIZE = 400MB,
    FILEGROWTH = 10%
);
ALTER DATABASE [SD32-Company]
ADD FILEGROUP ThirdFG;

ALTER DATABASE [SD32-Company]
ADD FILE 
(
    NAME = N'ThirdFG_Data1',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ThirdFG_Data1.ndf',  
    SIZE = 25MB,
    MAXSIZE = 400MB,
    FILEGROWTH = 10%
);

ALTER DATABASE [SD32-Company]
ADD FILE 
(
    NAME = N'ThirdFG_Data2',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ThirdFG_Data2.ndf',  
    SIZE = 25MB,
    MAXSIZE = 400MB,
    FILEGROWTH = 10%
);
use [SD32-Company]

---Create a new user data type named loc with the following Criteria:
--•	nchar(2)
--•	default:NY 
--•	create a rule for this Datatype :values in (NY,DS,KW)) and associate it to the location column  
sp_addtype loc , 'nchar(2)'

create rule r1 AS @loc IN ('NY', 'DS', 'KW')
create default def1 as 'NY' 
sp_bindrule r1, loc;
sp_bindefault def1, loc;

-- msh m7taga adrop kda kda lw add new role htovercome  el r1 
--sp_droptype loc;
--DROP RULE r1;
--DROP DEFAULT def1;

--CREATE DEPARTMENT TABLE 

CREATE TABLE Department(
DeptNo int primary key identity (1,1),
DeptName varchar(50),
Location loc

)


--insert into department 
insert into department (DeptName)values ('Marketing'),('sales'),('Engineering')
select * from Department
SET IDENTITY_INSERT department on;
insert into department (DeptNo)values (4),(5),(6)
SET IDENTITY_INSERT department off;
truncate table department -- áÚÈÊ ÝíåÇ ßÊíÑ æÚÇíÒÉ íÕÝÑ Çáßæáã ÈÊÇÚ ÇáÏíÈÑÊ äãÈÑ Ý åíÌí íÃäÓÑÊ íÈÏÃÊÇäí ãä 1 
--CREATE Employee TABLE 

CREATE TABLE Employee(
EmpNo int,
Fname Varchar(25) NOT NULL,
Lname	varchar(25)NOT NULL ,
Deptnumber int,
Salary money UNIQUE, -- Salary money CONSTRAINT CHK_Salary CHECK (Salary < 6000),
constraint emp_pk primary key (EmpNo),
constraint emp_Fk foreign key (Deptnumber) REFERENCES Department(DeptNo))
alter table employee add  [Full Name] as concat (Fname,' ' , Lname) persisted

--(Salary < 6000)
CREATE RULE SalaryCheck AS @Salary < 6000

sp_bindrule SalaryCheck, 'Employee.Salary'
sp_bindrule r1,'salary'

insert into Employee values 
(25348, 'israo', 'mtm', 1, 2500),
(10102, 'ali', 'bebo', 2, 3000),
(18316, 'memo', 'amer', 3, 2400)
select * from Employee
--Project 
CREATE TABLE Project (
PNO varchar(25) primary key ,
Pname varchar(50) NOT NULL,
Badget bigint NULL)

insert into Project values 
('p1', 'Apollo',null),
('p2', 'Gymini', 30000)
--table works_on
create table  works_on(
EmpNo int not null,
ProjectNo varchar(25) not null,
Job varchar(50) null,
Enter_Date  date not null default GETDATE(),
constraint pk_workson primary key(ProjectNo,EmpNo),
constraint fk_workson foreign key (EmpNo) REFERENCES Employee(EmpNo),
constraint fk_workson2 foreign key (ProjectNo) REFERENCES Project(PNO))

INSERT INTO works_on (EmpNo, ProjectNo, Job)
VALUES
(25348, 'p1', 'eng'),
(10102, 'p2', 'bi'),
(18316, 'p1', 'eng')
select * from works_on

--1-Add new employee with EmpNo =11111 In the works_on table [what will happen]
INSERT INTO works_on (EmpNo, ProjectNo,  Enter_Date) --<child then parent xxxx>
VALUES (11111, 'p1',  '2023-05-12') 
--The INSERT statement conflicted with the FOREIGN KEY constraint "fk_workson"
insert into Employee values (11111, 'mohamed', 'tawfiq', 3, 2600) --<parent then child>
INSERT INTO works_on (EmpNo, ProjectNo,  Enter_Date)
VALUES (11111, 'p1',  '2023-05-12') 


--2-Change the employee number 10102  to 11111  in the works on table [what will happen]
update works_on 
set EmpNo = 11111
where EmpNo = 10102 --huwdy 3adi 34an 3mlt ablha insert le 11111 f emp 
update works_on 
set EmpNo = 101218
where EmpNo = 11111 --xxxx update f parent then child
--3-Modify the employee number 10102 in the employee table to 22222. [what will happen]
update Employee
set EmpNo = 10102
where EmpNo = 22222 
select * from works_on
--4-Delete the employee with id 10102
delete from employee where EmpNo = 10102
--Add  TelephoneNumber column to the employee table[programmatically]
alter table employee add TelephoneNumber varchar(15)
--2-drop this column[programmatically]
alter table employee drop column TelephoneNumber 
--2.	Create the following schema and transfer the following tables to it 
--a.	Company Schema 
--i.	Department table (Programmatically)
create schema Company
alter schema Company transfer Department
--ii.	Project table (visually)
--b.	Human Resource Schema
CREATE SCHEMA HR
--i.	  Employee table (Programmatically)

--Write query to display the constraints for the Employee table.
SELECT
    TC.CONSTRAINT_NAME,
    TC.CONSTRAINT_TYPE,
    CCU.COLUMN_NAME AS COLUMN_NAME,
    KCU.TABLE_NAME AS REFERENCED_TABLE,
    KCU.COLUMN_NAME AS REFERENCED_COLUMN
FROM
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
JOIN
    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU
    ON TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
LEFT JOIN
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
    ON TC.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
WHERE
    CCU.TABLE_NAME = 'Employee'

--4.	Create Synonym for table Employee as Emp and then run the following queries and describe the results
create  synonym Emp for HR.Employee
SELECT * FROM Emp
select * from HR.Employee
select * from Employee <xxxx>
--5.	Increase the budget of the project where the manager number is 10102 by 10%.
update company.Project
set Badget =ISNULL(Badget * 1.10,0)
where PNO in (select ProjectNo from works_on where EmpNo=11111)
--6.Change the name of the department for which the employee named James works.The new department name is Sales.
SELECT * FROM [Company].[Department]
SELECT * FROM [HR].[Employee]
INSERT INTO [Company].[Department] (DeptName)VALUES ('NEW')
UPDATE [HR].[Employee]
SET  [Deptnumber]= 4
WHERE fName = 'israo';
--7.Change the enter date for the projects for those employees who work in project p1 and belong 
--to department ‘new’. The new date is 12.12.2007.
select * from [dbo].[works_on]
UPDATE works_on
SET Enter_Date = '2007-12-12'
WHERE ProjectNo = 'p1'
  AND EmpNo IN (SELECT EmpNo FROM [HR].[Employee] WHERE [Deptnumber] = 4)



--8.Delete the information in the works_on table for all employees who work for the department located in KW.

DELETE FROM works_on
WHERE EmpNo IN (SELECT EmpNo FROM [HR].[Employee] WHERE [Deptnumber] IN (SELECT DeptNo FROM [Company].[Department]
WHERE Location = 'NY'))


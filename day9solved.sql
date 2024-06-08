--1.	Display all the data from the Employee table (HumanResources Schema) 
--As an XML document “Use XML Raw”. “Use Adventure works DB” 
--A)	Elements
--B)	Attributes
use AdventureWorks2022
select * from HumanResources.Employee
for xml raw ('emp'),elements,Root('root')

--1.	Display Each Department Name with its instructors. “Use ITI DB”
--A)	Use XML Auto
use iti
select Dept_Name,ins_name from Department d join Instructor i on d.Dept_Id=i.Dept_Id
for xml auto
--B)Use XML Path
select Dept_Name,
(select ins_name "instructor"
from Instructor for xml path ('instructors'),TYPE,root('dept'))
from Department
for xml path('Dept_Name'),root('instructors_inside_deptartment')


-- Use the following variable to create a new table "customers" inside the company DB.
-- Use OpenXML
DECLARE @docs xml = '<customers>
              <customer FirstName="Bob" Zipcode="91126">
                     <order ID="12221">Laptop</order>
              </customer>
              <customer FirstName="Judy" Zipcode="23235">
                     <order ID="12221">Workstation</order>
              </customer>
              <customer FirstName="Howard" Zipcode="20009">
                     <order ID="3331122">Laptop</order>
              </customer>
              <customer FirstName="Mary" Zipcode="12345">
                     <order ID="555555">Server</order>
              </customer>
       </customers>'

DECLARE @hdocs int;
EXEC sp_xml_preparedocument @hdocs OUTPUT, @docs

SELECT *
INTO customers
FROM OPENXML (@hdocs, '//customer') 
WITH (
    firstname varchar(10) '@FirstName', 
    zipcode varchar(5) '@Zipcode',
    orderid int 'order/@ID',
    ordername varchar(20) '.')

EXEC sp_xml_removedocument @hdocs

SELECT * FROM customers

--1.Create a stored procedure to show the number of students per department.[use ITI DB] 
create or alter proc #student
as
	select count(*)  '#ofstudents', dept_name
	from student s join Department d
	on d.Dept_Id=s.Dept_Id
	group by dept_name
#student
--2.Create a stored procedure that will check for the # of employees in the project p1 
--if they are more than 3 print message to the user 
--“'The number of employees in the project p1 is 3 or more'” 
--if they are less display a message to the user “'The following employees work for the project p1'” 
--in addition to the first name and last name of each one. [Company DB] 
use [SD32-Company]

CREATE OR alter PROC p1
AS
BEGIN
    IF (SELECT COUNT(*) '#emp' FROM works_on WHERE ProjectNo = 'p1') >= 3
    BEGIN
        PRINT 'The number of employees in the project p1 is 3 or more'
    END
    ELSE
    BEGIN
        select 'The following employees work for the project p1: ',
         Fname, Lname
        FROM [HR].[Employee] e
        JOIN works_on w ON e.EmpNo = w.EmpNo
        WHERE w.ProjectNo = 'p1'
    END
END


p1
--3.Create a stored procedure that will be used in case there is an old employee has left the project
--and a new one become instead of him. The procedure should take 3 parameters 
--(old Emp. number, new Emp. number and the project number) 
--and it will be used to update works_on table. [Company DB]
use [SD32-Company]
create or alter proc project  @old int,@new int,@project varchar(25)
as
begin
	update  works_on set EmpNo=@new
	where EmpNo=@old and ProjectNo= @project

	  SELECT * FROM works_on WHERE ProjectNo = @project
end

project 1111,1,'p1'
---This table will be used to audit the update trials on the Budget column (Project table, Company DB)
--Example:
--If a user updated the budget column then the project number, user name that made that update, the date of the modification and the value of the old and the new budget will be inserted into the Audit table
--Note: This process will take place only if the user updated the budget column

Create table _audit
(ProjectNo  varchar(25), 
UserName varchar(50), 
ModifiedDate date, 
Budget_Old bigint , 
Budget_New bigint

)

create or alter trigger t1
on Company.Project
for update 
as
	IF update(Badget)
	begin
		declare @Project varchar(25),@oldBadget bigint,@newBadget bigint
		select @Project= d.Pno,@oldBadget=d.Badget, @newBadget=i.Badget
		from inserted i join deleted d on i.Pno=d.Pno
		insert into _audit values(@Project,SUSER_NAME(),getdate(),@oldBadget,@newBadget)
	end
update Company.Project set Badget+=12000
select * from _audit


--1.	Create a trigger to prevent anyone from inserting a new record in the Department table [ITI DB]
--“Print a message for user to tell him that he can’t insert a new record in that table”
use ITI
Create or alter trigger company.t2 
on Company.Department
instead of insert 
as
		select SUSER_NAME()+' can’t insert a new record in that table'
insert into Company.department values ('hrr','us')
--2.Create a trigger that prevents the insertion Process for Employee table in March [Company DB].
Create or alter trigger hr.t3 
on hr.employee
for  insert 
as
	 IF MONTH(GETDATE()) = 4
    BEGIN
        RAISERROR('Insertion into Employee table is not allowed in March.', 16, 1)
        ROLLBACK 
	end
insert into  hr.employee (EmpNo,Fname,Lname,Salary)values (2,'isra','mtm',1000)

select * from hr.Employee

--3.Create a trigger that prevents users from altering any table in Company DB

CREATE OR ALTER TRIGGER prevent_alter_table
ON DATABASE
FOR ALTER_TABLE
AS
BEGIN
    RAISERROR('ALTER TABLE statement is not allowed in this database.', 16, 1)
    ROLLBACK 
END

alter table hr.employee add coldummy  int
-----Create a trigger on student table after insert to add Row in Student Audit table (Server User Name , Date, Note) where note will be “[username] Insert New Row with Key=[Key Value] in table [table name]”

CREATE TABLE Student_Audit (
    UserName NVARCHAR(100),
    Date DATETIME,
    Note NVARCHAR(MAX)
)

CREATE  or alter TRIGGER trg_Student_Audit_Insert
ON Student
AFTER INSERT
AS
BEGIN
    INSERT INTO Student_Audit (UserName, Date, Note)
    SELECT SYSTEM_USER, GETDATE(), '[' + SYSTEM_USER + '] Insert New Row with Key=' + CAST(St_Id AS NVARCHAR(100)) + ' in table Student'
    FROM inserted;
END;
insert  into Student (St_Id) values (109872)
select * from Student_Audit


-- Create a trigger on student table instead of delete to add Row in Student Audit table
--(Server User Name, Date, Note)
--where note will be“ try to delete Row with Key=[Key Value]”

alter table student disable trigger t9,t78,t77,[trg_Student_Audit_Insert]
CREATE or alter TRIGGER trg0
ON Student
INSTEAD OF DELETE
AS
BEGIN
     
        INSERT INTO Student_Audit (UserName, Date, Note)
        SELECT SYSTEM_USER, GETDATE(), '[' + SYSTEM_USER + '] Try to delete Row with Key=' + CAST(St_Id AS NVARCHAR(100)) + '; '
        FROM deleted;

        ROLLBACK ;
   
END
----------
Bonus (5 Points):
1.	Transform all functions in lab 8 to be stored procedures

2.	Get All Student as an XML Document and display Student Id as attribute and the other columns as Elements
Use XML Explicit

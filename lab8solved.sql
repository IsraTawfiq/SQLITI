--lab8 
 Use ITI 
 select * from Student
--1.Create a view that displays student full name, course name if the student has a grade more than 50. 
create or alter view vw_student_info
as 
select St_fname+' '+st_Lname as [Name],a.Crs_Name as Course
from Student S join Stud_Course C on s.St_Id=c.St_Id join Course A on A.Crs_Id=C.Crs_Id
AND Grade>50

--select * from vw_student_info
--2.Create an Encrypted view that displays manager names and the topics they teach. 
create or alter view vw_manager
with encryption 
as 
select I.Ins_Name as Manager,T.Top_name as Topic
from  Instructor I JOIN Department D ON I.Ins_id=D.Dept_Manager
JOIN Ins_Course U on I.ins_id=U.ins_id 
Join Course C on C.crs_id=U.crs_id 
join topic T on T.top_id =C.top_id 

--SELECT * FROM vw_manager
--sp_helptext vw_manager

--3.Create a view that will display Instructor Name, Department Name 
--for the ‘SD’ or ‘Java’ Department “use Schema binding” and describe 
--what is the meaning of Schema Binding 
create or alter view vw_instructor
with schemabinding 
as 
select Ins_Name as [Instructor],Dept_name as [Department]
from dbo.instructor I join dbo.Department D on D.Dept_id=I.dept_id

--select * from vw_instructor

--4.Create a view “V1” that displays student data for student who lives in Alex or Cairo. 
--Note: Prevent the users to run the following query 
--Update V1 set st_address=’tanta’
--Where st_address=’alex’;
create or alter view v1
as 
select * from student 
where st_address in ('Alex','Cairo')
with check option 

select * from v1
update v1 set St_Address='tanta'
where St_Address='Alex' -- failed 
--5.Create index on column (Hiredate) that allow u to cluster the data in table Department.
--What will happen?
create index index1 
on Department(manager_hiredate)
-- it created it non cluster 

--6.Create index that allow u to enter unique ages in student table. What will happen?
create unique index ages
on student(st_age)
--it failed because the old data have duplication

--7.Create temporary table [Session based] on Company DB to save employee name and his today task.
use [SD32-Company]
create table #emptask
( 
  empname varchar(50),
  task varchar(max)
)

--8.Create a view that will display the project name and the number of employees work on it.
create or alter view vw_project
as 
select Pname AS [project name],count(Empno) as #EMP
from Company.project join works_on on PNO=ProjectNo
group by Pname

--select * from vw_project

--9.Using Merge statement between the following two tables [User ID, Transaction Amount]
create database trnx
use trnx
--target table
Create table dailytransactions(

[Userid] int,
Amount money)
go
insert into dailytransactions values (1,1000),(2,2000),(3,1000)
--source table 
Create table [lasttransactions](
[Userid] int ,
Amount money)
insert into [lasttransactions]  values (1,4000),(4,2000),(2,10000)

select * from dailytransactions
select * from [lasttransactions]
 
 merge  dailytransactions as [target] 
 using  [lasttransactions] as [source] 
 on [source].Userid=[target].Userid
 --#update
 when matched then update 
 set  [target].Amount = [source].Amount

 --#insert
 when not matched by target then
 insert 
 values ([source].Userid, [source].Amount) 
 --#delete
when not matched by source then delete;

 select @@ROWCOUNT
 select * from dailytransactions
select * from [lasttransactions]
 
 ---------------------------------------
 --Part 2:
 use [SD32-Company]
--1)Create view named “v_clerk” that will display employee#,project#, the date of hiring of all the jobs of the type 'Clerk'.
create or alter view v_clerk
as 
select count(EmpNo) as employee#,count(ProjectNo) as project#,Enter_Date
from [dbo].[works_on]
where job='Clerk'
group by Enter_Date

select * from v_clerk
--2)Create view named  “v_without_budget” that will display all the projects data 
--without budget
create or alter view v_without_budget
as 
select * from [Company].[Project]
where Badget is null 

select * from v_without_budget

--3)Create view named  “v_count “ that will display the project name and the # of jobs in it
create or alter view v_count
as 
select Pname,count(job) as [# of jobs] from [Company].[Project] join works_on
on PNO=ProjectNo
group by Pname
--select * from v_count

--4)Create view named ” v_project_p2” that will display the emp# s for the project# ‘p2’
--use the previously created view  “v_clerk”
--select * from v_clerk

create or alter view v_project_p2
as 
select c.employee#  from  [dbo].[works_on] w  join v_clerk c  on  c.employee# = w.EmpNo
where w.ProjectNo ='p2'

select * from v_project_p2

--5)modifey the view named  “v_without_budget”  to display all DATA in project p1 and p2 

--sp_helptext v_without_budget

alter view v_without_budget
as 
select * from [Company].[Project]
where PNO IN('p1','p2')
--6)Delete the views  “v_ clerk” and “v_count”
drop view v_clerk,v_count

--7)Create view that will display the emp# and emp lastname who works on dept# is ‘d2’
create or alter view vw_employee
as 
select count(EmpNo) as emp#,Lname as lastname
from hr.Employee join Company.Department on DeptNo=Deptnumber
and DeptNo ='2'
group by Lname
--8)Display the employee  lastname that contains letter “J”
--Use the previous view created in Q#7
select lastname from vw_employee 
where lastname like '%J%'
--9)Create view named “v_dept” that will display the department# and department name
create or alter view v_dept
as 
select count(deptno) as dept#, deptname 
from Company.Department
group by DeptName
--10)using the previous view try enter new department data where dept# is ’d4’ and 
--dept name is ‘Development’
insert into v_dept  (deptno,deptname)values (4,'Development') 
--failed da complex views contain agg or group by so cannot be directly updated 
--because the view's definition involves summarizing data from the underlying tables

--11)Create view name “v_2006_check” that will display employee#, the project #where he works and
--the date of joining the project which must be from the first of January and the last of December 2006.
--this view will be used to insert data so make sure that the coming new data must match the condition

create or alter view v_2006_check
as
   select empno,count(projectno) as #project from works_on 
    where Enter_Date between '2006-01-01' AND '2006-03-31'
     group by empno

use [Company_SD]

--1.	Display (Using Union Function)
--a. name and gender of the dependence that's gender is F  depending on F Employee.
--b.	 And the male dependence that depends on Male Employee.
SELECT Dependent_name,sex 
FROM Dependent
where sex ='F' AND ESSN IN (SELECT SSN FROM Employee WHERE SEX = 'F')
UNION
SELECT Dependent_name,sex 
FROM Dependent
where sex ='M' AND ESSN IN (SELECT SSN FROM Employee WHERE SEX = 'M')
--2.For each project, list the project name and the total hours per week
--(for all employees) spent on that project.
SELECT Pname,sum(Hours) as total
from Project join Works_for on Pnumber=Pno
group by Pname
--3. data of the department which has the smallest employee ID over all employees' ID.
select D.*
from Departments D join Employee E on Dnum=Dno
WHERE ssn =(select min(ssn) from Employee)
--4.For each department, retrieve the department name and the maximum, 
--minimum and average salary of its employees.
SELECT Dname, max(salary) as max,min(salary) as min, avg(salary) as avg
from Departments join Employee E on Dnum=Dno
group by Dname
--5.List the last name of all managers who have no dependents.
select Lname
from Employee join Departments on Dnum=Dno 
left join Dependent on SSN=ESSN
where  Essn is null 

--6.For each depart if its average salary is less than the average salary of all
--employees-- display its number, name and number of its employees.
SELECT dnum,dname,count(ssn) as numemp
from Departments join Employee on Dnum=Dno
group by Dnum,dname
having avg(salary) < (select avg(salary) from Employee)
--7.Retrieve a list of employees and the projects they are working on
--ordered by department and within each department ordered alphabetically by last name, first name.

select fname,Lname,Pname,Dnum
from employee join works_for on Essn=ssn join project on Pnumber=Pno
order by Dnum,Fname,Lname 
--8.Try to get the max 2 salaries using subquery
SELECT top 2 Salary 
from (select distinct salary
      from employee) as salary
order by  Salary DESC
--9.Get the full name of employees that is similar to any dependent name
use Company_SD
select fname+' '+Lname as [full name]
from Employee join Dependent on Essn = ssn
where fname IN (select Dependent_name from Dependent)
--10.Try to update all salaries of employees who work in Project ‘Al Rabwah’ by 30% 
update employee 
set Salary=salary*1.3
from employee join works_for on Essn=ssn join project on Pnumber=Pno
where Pname = 'Al Rabwah'
--11.Display the employee number and name if at least one of them have dependents
(use exists keyword) self-study.
SELECT SSN, fname + ' ' + Lname AS [full name]
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Dependent d
    WHERE d.ESSN = e.SSN
)

--DML

--1. "DEPT IT" , with id 100, employee with SSN = 112233 as a manager for this department. The start date for this manager is '1-11-2006'
insert into Departments Values ('DEPT IT',100,112233,'1-11-2006')
--2. Mrs.Noha Mohamed(SSN=968574)  moved to be the manager of the new department 
--(id = 100),and they give you(your SSN =102672) her position (Dept. 20 manager) 
--a.First try to update her record in the department table
update Departments 
set MGRSSN =968574
where Dnum=100
--b.Update your record to be department 20 manager.
update Departments
set MGRSSN=102672
where Dnum=20
--c.Update the data of employee number=102660 to be in your teamwork 
--(he will be supervised by you) (your SSN =102672)
update employee 
set Superssn=102672
where ssn = 102660
--3.Unfortunately the company ended the contract with Mr. Kamel Mohamed (SSN=223344)
--so try to delete his data from your database in case you know that you will be
--temporarily in his position.
--Hint: (Check if Mr. Kamel has dependents, works as a department manager,
--supervises any employees or works in any projects and handle these cases).
DELETE FROM Dependent WHERE ESSN = 223344

UPDATE Departments SET MGRSSN = 102672 WHERE MGRSSN = 223344
UPDATE Employee SET Superssn = 102672 WHERE Superssn = 223344
UPDATE Works_for SET Essn = 102672 WHERE Essn = 223344

DELETE FROM Employee WHERE ssn = 223344


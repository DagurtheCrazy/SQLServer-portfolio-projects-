DROP TABLE IF EXISTS ADDRESS;
CREATE TABLE ADDRESS
(
    ADDRESS_ID       VARCHAR(20) PRIMARY KEY
  , STREET           VARCHAR(250)
  , CITY             VARCHAR(100)
  , STATE            VARCHAR(100)
  , COUNTRY          VARCHAR(100)
);
DROP TABLE IF EXISTS SCHOOL;
CREATE TABLE  SCHOOL
(
    SCHOOL_ID         VARCHAR(20) PRIMARY KEY
  , SCHOOL_NAME       VARCHAR(100) NOT NULL
  , EDUCATION_BOARD   VARCHAR(80)
  , ADDRESS_ID        VARCHAR(20)
  , CONSTRAINT FK_SCHOOL_ADDR FOREIGN KEY(ADDRESS_ID) REFERENCES ADDRESS(ADDRESS_ID)
);
DROP TABLE IF EXISTS STAFF;
CREATE TABLE  STAFF
(
    STAFF_ID         VARCHAR(20)
  , STAFF_TYPE       VARCHAR(30)
  , SCHOOL_ID        VARCHAR(20)
  , FIRST_NAME       VARCHAR(100) NOT NULL
  , LAST_NAME        VARCHAR(100) NOT NULL
  , AGE              INT
  , DOB              DATE
  , GENDER           VARCHAR(10) CHECK (GENDER IN ('M', 'F', 'Male', 'Female'))
  , JOIN_DATE        DATE
  , ADDRESS_ID       VARCHAR(20)
  , CONSTRAINT PK_STAFF PRIMARY KEY(STAFF_ID)
  , CONSTRAINT FK_STAFF_SCHL FOREIGN KEY(SCHOOL_ID) REFERENCES SCHOOL(SCHOOL_ID)
  , CONSTRAINT FK_STAFF_ADDR FOREIGN KEY(ADDRESS_ID) REFERENCES ADDRESS(ADDRESS_ID)
);

DROP TABLE IF EXISTS STAFF_SALARY;
CREATE TABLE STAFF_SALARY
(
    STAFF_ID         VARCHAR(20) PRIMARY KEY
  , SALARY           FLOAT
  , CURRENCY         VARCHAR(5)
);

DROP TABLE IF EXISTS SUBJECTS;
CREATE TABLE SUBJECTS
(
    SUBJECT_ID       VARCHAR(20) PRIMARY KEY
  , SUBJECT_NAME     VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS CLASSES;
CREATE TABLE CLASSES
(
    CLASS_ID         VARCHAR(20)
  , CLASS_NAME       VARCHAR(50) NOT NULL
  , SUBJECT_ID       VARCHAR(20)
  , TEACHER_ID       VARCHAR(20)
  , CONSTRAINT FK_STAFF_SUBJ FOREIGN KEY(SUBJECT_ID) REFERENCES SUBJECTS(SUBJECT_ID)
  , CONSTRAINT FK_STAFF_STFF FOREIGN KEY(TEACHER_ID) REFERENCES STAFF(STAFF_ID)
  , CONSTRAINT PK_CLASSES PRIMARY KEY (CLASS_ID, CLASS_NAME, SUBJECT_ID)
);

DROP TABLE IF EXISTS STUDENTS;
CREATE TABLE STUDENTS
(
    ID               VARCHAR(20) PRIMARY KEY
  , FIRST_NAME       VARCHAR(100) NOT NULL
  , LAST_NAME        VARCHAR(100) NOT NULL
  , GENDER           VARCHAR(10) CHECK (GENDER IN ('M', 'F', 'Male', 'Female'))
  , AGE              INT
  , DOB              DATE
  , CONSTRAINT CH_STUDENTS_AGE CHECK (AGE > 0)
);

DROP TABLE IF EXISTS STUDENT_CLASSES;
CREATE TABLE STUDENT_CLASSES
(
    STUDENT_ID       VARCHAR(20)
  , CLASS_ID         VARCHAR(20)
  , CONSTRAINT UNQ_STDCLASS UNIQUE (STUDENT_ID, CLASS_ID)
  , FOREIGN KEY(STUDENT_ID) REFERENCES STUDENTS(ID)
);

DROP TABLE IF EXISTS PARENTS;
CREATE TABLE PARENTS
(
    ID               VARCHAR(20) PRIMARY KEY
  , FIRST_NAME       VARCHAR(100) NOT NULL
  , LAST_NAME        VARCHAR(100) NOT NULL
  , GENDER           VARCHAR(10)
  , ADDRESS_ID       VARCHAR(20)
  , CONSTRAINT CH_PARENTS CHECK (GENDER IN ('M', 'F', 'Male', 'Female'))
  , CONSTRAINT FK_PARENTS_ADDR FOREIGN KEY(ADDRESS_ID) REFERENCES ADDRESS(ADDRESS_ID)
);

DROP TABLE IF EXISTS STUDENT_PARENT;
CREATE TABLE STUDENT_PARENT
(
    STUDENT_ID       VARCHAR(20)
  , PARENT_ID        VARCHAR(20)
  , CONSTRAINT UNQ_STDPARENT UNIQUE (STUDENT_ID, PARENT_ID)
  , FOREIGN KEY(STUDENT_ID) REFERENCES STUDENTS(ID)
  , FOREIGN KEY(PARENT_ID) REFERENCES PARENTS(ID)
);

select * from STUDENTS;
         
exec sp_rename 'STUDENTS.DOB','Date Of Birth', 'COLUMN';  

select id,FIRST_NAME + ' ' + LAST_NAME as Full_Name 
from STUDENTS;    

select * 
from SUBJECTS 
where SUBJECT_NAME = 'Mathematics';

select * 
from SUBJECTS 
where SUBJECT_NAME <> 'Mathematics';

select distinct SUBJECT_NAME 
from SUBJECTS;

select *
from STAFF_SALARY
where SALARY between 5000 and 10000
order by SALARY;

select * 
from SUBJECTS
where SUBJECT_NAME in ('Mathematics','Science','English');

select * 
from SUBJECTS
where SUBJECT_NAME not in ('Mathematics','Science','English');

select *
from SUBJECTS
where SUBJECT_NAME like ('%S');

select STAFF_ID,SALARY,
case
	when SALARY > 10000 then 'High Salary'
	when SALARY between 5000 and 10000 then 'Avg Salary'
	when SALARY < 5000 then 'Low Salary'
end as Range
from STAFF_SALARY
order by SALARY asc;

select cla.CLASS_NAME
from SUBJECTS as sub
join CLASSES as cla 
	on sub.SUBJECT_ID = cla.SUBJECT_ID
where sub.SUBJECT_NAME = 'Music';

select distinct stf.FIRST_NAME + ' ' + stf.LAST_NAME as Full_Name
from SUBJECTS as sub
join CLASSES as cla 
	on sub.SUBJECT_ID = cla.SUBJECT_ID
join STAFF as stf 
	on stf.STAFF_ID = cla.TEACHER_ID
where sub.SUBJECT_NAME = 'Mathematics';

select stf.FIRST_NAME + ' ' + stf.LAST_NAME as Full_Name,stf.AGE,stf.JOIN_DATE,stf.STAFF_TYPE,
case
	when stf.GENDER = 'M' then 'Male'
	when stf.GENDER = 'F' then 'Female'
end as Gender
from STAFF as stf
join CLASSES as cla 
	on stf.STAFF_ID = cla.TEACHER_ID
where stf.STAFF_TYPE = 'Teaching' and cla.CLASS_NAME in ('Grade 8','Grade 9','Grade 10')
union 
select stf.FIRST_NAME + ' ' + stf.LAST_NAME as Full_Name,stf.AGE,stf.JOIN_DATE,stf.STAFF_TYPE,
case
	when stf.GENDER = 'M' then 'Male'
	when stf.GENDER = 'F' then 'Female'
end as Gender
from STAFF as stf
where stf.STAFF_TYPE = 'Non-Teaching';      

select stc.CLASS_ID,COUNT(stc.STUDENT_ID) as 'Number_Of_Students'
from STUDENT_CLASSES as stc
group by stc.CLASS_ID
order by stc.CLASS_ID;

select stc.CLASS_ID,COUNT(stc.STUDENT_ID) as 'Number_Of_Students'
from STUDENT_CLASSES as stc
group by stc.CLASS_ID
having COUNT(stc.STUDENT_ID) > 100
order by stc.CLASS_ID;

select stp.PARENT_ID,par.FIRST_NAME + ' ' + par.LAST_NAME as Full_Name
,COUNT(stp.STUDENT_ID) as 'Number_Of_Children'
from STUDENT_PARENT as stp
join PARENTS as par 
	on stp.PARENT_ID = par.ID
group by stp.PARENT_ID,par.FIRST_NAME,par.LAST_NAME
having COUNT(stp.STUDENT_ID) > 1
order by 'Number_Of_Children' desc;
 
 
select (par.FIRST_NAME + ' ' + par.LAST_NAME) as Parent_Name,
	   (stu.FIRST_NAME + ' ' + stu.LAST_NAME) as Student_Name,
	   stu.AGE as Student_Age,
	   stu.GENDER as Student_Gender,
	   (ad.STREET + ', ' + ad.CITY + ', '+ ad.STATE + ', ' + ad.COUNTRY) as ADDRESS
from PARENTS as par
join STUDENT_PARENT as stp 
	on par.ID = stp.PARENT_ID
join STUDENTS as stu 
	on stu.ID = stp.STUDENT_ID
join ADDRESS as ad
	on par.ADDRESS_ID = ad.ADDRESS_ID
where par.ID in (	
					select stp.PARENT_ID
					from STUDENT_PARENT as stp
					group by stp.PARENT_ID
					having COUNT(stp.STUDENT_ID) > 1
					);

select avg(ss.SALARY) as 'Avg_Salary'
from STAFF_SALARY as ss
join STAFF as sta
	on ss.STAFF_ID = sta.STAFF_ID
where sta.STAFF_TYPE = 'Non-Teaching';

select round(avg(ss.SALARY),2) as 'Avg_Salary'
from STAFF_SALARY as ss
join STAFF as sta
	on ss.STAFF_ID = sta.STAFF_ID;

select sta.STAFF_TYPE,sum(ss.SALARY) as 'Tot_Salary'
from STAFF_SALARY as ss
join STAFF as sta
	on ss.STAFF_ID = sta.STAFF_ID
group by sta.STAFF_TYPE;

select (sta.FIRST_NAME + ' ' + sta.LAST_NAME) as Full_Name,sta.STAFF_TYPE,
sub.SUBJECT_NAME,cla.CLASS_NAME
from STAFF as sta
join CLASSES as cla 
	on sta.STAFF_ID = cla.TEACHER_ID
join SUBJECTS as sub 
	on sub.SUBJECT_ID = cla.SUBJECT_ID;

select distinct(sta.FIRST_NAME + ' ' + sta.LAST_NAME) as Full_Name,sta.STAFF_TYPE,
case
	when sub.SUBJECT_NAME is null and sta.STAFF_TYPE = 'Teaching' then 'Doesn''t teach '
	when sub.SUBJECT_NAME is null then 'Doesn''t teach '
	else sub.SUBJECT_NAME
end as SUBJECT_NAME,
sta.AGE,
year(CURRENT_TIMESTAMP)-year(sta.JOIN_DATE) as 'Tot_Year_Of_Work'
from STAFF as sta
left join CLASSES as cla 
	on sta.STAFF_ID = cla.TEACHER_ID
left join SUBJECTS as sub 
	on sub.SUBJECT_ID = cla.SUBJECT_ID
order by 'Tot_Year_Of_Work' desc;

select distinct(sta.FIRST_NAME + ' ' + sta.LAST_NAME) as Full_Name
,count(distinct cla.CLASS_NAME) as 'Number_Of_Classes'
,COUNT(distinct sub.subject_name) as 'Tot_Subject_Teaching'
,sub.SUBJECT_NAME
from STAFF as sta 
join CLASSES as cla
	on sta.STAFF_ID = cla.TEACHER_ID
join SUBJECTS as sub
	on sub.SUBJECT_ID = cla.SUBJECT_ID 
group by sta.FIRST_NAME,sta.LAST_NAME,sub.SUBJECT_NAME
order by 'Number_Of_Classes' desc;

select sta.STAFF_TYPE,sta.FIRST_NAME,ss.SALARY
,round(AVG(ss.SALARY) over (partition by sta.STAFF_TYPE),0) as 'Avg_Salary_per_StaffType'
from STAFF as sta 
join STAFF_SALARY as ss
	on sta.STAFF_ID = ss.STAFF_ID
group by sta.STAFF_TYPE,sta.FIRST_NAME,ss.SALARY;

with t1 as(
select sta.STAFF_TYPE,sta.FIRST_NAME,ss.SALARY
,round(AVG(ss.SALARY) over (partition by sta.STAFF_TYPE),0) as 'Avg_Salary_per_StaffType'
from STAFF as sta 
join STAFF_SALARY as ss
	on sta.STAFF_ID = ss.STAFF_ID
group by sta.STAFF_TYPE,sta.FIRST_NAME,ss.SALARY
)
select t1.*
,case 
	when SALARY < Avg_Salary_per_StaffType then 'Salary_Less_Than_Avg'
	when SALARY > Avg_Salary_per_StaffType then 'Salary_More_Than_Avg'
end as 'Salary_Detailes'
from t1;
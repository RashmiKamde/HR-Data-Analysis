SELECT * FROM [dbo].[employee_details];
SELECT * FROM [dbo].[department];
SELECT * FROM [dbo].[attendance];
SELECT * FROM [dbo].[performance];

-- Checking For is there any null value in dataset

SELECT * FROM employee_details WHERE Employee_ID = null;
SELECT * FROM department WHERE Department_ID = null;
SELECT * FROM attendance WHERE Employee_ID = null;
SELECT * FROM performance WHERE Employee_ID = null;

--Q1. Find the total number of employees in each department.

SELECT d.Department_Name,COUNT(e.Employee_ID) AS Total_Employees
FROM [dbo].[employee_details] e
JOIN  [dbo].[department] d 
ON e.Department_ID = d.Department_ID
GROUP BY d.Department_Name
ORDER BY Total_Employees DESC;

--Q2. Retrieve the top 5 highest-paid employees.
SELECT * FROM employee_details;

SELECT TOP 5 Employee_ID, First_Name,Last_Name,Department_ID,Email,Salary 
FROM employee_details
ORDER BY Salary DESC;

--Q3. Find employees who joined in the last 2 years.
--M1
SELECT Employee_ID, First_Name, Last_Name,Joining_Date
from employee_details
WHERE DATEDIFF(YEAR,Joining_Date,GETDATE()) <= 2;

--M2
SELECT Employee_ID, First_Name, Last_Name, Joining_Date
FROM employee_details
WHERE Joining_Date >= DATEADD(YEAR, -2, GETDATE());

--Q4. Count the number of days each employee was absent.

SELECT a.Employee_ID,ISNULL(e.First_Name,'N/A') AS First_Name,
       ISNULL(e.Last_Name,'N/A') AS Last_Name,COUNT(*) AS Absent_Days  
FROM attendance a
LEFT JOIN employee_details e ON e.Employee_ID = a.Employee_ID
WHERE Status = 'Absent' 
GROUP BY a.Employee_ID,e.First_Name,e.Last_Name
ORDER BY Absent_Days DESC,a.Employee_ID ASC;

--Q5. Find employees with the highest performance rating.

SELECT * FROM performance
-- Change datatype from int to varchar
ALTER TABLE performance 
ALTER COLUMN Promotion_Eligible VARCHAR(3);  -- Convert to text type

--Update column Promotion_Eligible
UPDATE performance
SET Promotion_Eligible = 'No'
WHERE Promotion_Eligible = '0';

UPDATE performance
SET Promotion_Eligible = 'Yes'
WHERE Promotion_Eligible = '1';

UPDATE performance
SET Promotion_Eligible = CASE 
                         WHEN Performance_Rating = 5 THEN 'Yes' 
						 ELSE 'No' 
						 END;


 -- employees with the highest performance rating.

 SELECT p.Employee_ID,e.First_Name,e.Last_Name,d.Department_Name
 FROM performance p 
 JOIN employee_details e ON e.Employee_ID = p.Employee_ID
 JOIN department d ON d.Department_ID = e.Department_ID
 WHERE Performance_Rating = 5;

 --Q6 Get the list of employees eligible for promotion.
--M1
SELECT First_Name, Last_Name, Department_ID
FROM Employee_Details 
WHERE Employee_ID IN (SELECT Employee_ID 
                      FROM Performance 
					  WHERE Promotion_Eligible = 'Yes');
--M2
SELECT First_Name, Last_Name, Department_ID
FROM Employee_Details e
WHERE EXISTS (SELECT * 
              FROM Performance p 
			  WHERE Promotion_Eligible = 'Yes' 
			  AND e.Employee_ID = p.Employee_ID );

--Q7. Retrieve employee names along with their department names.

SELECT e.First_Name, e.Last_Name,d.Department_Name
FROM employee_details e
JOIN department d ON e.Department_ID = d.Department_ID;

--Q8. Identify employees who do not have attendance records.
SELECT * FROM employee_details

--M1
SELECT e.Employee_ID,e.First_Name, e.Last_Name
FROM employee_details e
WHERE Employee_ID NOT IN (SELECT Employee_ID FROM attendance a);

--M2
SELECT e.Employee_ID,e.First_Name, e.Last_Name
FROM employee_details e
WHERE NOT EXISTS (SELECT * FROM attendance a WHERE a.Employee_ID = e.Employee_ID);

--M3
SELECT e.Employee_ID,e.First_Name, e.Last_Name
FROM employee_details e
LEFT JOIN attendance a ON e.Employee_ID = a.Employee_ID
WHERE a.Employee_ID IS NULL;

--Q9. Get the average salary of employees for each department.

SELECT d.Department_Name,AVG(e.Salary) AS Average_Salary
FROM employee_details e
LEFT JOIN department d ON e.Department_ID = d.Department_ID
GROUP BY d.Department_Name
ORDER BY Average_Salary DESC; 
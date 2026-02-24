--Exercise 10
SELECT role, MAX(years_employed) AS longest_time FROM employees;

SELECT role, AVG(years_employed) AS average_years FROM employees
GROUP BY role;

SELECT building, SUM(years_employed) AS years_worked FROM employees
GROUP BY building;


--Exercise 11
SELECT role, COUNT(*) AS num_artist FROM employees
WHERE role = "Artist";

SELECT role, COUNT(*) AS employees_role FROM employees
GROUP BY role;

SELECT role, SUM(years_employed) FROM employees
GROUP BY role
HAVING role = "Engineer";
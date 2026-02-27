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


-- three try-it from freesql.com
select count(distinct shape) number_of_shapes,
       stddev(distinct weight) distinct_weight_stddev
from   bricks;

select shape, sum(weight) shape_weight
from   bricks
group by shape;

select shape, sum ( weight )
from   bricks
having sum(weight)<4
group  by shape;
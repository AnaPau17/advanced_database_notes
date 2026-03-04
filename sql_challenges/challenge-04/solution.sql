-- freesql.com
select b.*,
       count(*) over (
         partition by shape
       ) bricks_per_shape,
       median ( weight ) over (
         partition by shape
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;


select b.brick_id, b.weight,
       round ( avg ( weight ) over (
         order by brick_id 
       ), 2 ) running_average_weight
from   bricks b
order  by brick_id;


select b.*,
       min ( colour ) over (
         order by brick_id
         rows between 2 preceding and 1 preceding
       ) first_colour_two_prev,
       count (*) over (
         order by weight
         range between current row and 1 following
       ) count_values_this_and_next
from   bricks b
order  by weight;


with totals as (
  select b.*,
         sum ( weight ) over (
           partition by shape
         ) weight_per_shape,
         sum ( weight ) over (
           order by brick_id
         ) running_weight_by_id
  from   bricks b
)
select * from totals
where brick_id>4
order  by brick_id;


-- datalemur
WITH ranking_salary AS (
  SELECT department_id, name, salary,
      DENSE_RANK() OVER (
        PARTITION BY department_id ORDER BY salary DESC) AS ranking
  FROM employee
)
SELECT department.department_name, ranking_salary.name, ranking_salary.salary
FROM ranking_salary
INNER JOIN department
  ON ranking_salary.department_id = department.department_id
WHERE ranking_salary.ranking <= 3
ORDER BY department.department_name ASC, ranking_salary.salary DESC, ranking_salary.name ASC;
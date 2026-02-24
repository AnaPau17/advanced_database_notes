--Exercise 6
SELECT movies.id, movies.title, boxoffice.domestic_sales, boxoffice.international_sales FROM movies 
INNER JOIN boxoffice 
    ON movies.id = boxoffice.movie_id;


SELECT movies.id, movies.title, boxoffice.domestic_sales, boxoffice.international_sales FROM movies 
INNER JOIN boxoffice 
    ON movies.id = boxoffice.movie_id
WHERE boxoffice.domestic_sales < boxoffice.international_sales;


SELECT movies.id, movies.title, boxoffice.rating FROM movies 
INNER JOIN boxoffice 
    ON movies.id = boxoffice.movie_id
    ORDER BY rating DESC;


--Exercise 7
SELECT * FROM buildings 
INNER JOIN employees 
    ON buildings.building_name = employees.building
GROUP BY buildings.building_name;


SELECT * FROM buildings;


SELECT buildings.building_name, employees.role FROM buildings 
LEFT JOIN employees 
    ON buildings.building_name = employees.building
GROUP BY employees.role, buildings.building_name;


-- interviw question
SELECT pages.page_id FROM pages
LEFT JOIN page_likes
 ON pages.page_id = page_likes.page_id
WHERE page_likes.page_id IS NULL
ORDER BY page_id;
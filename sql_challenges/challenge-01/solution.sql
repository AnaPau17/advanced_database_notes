--Exercise 1
SELECT Title FROM movies;
SELECT director FROM movies;
SELECT title, director FROM movies;
SELECT title, year FROM movies;
SELECT * FROM movies;

--Exercise 2
SELECT title, id FROM movies WHERE id=6;
SELECT title, year FROM movies WHERE year BETWEEN 2000 AND 2010;
SELECT title, year FROM movies WHERE year NOT BETWEEN 2000 AND 2010;
SELECT title, year FROM movies WHERE id<=5;

--Exercise 3
SELECT title FROM movies WHERE title LIKE "Toy Story%";
SELECT title FROM movies WHERE director="John Lasseter";
SELECT title, director FROM movies WHERE director!="John Lasseter";
SELECT title FROM movies WHERE title LIKE "WALL-%"

--Exercise 4
SELECT DISTINCT director FROM movies ORDER BY director ASC;
SELECT title FROM movies ORDER BY year DESC LIMIT 4;
SELECT title FROM movies ORDER BY title ASC LIMIT 5;
SELECT title FROM movies ORDER BY title ASC LIMIT 5 OFFSET 5;

--Exercise 5
SELECT city, population FROM north_american_cities WHERE country="Canada";
SELECT city FROM north_american_cities WHERE country="United States" ORDER BY latitude DESC;
SELECT city, longitude FROM north_american_cities WHERE longitude < -87.629798 ORDER BY longitude ASC;
SELECT city, population FROM north_american_cities WHERE country="Mexico" ORDER BY population DESC LIMIT 2;
SELECT city, population FROM north_american_cities WHERE country="United States" ORDER BY population DESC LIMIT 2 OFFSET 2;
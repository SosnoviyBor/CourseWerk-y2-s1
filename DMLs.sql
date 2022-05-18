-- 1. Кількість замовлень кожного контрагента
SELECT c.*, count(c.id) AS order_amount
FROM contragent c
INNER JOIN orders o ON c.id = o.contragent_id
GROUP BY c.id
ORDER BY order_amount DESC;

-- 2. Кількість прийнятих замовлень кожного з кораблів
SELECT s.*, COUNT(s.id) AS orders_taken
FROM ships s
INNER JOIN trips t ON s.id = t.ship_id
INNER join orders o ON t.id = o.trip_id
GROUP BY s.id;

-- 3. Кількість прийнятих замовлень кожним з працівників кол-центру
SELECT e.*, COUNT(e.id) AS orders_taken
FROM employees e
INNER JOIN trips t ON e.id = t.employee_id
INNER join orders o ON t.id = o.trip_id
WHERE e.position_id != 7
GROUP BY e.id;

-- 4. Кількість прийнятих замовлень кожним з працівників екіпажу кораблів
SELECT c.*, COUNT(c.person_id) AS orders_done
FROM crews c
INNER JOIN trips t ON c.team_id = t.crew_id
INNER JOIN orders o ON t.id = o.trip_id
GROUP BY c.person_id;

-- 5. Популярність грузових тарифів за попередній місяць
SELECT t.*, COUNT(t.id) AS times_chosen
FROM tariffs t
INNER JOIN cargo c ON t.id = c.tariff_id
INNER JOIN orders o ON c.id = o.cargo_id
WHERE MONTH(o.time_ordered) = MONTH(NOW())-1
GROUP BY t.id
ORDER BY times_chosen DESC;

-- 6. Кількість відвідувань портів за цей рік
SELECT p.*, COUNT(p.id) AS times_visited
FROM ports p
INNER JOIN route_sequence rs ON p.id = rs.port_id
INNER JOIN route r ON rs.id = r.sequence_id
INNER JOIN trips t ON r.id = t.route_id
INNER JOIN orders o ON t.id = o.trip_id
WHERE YEAR(o.time_ordered) = YEAR(NOW())
GROUP BY p.id  
ORDER BY times_visited DESC;

-- 7. Загальна вартість замовлень контрагентів за цей рік
SELECT c.*, SUM(getFullCargoCost(o.cargo_id)) AS total_income
FROM contragent c
INNER JOIN orders o ON c.id = o.contragent_id
WHERE YEAR(o.time_ordered) = YEAR(NOW())
GROUP BY c.id  
ORDER BY total_income DESC;

-- 8. Кількість перевезених контейнерів кожного контрагента за цей рік
SELECT c.*, SUM(ca.amount) AS total_containers
FROM contragent c
INNER JOIN orders o ON c.id = o.contragent_id
INNER JOIN cargo ca ON ca.id = o.cargo_id
WHERE YEAR(o.time_ordered) = YEAR(NOW())
GROUP BY c.id  
ORDER BY total_containers DESC;

-- 9. Витрати на зарплатню офісних робітників компанії за цей рік
SELECT SUM(j.salary) AS total_employee_salary
FROM orders o
INNER JOIN trips t ON t.id = o.trip_id
INNER JOIN employees e ON e.id = t.employee_id
INNER JOIN jobs j ON j.id = e.position_id
WHERE YEAR(o.time_ordered) = YEAR(NOW());

-- 10. Витрати на зарплатню корабельних робітників компанії за цей рік
SELECT SUM(j.salary) AS total_crew_salary
FROM (
    SELECT t.*
    FROM trips t
    INNER JOIN orders o ON t.id = o.trip_id
    WHERE YEAR(o.time_ordered) = YEAR(NOW())
    GROUP BY o.trip_id
) t
INNER JOIN crews c ON c.team_id = t.crew_id
INNER JOIN jobs j ON j.id = c.post_id;

-- 11. Список корабельних робітників, що мають у імені або прізвищі літеру "J" та народилися до 2000 року
SELECT p.*
FROM crews c
INNER JOIN persons p ON p.id = c.person_id
WHERE LOWER(getFullName(p.id)) LIKE "%j%" AND YEAR(p.date_of_birth) < 2000;

-- 12. Історія відвіданих портів робітником Joeseph Joestar
SELECT p.name, p.surname, t.id AS trip_id, po.id AS port_id, co.name AS country, po.city
FROM persons p
INNER JOIN crews c ON p.id = c.person_id
INNER JOIN trips t ON c.team_id = t.crew_id
INNER JOIN route r ON r.id = t.route_id
INNER JOIN route_sequence rs ON rs.id = r.sequence_id
INNER JOIN ports po ON po.id = rs.port_id
INNER join countries co ON co.id = po.country_id
WHERE getFullName(p.id) = "Joeseph Joestar";

-- 13. Працівники, що мають поштові скриньки від сервісів azwv або emailaing
SELECT p.id AS p_id, e.id AS e_id, getFullName(p.id) AS full_name, o.name AS office_name, j.name AS position, p.email
FROM employees e
INNER JOIN persons p ON p.id = e.person_id
INNER JOIN jobs j ON j.id = e.position_id
INNER JOIN offices o ON o.id = e.office_id
WHERE p.email LIKE "%@azwv.%" OR p.email LIKE  "%@emailaing.%";

-- 14. Порт, на якому найчастіше загружають вантаж
SELECT p.id AS port_id, co.name AS country, p.city, count(c.src_id) AS times_loaded_on
FROM cargo c
INNER JOIN ports p ON p.id = c.src_id
INNER JOIN countries co ON co.id = p.country_id
GROUP BY p.id
ORDER BY count(c.src_id) DESC
LIMIT 1;

-- 15. Топ-5 найбільш відвіданих країн кораблями компанії
SELECT c.*, COUNT(c.id) AS times_visited
FROM trips t
INNER JOIN orders o ON t.id = o.trip_id
INNER JOIN route r ON r.id = t.route_id
INNER JOIN route_sequence rs ON rs.id = r.sequence_id
INNER JOIN ports p ON p.id = rs.port_id
INNER JOIN countries c ON c.id = p.country_id
WHERE YEAR(o.time_delivered) = YEAR(NOW())
GROUP BY c.id
ORDER BY COUNT(c.id) DESC
LIMIT 5;

-- 16. Кількість працівників конкретних спеціальностей у мореплавчих командах
SELECT c.team_id, j.*, COUNT(c.post_id) AS amount
FROM crews c
INNER JOIN jobs j ON j.id = c.post_id
GROUP BY c.post_id, c.team_id
ORDER BY j.id DESC;

-- 17. Кількість працівників конкретних спеціальностей у офісах
SELECT e.office_id, j.*, COUNT(e.position_id) AS amount
FROM employees e
INNER JOIN jobs j ON j.id = e.position_id
GROUP BY e.position_id, e.office_id
ORDER BY j.id DESC;

-- 18. Популярність тарифів серед контрагентів
SELECT c.company, t.name AS tariff, COUNT(t.id) AS times_taken, SUM(ca.amount) AS sum_amount
FROM contragent c
INNER JOIN orders o ON c.id = o.contragent_id
INNER JOIN cargo ca ON ca.id = o.cargo_id
INNER JOIN tariffs t ON t.id = ca.tariff_id
GROUP BY c.id, t.id
ORDER BY c.id DESC, COUNT(t.id) DESC;

-- 19. Топ-3 найстарші корабельних працівники
SELECT getFullName(p.id) AS full_name, j.name AS post, j.salary, p.date_of_birth, DATEDIFF(NOW(), p.date_of_birth) DIV 365 AS age
FROM crews c
INNER JOIN persons p ON p.id = c.person_id
INNER JOIN jobs j ON j.id = c.post_id
ORDER BY DATEDIFF(NOW(), p.date_of_birth) DESC
LIMIT 3;

-- 20. Топ-3 міста, у яких проживає найбільша кількість корабельних працівники
SELECT p.city, COUNT(p.city) AS crewmembers_from
FROM crews c
INNER JOIN persons p ON p.id = c.person_id
GROUP BY p.city
ORDER BY COUNT(p.city) DESC
LIMIT 3;
-- Ejercicios que he hecho en SQL Practice Online (desde lo mas basico hasta distintos tipos de joins)
-- Por Juan Camilo Cabarcas Roso
-- 01. Todos los empleados
SELECT *
FROM employees;

-- 02. Nombre, apellido y salario de los empleados
SELECT first_name, last_name, salary
FROM employees;

-- 03. Empleados del departamento 50 con salario mayor a 3000
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE department_id = 50
  AND salary > 3000;

-- 04. Empleados contratados desde 2005, ordenados del mas reciente al mas antiguo
SELECT employee_id, first_name, last_name, hire_date
FROM employees
WHERE hire_date >= DATE '2005-01-01'
ORDER BY hire_date DESC;

-- 05. Empleados cuyo apellido empieza con 'K' o que ganan entre 8000 y 10000
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE last_name LIKE 'K%'
   OR salary BETWEEN 8000 AND 10000
ORDER BY salary DESC;

-- 06. Total de empleados, salario promedio, minimo y maximo
SELECT COUNT(*)    AS total_empleados,
       AVG(salary) AS salario_promedio,
       MIN(salary) AS salario_minimo,
       MAX(salary) AS salario_maximo
FROM employees;

-- 07. Cantidad de empleados por departamento (por id)
SELECT department_id,
       COUNT(*) AS total_empleados
FROM employees
GROUP BY department_id
ORDER BY total_empleados DESC;

-- 08. Departamentos con mas de 5 empleados y su salario promedio
SELECT department_id,
       COUNT(*)    AS total_empleados,
       AVG(salary) AS salario_promedio
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5
ORDER BY salario_promedio DESC;

-- 09. Nomina total (salario + comision) por cargo (job_id)
SELECT job_id,
       SUM(salary + salary * NVL(commission_pct, 0)) AS nomina_total
FROM employees
GROUP BY job_id
ORDER BY nomina_total DESC;
-- Nota: en PostgreSQL/MySQL reemplazar NVL por COALESCE.

-- 10. Cantidad de empleados contratados por anio
SELECT EXTRACT(YEAR FROM hire_date) AS anio_contratacion,
       COUNT(*)                     AS total_contratados
FROM employees
GROUP BY EXTRACT(YEAR FROM hire_date)
ORDER BY anio_contratacion;

-- 11. INNER JOIN basico: empleado y nombre de su departamento
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       d.department_name
FROM employees e
INNER JOIN departments d
        ON e.department_id = d.department_id;

-- 12. INNER JOIN con filtro: empleados y su cargo (titulo) con salario > 10000
SELECT e.first_name,
       e.last_name,
       j.job_title,
       e.salary
FROM employees e
INNER JOIN jobs j
        ON e.job_id = j.job_id
WHERE e.salary > 10000
ORDER BY e.salary DESC;

-- 13. INNER JOIN de 3 tablas: empleado, departamento y ciudad
SELECT e.first_name,
       e.last_name,
       d.department_name,
       l.city
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN locations   l ON d.location_id   = l.location_id
ORDER BY l.city, d.department_name;

-- 14. INNER JOIN de 5 tablas: empleado -> departamento -> ciudad -> pais -> region
SELECT e.first_name || ' ' || e.last_name AS empleado,
       d.department_name                  AS departamento,
       l.city                             AS ciudad,
       c.country_name                     AS pais,
       r.region_name                      AS region
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN locations   l ON d.location_id   = l.location_id
INNER JOIN countries   c ON l.country_id    = c.country_id
INNER JOIN regions     r ON c.region_id     = r.region_id
ORDER BY r.region_name, c.country_name, empleado;

-- 15. INNER JOIN + GROUP BY: salario promedio y empleados por pais
SELECT c.country_name,
       COUNT(e.employee_id) AS total_empleados,
       ROUND(AVG(e.salary), 2) AS salario_promedio
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN locations   l ON d.location_id   = l.location_id
INNER JOIN countries   c ON l.country_id    = c.country_id
GROUP BY c.country_name
ORDER BY salario_promedio DESC;


-- 16. LEFT JOIN: todos los empleados, incluso los SIN departamento
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       d.department_name
FROM employees e
LEFT JOIN departments d
       ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- 17. LEFT JOIN + IS NULL (anti-join): empleados sin departamento asignado
SELECT e.employee_id,
       e.first_name,
       e.last_name
FROM employees e
LEFT JOIN departments d
       ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- 18. RIGHT JOIN: todos los departamentos, tengan o no empleados
SELECT d.department_id,
       d.department_name,
       e.employee_id,
       e.last_name
FROM employees e
RIGHT JOIN departments d
        ON e.department_id = d.department_id
ORDER BY d.department_id;

-- 19. RIGHT JOIN + IS NULL: departamentos SIN ningun empleado
SELECT d.department_id,
       d.department_name
FROM employees e
RIGHT JOIN departments d
        ON e.department_id = d.department_id
WHERE e.employee_id IS NULL
ORDER BY d.department_id;

-- 20. LEFT JOIN + GROUP BY: cantidad de empleados por departamento,
--     incluyendo departamentos con 0 empleados
SELECT d.department_name,
       COUNT(e.employee_id) AS total_empleados
FROM departments d
LEFT JOIN employees e
       ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY total_empleados DESC, d.department_name;

-- 21. FULL OUTER JOIN: empleados y departamentos, mostrando lo que no tiene pareja
SELECT e.employee_id,
       e.last_name,
       d.department_id,
       d.department_name
FROM employees e
FULL OUTER JOIN departments d
             ON e.department_id = d.department_id
ORDER BY d.department_id, e.employee_id;

-- 22. FULL OUTER JOIN filtrado: SOLO las filas sin coincidencia en alguno de los lados
SELECT e.employee_id,
       e.last_name,
       d.department_id,
       d.department_name
FROM employees e
FULL OUTER JOIN departments d
             ON e.department_id = d.department_id
WHERE e.employee_id IS NULL
   OR d.department_id IS NULL;

-- 23. CROSS JOIN: producto cartesiano entre regiones y cargos que empiezan con 'AD'
SELECT r.region_name,
       j.job_title
FROM regions r
CROSS JOIN jobs j
WHERE j.job_id LIKE 'AD%'
ORDER BY r.region_name, j.job_title;

-- 24. SELF JOIN: cada empleado con el nombre de su jefe
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name  AS empleado,
       m.first_name || ' ' || m.last_name  AS jefe
FROM employees e
LEFT JOIN employees m
       ON e.manager_id = m.employee_id
ORDER BY jefe, empleado;

-- 25. NON-EQUI JOIN: empleados cuyo salario esta fuera del rango permitido de su cargo
SELECT e.employee_id,
       e.last_name,
       j.job_title,
       e.salary,
       j.min_salary,
       j.max_salary
FROM employees e
INNER JOIN jobs j
        ON e.job_id = j.job_id
       AND (e.salary < j.min_salary OR e.salary > j.max_salary);

-- 26. SELF JOIN: empleados que ganan MAS que su jefe
SELECT e.last_name   AS empleado,
       e.salary      AS salario_empleado,
       m.last_name   AS jefe,
       m.salary      AS salario_jefe
FROM employees e
INNER JOIN employees m
        ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- 27. JOIN con USING y NATURAL JOIN
SELECT department_id,
       d.department_name,
       e.last_name
FROM employees e
INNER JOIN departments d USING (department_id)
ORDER BY department_id;

--     b) NATURAL JOIN (une por TODAS las columnas con el mismo nombre;
SELECT department_id,
       department_name,
       last_name
FROM employees
NATURAL JOIN departments;

-- 28. JOIN con job_history: historial de cargos con nombre del cargo y departamento
SELECT e.first_name || ' ' || e.last_name AS empleado,
       j.job_title                        AS cargo_anterior,
       d.department_name                  AS departamento_anterior,
       jh.start_date,
       jh.end_date
FROM job_history jh
INNER JOIN employees   e ON jh.employee_id   = e.employee_id
INNER JOIN jobs        j ON jh.job_id        = j.job_id
INNER JOIN departments d ON jh.department_id = d.department_id
ORDER BY empleado, jh.start_date;

-- 29. Mezcla de LEFT JOINs: ubicacion completa de TODOS los departamentos,
SELECT d.department_name,
       l.city,
       c.country_name,
       m.first_name || ' ' || m.last_name AS jefe_departamento,
       COUNT(e.employee_id)               AS total_empleados
FROM departments d
LEFT JOIN locations l ON d.location_id   = l.location_id
LEFT JOIN countries c ON l.country_id    = c.country_id
LEFT JOIN employees m ON d.manager_id    = m.employee_id
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name,
         l.city,
         c.country_name,
         m.first_name,
         m.last_name
ORDER BY total_empleados DESC, d.department_name;


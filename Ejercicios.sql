-- Comandos consola:
-- Iniciar base de datos: sudo service postgresql start
-- psql -U vscode -d linkedin
-- psql -h ip_servidor -U usuario -d base_de_datos
-- psql linkedin
-- \l -> list databases
-- \d -> list tables
-- \d table_name -> describe table
-- \x -> toggle expanded output
-- Para ejecutar el script: nos movemos al directorio donde está guardado el script con cd y luego ejecutamos psql linkedin -f "02_01/insertorderrecords.sql" 


-- 1 CREATING A TABLE

-- Mi solución
DROP TABLE IF EXISTS public.customers CASCADE;
CREATE TABLE public.customers (
  customer_id varchar(200) NOT NULL,
  first_name varchar(100) NULL,
  last_name varchar(100) NULL,
  username varchar(15) NULL,
  "password" varchar(20) NOT NULL,
  email varchar(320) NULL,
  account_creation_date timestamp NULL,
  CONSTRAINT customers_pkey PRIMARY KEY (customer_id),
  CONSTRAINT customers_customer_id_key UNIQUE (customer_id),
  CONSTRAINT customers_username_key UNIQUE (username),
  CONSTRAINT customers_email_key UNIQUE (email)
);

-- Solución final
DROP TABLE IF EXISTS public.customers CASCADE;
CREATE TABLE public.customers (
  customer_id serial PRIMARY KEY,
  firstname varchar(100) NOT NULL,
  lastname varchar(100) NOT NULL,
  username varchar(50) UNIQUE NOT NULL,
  "password" varchar(50) NOT NULL,
  email varchar(255) UNIQUE NOT NULL,
  created_on TIMESTAMPTZ NULL
);

-- 2 INSERTING DATA
-- Separados
TRUNCATE public.customers RESTART IDENTITY CASCADE;
INSERT INTO public.customers
(customer_id, firstname, lastname, username, "password", email, created_on)
VALUES(nextval('customers_customer_id_seq'::regclass), 'Pepito', 'Perez', 'pperez', 'pepito12345678', 'ppchuru@hotmail.com', NOW());
INSERT INTO public.customers
(firstname, lastname, username, "password", email, created_on)
VALUES('Fulanita', 'De Tal', 'fulanitalamasbonita', 'fulanita12345678', 'fulanita@hotmail.com', CURRENT_TIMESTAMP AT TIME ZONE 'Europe/Madrid');
-- juntos
INSERT INTO public.customers
(firstname, lastname, username, "password", email, created_on)
VALUES('Juanita', 'Banana', 'jeanbananas', 'jb123456', 'jb@gmail.com', '2023-12-12 15:20:00'),
('Menganito', 'García', 'MG_Master', 'mg123456', 'mg@outlook.com', CURRENT_TIMESTAMP);

-- Solución final
INSERT INTO public.customers
(firstname, lastname, username, "password", email, created_on)
VALUES('Elisabeth', 'Banks', 'elisabethbanks', '4s$5eks9m', 'elisabethbanks@myemail.com', CURRENT_TIMESTAMP);

INSERT INTO public.customers
(firstname, lastname, username, "password", email, created_on)
VALUES('Nicole', 'Kidman', 'nkidman', '39*2kMLK!m', 'nicole@kidman.com', CURRENT_TIMESTAMP),
('Leroy', 'Jenkins', 'leeroy', '4k21n@Lm', 'leroy@email.com', CURRENT_TIMESTAMP);

-- 3 UPDATING DATA
UPDATE public.customers 
SET firstname = 'Pepita' 
WHERE email = 'ppchuru@hotmail.com';

SELECT * 
FROM public.customers 
WHERE email = 'ppchuru@hotmail.com';

SELECT * 
FROM public.customers 
WHERE name = 'Pepita';

-- Solución final
UPDATE public.customers 
SET firstname = 'aliceinwonderland' 
WHERE email = 'elisabethbanks@myemail.com';


-- 4 LOCATING DATABASE RECORDS
SELECT * 
FROM public.customers 
WHERE email LIKE '%@hotmail.com%';

-- create a table from records
CREATE TABLE public.customers_hotmail AS 
SELECT * 
FROM public.customers 
WHERE email LIKE '%@hotmail.com%';

-- 5 SORTING DATABASE RECORDS
SELECT firstname, lastname
FROM public.customers
ORDER BY lastname DESC;

SELECT CONCAT(firstname, ' ', lastname) AS fullname, email
FROM public.customers
WHERE LENGTH("password") < 12
ORDER BY LENGTH("password") ASC;

-- 6 DELETING DATABASE RECORDS
DELETE FROM public.customers
WHERE email LIKE '%@hotmail.com%';

DELETE FROM public.customers
WHERE firstname LIKE '%uanita%';

DELETE FROM public.customers
RETURNING *;

-- 7 CREATING A NEW READ-ONLY USER
CREATE USER solover WITH PASSWORD 'soloveo12345678' VALID UNTIL '2023-03-12';
GRANT pg_read_all_data TO solover;

-- 8 CREATING A TABLE USING A FOREIGN KEY

-- Mi solución
DROP TABLE IF EXISTS public.orders CASCADE;
CREATE TABLE public.orders (
  order_id serial PRIMARY KEY,
  purchase_total NUMERIC NOT NULL CHECK (purchase_total = ROUND(purchase_total::numeric, 2)),
  customer_id INT NOT NULL,
  "timestamp" TIMESTAMPTZ NOT NULL,
  CONSTRAINT order_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers (customer_id)
);

-- Solución final
DROP TABLE IF EXISTS public.orders CASCADE;
CREATE TABLE public.orders (
  order_id serial PRIMARY KEY,
  purchase_total NUMERIC NOT NULL,
  "timestamp" TIMESTAMPTZ NOT NULL,
  customer_id INT REFERENCES customers(customer_id) 
  ON DELETE CASCADE
);

-- Otra solución
DROP TABLE IF EXISTS public.orders CASCADE;
CREATE TABLE public.orders (
  order_id serial PRIMARY KEY,
  purchase_total NUMERIC NOT NULL CHECK (purchase_total = ROUND(purchase_total::numeric, 2)),
  "timestamp" TIMESTAMPTZ NOT NULL,
  customer_id INT REFERENCES customers(customer_id) 
  ON DELETE CASCADE
);

DELETE FROM public.customers
WHERE customer_id = 4
RETURNING *;

-- 9 IDENTIFYING TRANSACTION TOTALS PER CUSTOMER
--Ordenar
SELECT c.customer_id, c.firstname, c.lastname, SUM(o.purchase_total) AS total
FROM public.customers c
JOIN public.orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.firstname, c.lastname
ORDER BY total DESC;

-- solo el máximo
SELECT customer_id, MAX(purchase_total) AS top_order_amt
FROM public.orders
GROUP BY customer_id
ORDER BY top_order_amt DESC;

-- TOP 2
SELECT customer_id, SUM(purchase_total::NUMERIC)
FROM public.orders
GROUP BY customer_id
ORDER BY sum DESC LIMIT 2;

-- 10 USING SUBQUERIES TO INSERT RECORDS
-- Mi solución
DELETE FROM public.orders
WHERE purchase_total = 50.50
AND customer_id = (SELECT customer_id FROM public.customers WHERE email = 'kdiamond@myemail.com')
RETURNING *;
INSERT INTO public.orders
(purchase_total, customer_id, "timestamp")
VALUES(50.50, (SELECT customer_id FROM public.customers WHERE email = 'kdiamond@myemail.com'), CURRENT_TIMESTAMP AT TIME ZONE 'Europe/Madrid');

-- Solución final
DELETE FROM public.orders
WHERE purchase_total = 50.50
AND customer_id = (SELECT customer_id FROM public.customers WHERE email = 'kdiamond@myemail.com')
RETURNING *;
INSERT INTO public.orders
(purchase_total, customer_id, "timestamp")
VALUES(50.50, (SELECT customer_id FROM public.customers WHERE email = 'kdiamond@myemail.com'), '2023-06-01 08:01:31.876335-07');

-- 11 HANDLING DUPLICATE RECORDS
-- Se insertan registros duplicados
ALTER TABLE public.customers
DROP CONSTRAINT customers_email_key;

INSERT INTO public.customers
(firstname, lastname, username, "password", email, created_on)
VALUES
('Menganita', 'García', 'MG_Mistress', 'mg123456', 'mg@outlook.com', CURRENT_TIMESTAMP), 
('Juanito', 'Banana', 'johnbananas', 'jb123456', 'jb@gmail.com', '2023-12-12 15:20:00');

-- Esos clientes hacen pedidos y se registra el nuevo customer_id en la tabla orders
INSERT INTO public.orders
(purchase_total, customer_id, "timestamp")
VALUES
(750, (SELECT customer_id FROM public.customers WHERE firstname = 'Menganita'), CURRENT_TIMESTAMP AT TIME ZONE 'Europe/Madrid'),
(850, (SELECT customer_id FROM public.customers WHERE firstname = 'Juanito'), CURRENT_TIMESTAMP AT TIME ZONE 'Europe/Madrid');

-- Otro cliente cambia su nombre y hace pedido
INSERT INTO public.customers
(firstname, lastname, username, "password", email, created_on)
VALUES
('John', 'Banana', 'jbananas', 'jb123456', 'jb@gmail.com', NOW());

INSERT INTO public.orders
(purchase_total, customer_id, "timestamp")
VALUES
(900, (SELECT customer_id FROM public.customers WHERE firstname = 'John'), CURRENT_TIMESTAMP AT TIME ZONE 'Europe/Madrid');

-- Se actualizan los registros duplicados en la tabla orders con el número de customer_id antiguo
UPDATE public.orders o
SET customer_id = (SELECT customer_id
    			FROM (SELECT cu.customer_id, cu.email, ROW_NUMBER() 
                              OVER (PARTITION BY cu.email ORDER BY cu.customer_id) AS row_number
        			FROM public.customers cu
        			JOIN (SELECT email, COUNT(email) AS count
            			FROM public.customers
                              GROUP BY email
                              HAVING COUNT(email) > 1) as co 
                        ON cu.email = co.email)duplicates
                  WHERE email = c.email AND row_number = 1)
    FROM public.customers c
WHERE o.customer_id = c.customer_id AND o.customer_id IN (SELECT customer_id
                                                          FROM (SELECT cu.customer_id, cu.email, ROW_NUMBER() 
                                                                        OVER (PARTITION BY cu.email ORDER BY cu.customer_id) AS row_number
                                                                FROM public.customers cu
                                                                JOIN (SELECT email, COUNT(email) AS count
                                                                      FROM public.customers
                                                                      GROUP BY email
                                                                      HAVING COUNT(email) > 1) as co 
                                                                ON cu.email = co.email) duplicates
                                                          WHERE row_number > 1);

-- Se eliminan los registros duplicados en la tabla customers
DELETE
FROM public.customers
WHERE customer_id in (SELECT customer_id
                      FROM (SELECT cu.customer_id, cu.email, ROW_NUMBER() 
                                    OVER (PARTITION BY cu.email ORDER BY cu.customer_id) AS row_number
                            FROM public.customers cu
                            JOIN (SELECT email, COUNT(email) AS count
                                  FROM public.customers
                                  GROUP BY email
                                  HAVING COUNT(email) > 1) as co
                            ON cu.email = co.email)duplicates
                      WHERE row_number > 1)
RETURNING *;


-- Se actualizan los registros duplicados en la tabla orders con el número de customer_id nuevo

UPDATE public.orders o
SET customer_id = (SELECT customer_id
                  FROM (SELECT customer_id, cu.email, num_reg, ROW_NUMBER() 
                                    OVER (PARTITION BY cu.email ORDER BY cu.customer_id) AS row_number
                        FROM public.customers cu
                        JOIN (SELECT email, COUNT(email) as num_reg
                              FROM public.customers          
                              GROUP BY email)e
                        ON cu.email = e.email)duplicates
                  WHERE email = c.email AND row_number = num_reg AND num_reg > 1)
    FROM public.customers c
WHERE o.customer_id = c.customer_id AND o.customer_id IN (SELECT customer_id
                                                          FROM (SELECT customer_id, cu.email, num_reg, ROW_NUMBER() 
                                                                        OVER (PARTITION BY cu.email ORDER BY cu.customer_id) AS row_number
                                                                FROM public.customers cu
                                                                JOIN (SELECT email, COUNT(email) as num_reg
                                                                      FROM public.customers          
                                                                      GROUP BY email)e
                                                                ON cu.email = e.email)duplicates
                                                          WHERE row_number < num_reg);


                                                          
-- Se eliminan los registros duplicados en la tabla customers
DELETE
FROM public.customers
WHERE customer_id IN (SELECT customer_id
                      FROM (SELECT customer_id, cu.email, num_reg, ROW_NUMBER() 
                                    OVER (PARTITION BY cu.email ORDER BY cu.customer_id) AS row_number
                            FROM public.customers cu
                            JOIN (SELECT email, COUNT(email) as num_reg
                                  FROM public.customers          
                                  GROUP BY email)e
                            ON cu.email = e.email)duplicates
                    WHERE row_number < num_reg)
RETURNING *;

-- La tabla vuelve a su estado original
DELETE FROM public.orders
WHERE purchase_total > 600
RETURNING *;

ALTER TABLE public.customers
ADD CONSTRAINT customers_email_key UNIQUE (email);


-- Solución final
SELECT url,name, COUNT(*)
FROM public.bookmarks
GROUP BY url,name
HAVING COUNT(*) > 1;

DELETE 
FROM public.bookmarks
WHERE id IN (SELECT id
             FROM public.bookmarks
             EXCEPT 
                    SELECT MAX(id)
                    FROM public.bookmarks
                    GROUP BY url,name)
RETURNING *;


-- 12 USING INNER JOINS

SELECT o.order_id, o.purchase_total, c.email
FROM public.orders o
JOIN public.customers c
ON o.customer_id = c.customer_id;

-- 13 USING OUTER JOINS
SELECT *
FROM public.students s
FULL OUTER JOIN public.programs p
ON s.program_id = p.program_id;

-- La mejor solución
SELECT p.program_name, COUNT(s.student_id) AS student_count
FROM public.programs p
LEFT OUTER JOIN students s
ON p.program_id = s.program_id
GROUP BY p.program_name;

-- 14 CREATING A TEMPORARY TABLE
CREATE TEMPORARY TABLE temp_customer_purchases AS
SELECT c.customer_id, c.email, SUM(o.purchase_total) AS purchases
FROM public.customers c
INNER JOIN public.orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.email;


-- 15 PATTERN MATCHING
-- Mi solución
SELECT c.customer_id, c.firstname, c.lastname, c.username, c."password", c.email, c.created_on, 
      CONCAT(SUBSTR(p.phone_number, 1, 3),'-',SUBSTR(p.phone_number, 4, 6),'-',SUBSTR(p.phone_number, 7, LENGTH(p.phone_number))) 
      AS phone_number
FROM public.customers c
JOIN (SELECT customer_id, REGEXP_REPLACE(phone_number, '\D+', '', 'g') AS phone_number
      FROM public.customers)p
ON c.customer_id = p.customer_id;

-- otra solución
SELECT c.customer_id, c.firstname, c.lastname, c.username, c."password", c.email, c.created_on, 
      REGEXP_REPLACE(p.phone_number, '(\d{3})(\d{3})(\d{4})', '\1-\2-\3')
      AS phone_number
FROM public.customers c
JOIN (SELECT customer_id, REGEXP_REPLACE(phone_number, '\D+', '', 'g') AS phone_number
      FROM public.customers)p
ON c.customer_id = p.customer_id;

-- Solución final
UPDATE public.customers
SET phone_number = REGEXP_REPLACE(phone_number, '\D+', '', 'g')
WHERE phone_number ~ '\D+';

UPDATE public.customers
SET phone_number = REGEXP_REPLACE(phone_number, '(\d{3})(\d{3})(\d{4})', '\1-\2-\3')
WHERE phone_number ~ '\d{10}$';

--16 FILER SENSITIVE DATA
-- Mi solución
SELECT CONCAT(firstname,' ', SUBSTR(UPPER(lastname), 1, 1),'.') AS "name", email, REGEXP_REPLACE(phone_number, '(\d{3})-(\d{3})-(\d{4})', '***-***-\3') as phone_number
FROM public.customers;

-- Solución final
SELECT CONCAT(firstname,' ', UPPER(SUBSTR(lastname, 1, 1)),'.') AS fullname, email, (SELECT CONCAT('***-***-', RIGHT(phone_number, 4))) AS masked_phone_number
FROM public.customers;


-- 17 UPDATING ORDER STATUS
-- Mi solución
UPDATE public.orders
SET status = 'Shipped'
WHERE order_id <= 5
RETURNING *;

UPDATE public.orders
SET status = 'Preparing for Shipment'
WHERE order_id > 5
RETURNING *;

-- Solución final
UPDATE public.orders
SET status = CASE 
                  WHEN order_id < 5 OR "timestamp" < '2023-06-11 00:00:00-07' AT TIME ZONE 'Europe/Madrid' THEN 'Shipped'
                  ELSE 'Preparing for Shipment'
             END
RETURNING *;

-- 18 DATA CLEANUP

-- Mi solución
UPDATE public.orders
SET city = CONCAT(SUBSTR(UPPER(TRIM(LEADING FROM city)), 1,1), 
            SUBSTR(LOWER(TRIM(LEADING FROM city)), 2,LENGTH(TRIM(LEADING FROM city)))),
      "state" = UPPER("state"),
      zip_code = SUBSTR(TRIM(LEADING FROM zip_code), 1,5)
RETURNING *;

-- Solución final
UPDATE public.orders
SET street = INITCAP(TRIM(street)),
      city = INITCAP(city),
      "state" = UPPER("state"),
      zip_code = SUBSTR(REGEXP_REPLACE(TRIM(zip_code), '\D+', '', 'g'), 1,5)
WHERE street != INITCAP(TRIM(street)) OR
      city != INITCAP(city) OR
      "state" != UPPER("state") OR
      zip_code != SUBSTR(REGEXP_REPLACE(TRIM(zip_code), '\D+', '', 'g'), 1,5)
RETURNING *;


-- 19 CREATING FICTICIOUS DATA
INSERT INTO public.bookmarks (url, name, description)
SELECT 'https://example.com/' || generate_series as url,
       'Bookmark ' || generate_series as name,
       'Description for bookmark ' || generate_series as description
       FROM generate_series(1, 50) as generate_series
RETURNING *;

-- 20 ENCRYPTING A PASSWORD
ALTER TABLE public.users
ADD COLUMN password_hash VARCHAR(255),
ADD COLUMN password_salt VARCHAR(255);

UPDATE public.users
SET password_salt = SUBSTR(MD5(RANDOM()::TEXT), 1, 16),
    password_hash = MD5(CONCAT('password_salt', "password"))
WHERE password_salt IS NULL
RETURNING *;

-- 21 CANCELING RUNNIN QUERIES

SELECT pid, query, xact_start, wait_event, wait_event_type
FROM pg_stat_activity
WHERE backend_type = 'client backend'
AND wait_event IS NOT NULL;

SELECT pg_cancel_backend(61476);

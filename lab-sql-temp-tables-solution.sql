use sakila;
-- Step 1: Create a View for rental information
drop view if EXISTS customer_rental_summary;
create VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
LEFT JOIN 
    rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;

-- Step 2: Create a Temporary Table for payment information
drop TEMPORARY table if exists customer_payment_summary;
create TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    crs.customer_name,
    crs.email,
    crs.rental_count,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM 
    customer_rental_summary crs
LEFT JOIN 
    payment p ON crs.customer_id = p.customer_id
GROUP BY 
    crs.customer_id, crs.customer_name, crs.email, crs.rental_count;

-- Step 3: Create CTE and final report
WITH customer_summary AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM 
        customer_rental_summary crs
    JOIN 
        customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count = 0 THEN 0
        ELSE ROUND(total_paid / rental_count, 2)
    END AS average_payment_per_rental
FROM 
    customer_summary
ORDER BY 
    total_paid DESC;
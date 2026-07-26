CREATE DATABASE brazilian_ecommerce;
USE brazilian_ecommerce;

-- ==========================================================
-- Customers
-- ==========================================================

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- ==========================================================
-- Orders
-- ==========================================================

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- ==========================================================
-- Order Items
-- ==========================================================

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- ==========================================================
-- Payments
-- ==========================================================

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- ==========================================================
-- Products
-- ==========================================================

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- ==========================================================
-- Reviews
-- ==========================================================

CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id)
);

-- ==========================================================
-- Sellers
-- ==========================================================

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- ==========================================================
-- Geolocation
-- ==========================================================

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

-- ==========================================================
-- Category Translation
-- ==========================================================

CREATE TABLE category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);
SHOW TABLES;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM category_translation;

DESCRIBE customers;
DESCRIBE order_items;
DESCRIBE payments;

# Customer Distribution by State

SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

# Payment Method Distribution

SELECT
    payment_type,
    COUNT(*) AS total_payments
FROM payments
GROUP BY payment_type
ORDER BY total_payments DESC;

# Average Payment by Method

SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_payment,
    ROUND(MAX(payment_value), 2) AS highest_payment,
    ROUND(MIN(payment_value), 2) AS lowest_payment
FROM payments
GROUP BY payment_type
ORDER BY average_payment DESC;

# Installment Analysis

SELECT
    payment_installments,
    COUNT(*) AS number_of_payments
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;

# Which product categories have the most products?

SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS total_products
FROM products p
JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY total_products DESC
LIMIT 10;

# What is the average product weight by category?

SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(product_weight_g),2) AS avg_weight_g
FROM products p
JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY avg_weight_g DESC
LIMIT 10;

# Which product categories have the largest products?

SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(product_length_cm),2) AS avg_length,
    ROUND(AVG(product_height_cm),2) AS avg_height,
    ROUND(AVG(product_width_cm),2) AS avg_width
FROM products p
JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY avg_length DESC
LIMIT 10;

# What is the average freight cost?

SELECT
    ROUND(AVG(freight_value),2) AS average_freight,
    ROUND(MAX(freight_value),2) AS maximum_freight,
    ROUND(MIN(freight_value),2) AS minimum_freight
FROM order_items;
# What is the average product price?

SELECT
    ROUND(AVG(price),2) AS average_price,
    ROUND(MAX(price),2) AS highest_price,
    ROUND(MIN(price),2) AS lowest_price
FROM order_items;

# Which products are the most expensive?
SELECT
    product_id,
    price
FROM order_items
ORDER BY price DESC
LIMIT 10;

# Which products have the highest shipping cost?
SELECT
    product_id,
    freight_value
FROM order_items
ORDER BY freight_value DESC
LIMIT 10;

# Which product categories appear most frequently in orders?
SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS total_items_sold
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY total_items_sold DESC
LIMIT 10;

# Which product categories generate the highest average selling price?
SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(oi.price),2) AS average_price
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY average_price DESC
LIMIT 10;

# Which categories have the highest average shipping cost?
SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(oi.freight_value),2) AS average_shipping
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY average_shipping DESC
LIMIT 10;

# What is the distribution of product prices?
SELECT
    CASE
        WHEN price < 50 THEN 'Below 50'
        WHEN price BETWEEN 50 AND 100 THEN '50-100'
        WHEN price BETWEEN 101 AND 200 THEN '101-200'
        WHEN price BETWEEN 201 AND 500 THEN '201-500'
        ELSE 'Above 500'
    END AS price_range,
    COUNT(*) AS total_products
FROM order_items
GROUP BY price_range
ORDER BY total_products DESC;


use orders;
Show tables;
select * from online_customer;
/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  both first name and last name are in upper case, customer email id,  customer creation year and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Hint: Use CASE statement, no permanent change in the table is required. 
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] */
SELECT CONCAT(
        CASE 
            WHEN YEAR(customer_creation_date) < 2005 THEN 'Mr/Ms'
            WHEN YEAR(customer_creation_date) >= 2005 AND YEAR(customer_creation_date) < 2011 THEN 'Mr/Ms'
            ELSE 'Mr/Ms'
        END,
        ' ',
       UPPER(CUSTOMER_FNAME),
        ' ',
       UPPER(CUSTOMER_LNAME)
    ) AS full_name,  
    CUSTOMER_ID,
    CUSTOMER_EMAIL,
    CUSTOMER_CREATION_DATE,
    CASE
        WHEN YEAR(customer_creation_date) < 2005 THEN 'Category A'
        WHEN YEAR(customer_creation_date) >= 2005 AND YEAR(customer_creation_date) < 2011 THEN 'Category B'
        ELSE 'Category C'
    END AS customer_category
FROM online_customer;
-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
SELECT 
    p.product_id,
    p.product_desc,
    p.product_quantity_avail,
    p.product_price,
    (p.product_quantity_avail * p.product_price) AS inventory_value,
    CASE
        WHEN p.product_price > 20000 THEN p.product_price * 0.8
        WHEN p.product_price > 10000 THEN p.product_price * 0.85
        ELSE p.product_price * 0.9
    END AS new_price
FROM 
    product p
LEFT JOIN 
    order_items oi ON p.product_id = oi.product_id
WHERE 
    oi.order_id IS NULL
ORDER BY 
    inventory_value DESC;
-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]

SELECT pc.product_class_code, pc.product_class_desc, COUNT(p.product_id) AS count_product_type, SUM(p.product_quantity_avail * p.product_price) AS inventory_value
FROM PRODUCT p 
JOIN PRODUCT_CLASS pc ON p.product_class_code = pc.product_class_code 
GROUP BY pc.product_class_code, pc.product_class_desc 
HAVING inventory_value > 100000 
ORDER BY inventory_value DESC;


-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

SELECT 
    oc.customer_id,
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS full_name,
    oc.customer_email,
    oc.customer_phone,
    a.country
FROM 
    online_customer oc
JOIN 
    address a ON oc.address_id = a.address_id
WHERE 
    oc.customer_id IN (
        SELECT 
            oh.customer_id
        FROM 
            order_header oh
        WHERE 
            oh.order_status = 'Cancelled'
        GROUP BY 
            oh.customer_id
        HAVING 
            COUNT(*) = (
                SELECT 
                    COUNT(*)
                FROM 
                    order_header
                WHERE 
                    customer_id = oh.customer_id
            )
    );


-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

SELECT 
    s.shipper_name,
    a.city AS city_catering,
    COUNT(DISTINCT oc.customer_id) AS num_customers_catered,
    COUNT(*) AS num_consignments_delivered
FROM 
    shipper s
JOIN 
    order_header oh ON s.shipper_id = oh.shipper_id
JOIN 
    online_customer oc ON oh.customer_id = oc.customer_id
JOIN 
    address a ON oc.address_id = a.address_id
WHERE 
    s.shipper_name = 'DHL'
GROUP BY 
    s.shipper_name, a.city;


-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]

SELECT 
    oc.customer_id,
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS full_name,
    SUM(oi.product_quantity) AS total_quantity,
    SUM(oi.product_quantity * p.product_price) AS total_value
FROM 
    online_customer oc
JOIN 
    order_header oh ON oc.customer_id = oh.customer_id
JOIN 
    order_items oi ON oh.order_id = oi.order_id
JOIN 
    product p ON oi.product_id = p.product_id
WHERE 
    oh.payment_mode = 'Cash'
    AND oc.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
    oc.customer_id, oc.CUSTOMER_FNAME, oc.CUSTOMER_LNAME;



-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]

SELECT 
    oi.order_id,
    SUM(oi.product_quantity * (c.LEN * c.WIDTH * c.HEIGHT)) AS total_volume
FROM 
    order_items oi
JOIN 
    product p ON oi.product_id = p.PRODUCT_ID
JOIN 
    carton c ON c.CARTON_ID = 10
WHERE 
    oi.order_id IN (
        SELECT 
            order_id
        FROM 
            order_items
        WHERE 
            carton_id = 10
    )
GROUP BY 
    oi.order_id
ORDER BY 
    total_volume DESC
LIMIT 1;


-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)


SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    COALESCE(sold.product_quantity_sold, 0) AS product_quantity_sold,
    CASE 
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
            CASE 
                WHEN COALESCE(sold.product_quantity_sold, 0) = 0 THEN 'No sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.1 * COALESCE(sold.product_quantity_sold, 0) THEN 'Low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.5 * COALESCE(sold.product_quantity_sold, 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE 
                WHEN COALESCE(sold.product_quantity_sold, 0) = 0 THEN 'No sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.2 * COALESCE(sold.product_quantity_sold, 0) THEN 'Low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.6 * COALESCE(sold.product_quantity_sold, 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE 
                WHEN COALESCE(sold.product_quantity_sold, 0) = 0 THEN 'No sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.3 * COALESCE(sold.product_quantity_sold, 0) THEN 'Low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.7 * COALESCE(sold.product_quantity_sold, 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS inventory_status
FROM 
    product p
JOIN 
    product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
LEFT JOIN 
    (SELECT 
         PRODUCT_ID,
         SUM(PRODUCT_QUANTITY) AS product_quantity_sold
     FROM 
         order_items
     GROUP BY 
         PRODUCT_ID) AS sold ON p.PRODUCT_ID = sold.PRODUCT_ID;


-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]

SELECT 
    oi.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(oi.PRODUCT_QUANTITY) AS tot_qty
FROM 
    order_items oi
JOIN 
    product p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE 
    oi.ORDER_ID IN (
        SELECT 
            oh.ORDER_ID
        FROM 
            order_header oh
        JOIN 
            online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
        JOIN 
            address a ON oc.ADDRESS_ID = a.ADDRESS_ID
        WHERE 
            a.CITY NOT IN ('Bangalore', 'New Delhi')
    )
    AND oi.PRODUCT_ID != 201
GROUP BY 
    oi.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY 
    tot_qty DESC;



-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]

SELECT 
    oh.ORDER_ID,
    oc.CUSTOMER_ID,
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS full_name,
    SUM(oi.PRODUCT_QUANTITY) AS total_quantity_shipped
FROM 
    order_header oh
JOIN 
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
JOIN 
    order_items oi ON oh.ORDER_ID = oi.ORDER_ID
WHERE 
    oh.ORDER_ID % 2 = 0
    AND NOT (a.PINCODE LIKE '5%')
GROUP BY 
    oh.ORDER_ID, oc.CUSTOMER_ID, full_name;
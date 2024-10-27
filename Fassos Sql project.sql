create database restaurent;
use restaurent;

CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
(2,'2021-03-01'),
(3,'2021-08-01'),
(4,'2021-01-15');

SET SQL_SAFE_UPDATES = 0;
UPDATE driver SET reg_date='2021-01-03' where driver_id=2;
UPDATE driver SET reg_date='2021-01-08' where driver_id=3;

select * from driver;


CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

select * from ingredients;


CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

select * from rolls;


CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

select * from rolls_recipes;


CREATE TABLE driver_order
(order_id integer,driver_id integer,pickup_time datetime,
distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));

INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-03-01 00:12:37','13.4km','20 mins','NaN'),
(4,2,'2021-04-01 13:53:03','23.4','40','NaN'),
(5,3,'2021-08-01 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2020-08-01 21:30:45','25km','25mins',null),
(8,2,'2020-10-01 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2020-11-01 18:50:20','10km','10minutes',null);

truncate table driver_order;

select * from driver_order;

INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-01-03 00:12:37','13.4km','20 mins','NaN'),
(4,2,'2021-01-04 13:53:03','23.4','40','NaN'),
(5,3,'2021-01-08 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2020-01-8 21:30:45','25km','25mins',null),
(8,2,'2020-01-10 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2020-01-11 18:50:20','10km','10minutes',null);


CREATE TABLE customer_orders
(order_id integer,customer_id integer,roll_id integer,
not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);

INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','2021-01-01 18:05:02'),
(2,101,1,'','','2021-01-01 19:00:52'),
(3,102,1,'','','2021-01-02 23:51:23'),
(3,102,2,'','NaN','2021-01-02 23:51:23'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,2,'4','','2021-01-04 13:23:46'),
(5,104,1,null,'1','2021-01-08 21:00:29'),
(6,101,2,null,null,'2021-01-08 21:03:13'),
(7,105,2,null,'1','2021-01-08 21:20:29'),
(8,102,1,null,null,'2021-01-09 23:54:33'),
(9,103,1,'4','1,5','2021-01-10 11:22:59'),
(10,104,1,null,null,'2021-01-10 18:34:49'),
(10,104,1,'2,6','1,4','2021-01-11 18:34:49');

select * from customer_orders;
truncate table customer_orders;

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;



# how many rolls were ordered?

select count(roll_id) from customer_orders;       

#how many unique customer orders were made?

select distinct customer_id from customer_orders;   

SELECT COUNT(DISTINCT(customer_id)) AS unique_order
FROM customer_orders  

# Data Cleaning

SELECT order_id, driver_id, pickup_time, 
        Trim(REPLACE(Lower(distance), "km", " ")) AS distance,
        Trim(REPLACE(REPLACE(REPLACE(Lower(duration), "minutes", " "), "mins", " "), "minute", " ")) AS Duration,
        CASE WHEN cancellation IN ("cancellation","Customer Cancellation") THEN 0 ELSE 1 END AS new_cancellation,
        CASE WHEN cancellation IN ("cancellation","Customer Cancellation") THEN "Cancel" ELSE "Not Cancel" END AS Cancellation_Status 
FROM driver_order;

#how many successful orders were delivered by each driver?

select driver_id, count(distinct order_id) Total_Orders_Delivered from driver_order 
where cancellation not in ('cancellation','customer cancellation') group by driver_id;

#4)how many each types of rolls were delivered?

SELECT r.roll_name, COUNT((r.roll_id)) AS Rolls_Sold
FROM customer_orders c
JOIN Temp_Driver_Orders d
ON c.order_id = d.order_id
JOIN rolls r
ON c.roll_id = r.roll_id
WHERE d.Cancellation_status = "Not Cancel"
GROUP BY r.roll_name;

# Data Cleaning

SELECT order_id, customer_id, roll_id, 
CASE WHEN not_include_items IS NULL OR not_include_items = "" THEN 0 ELSE not_include_items END AS new_not_included_item,
CASE WHEN extra_items_included IS NULL OR extra_items_included = "" OR extra_items_included = "NaN" THEN 0 ELSE extra_items_included END AS new_extra_items_included,
order_date
FROM customer_orders;


#5)how many veg and non veg rolls were ordered by each customer?

SELECT c.customer_id, r.roll_name, Count(r.roll_id)
FROM customer_orders c
JOIN rolls r
ON c.roll_id = r.roll_id
GROUP BY c.customer_id, r.roll_name
ORDER BY r.roll_name;


#6) what was the maximum number of roads delivered in a single order?

WITH T1 AS (
SELECT c.order_id, COUNT(c.roll_id) AS Rolls_Delivered
FROM customer_orders c
JOIN Temp_Driver_Orders d
ON c.order_id = d.order_id
WHERE cancellation_status = "Not Cancel"
GROUP BY c.order_id),

T2 AS 
(SELECT *,
DENSE_RANK() OVER (ORDER BY Rolls_Delivered DESC) AS RNK
FROM T1)
SELECT * FROM T2 WHERE RNK = 1;

# For each customer, how many delivered rolls had atleast 1 change and how many had no change?

with temp_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id, customer_id,roll_id, 
case when not_include_items is NULL or not_include_items="" then '0' else not_include_items end as new_not_include_items,
case when extra_items_included="" or extra_items_included='NaN' or extra_items_included is NULL then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
) 
,temp_driver_order (order_id,driver_id,pickup_time,distance,duration,cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration, 
case when cancellation in ('cancellation', 'customer cancellation') then 0 else 1 end as new_cancellation
from driver_order
)
select customer_id, chg_no_chg,count(order_id) at_least_one_Change from 
(select *, case when not_include_items='0' and extra_items_included='0' then 'No_Changes' else 'Changes' end chg_no_chg
from temp_customer_orders where order_id in( select order_id from temp_driver_order where cancellation !=0)) c
group by customer_id, chg_no_chg;

# How many rolls were delivered that had both exclusions and extras?

with temp_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id, customer_id,roll_id, 
case when not_include_items is NULL or not_include_items="" then '0' else not_include_items end as new_not_include_items,
case when extra_items_included="" or extra_items_included='NaN' or extra_items_included is NULL then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
) 
,temp_driver_order (order_id,driver_id,pickup_time,distance,duration,cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration, 
case when cancellation in ('cancellation', 'customer cancellation') then 0 else 1 end as new_cancellation
from driver_order
)
select chg_no_chg, count(chg_no_chg) from 
(select *, case when not_include_items !='0' and extra_items_included !='0' then 'both_inc_exc' else 'either_1_inc_or_exc' end chg_no_chg
from temp_customer_orders where order_id in( select order_id from temp_driver_order where cancellation !=0)) c group by chg_no_chg;

# What was the total number of rolls ordered for each hour of the day?

select Hrs_Slot, count(roll_id) Order_Count from
(select *,concat(cast(hour(order_date) as char),"-",cast(hour(order_date)+1 as char)) as Hrs_Slot from customer_orders) a
group by Hrs_Slot;

# What was the number of orders for each day of the week?

select days, count(distinct order_id) as Day_Cnt from
(select *, dayname(order_date) as Days from customer_orders) a
group by days;

# What was the Average time in minutes it took for each driver to arrive at the Faaso’s HQ to pickup the order?

select driver_id,sum(diff)/count(order_id) as Avg_Min from
(select * from 
(select *, row_number() over(partition by order_id order by diff) rnk from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation, TIMESTAMPDIFF(minute,a.order_date,b.pickup_time) AS Diff from customer_orders a 
inner join driver_order b on a.order_id=b.order_id where b.pickup_time is not null) a) b where rnk=1) c group by driver_id;

# Is there any relationship between the number of rolls and how long the order takes to prepare?

select order_id,count(roll_id) cnt,sum(diff)/count(roll_id) as Avg from
(select a.order_id,a.customer_id,a.roll_id,a.not_include_items,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation, timestampdiff(minute,order_date,pickup_time) AS Diff from customer_orders a 
inner join driver_order b on a.order_id=b.order_id where pickup_time is not null) c 
group by order_id;

# What was the average distance travelled for each customer?

select customer_id, sum(distance)/count(customer_id) as Avg_Distance from
(select *, row_number() over(partition by order_id order by order_id) rnk from
(select a.order_id,a.customer_id,cast(trim(replace(lower(b.distance),"km","")) as decimal(4,2)) distance from customer_orders a 
inner join driver_order b on a.order_id=b.order_id where distance is not null)c) d where rnk=1 group by customer_id;

# What was the difference between the shortest and longest delivery times for all orders?

select max(duration) Max_duration,min(duration) Min_Duration,max(duration)- min(duration) Difference from 
(select order_id,driver_id,pickup_time,distance,cast(trim(replace(lower(duration),"minutes","")) as unsigned) duration,cancellation
from driver_order where duration is not null) c;

# What was the average speed for each driver for each delivery and do you notice any trend for these values

select c.order_id,c.driver_id,c.distance/c.duration as Avg_Speed,d.cnt from
(select order_id,driver_id,pickup_time,cast(trim(replace(lower(duration),"minutes","")) as unsigned) duration,
cast(trim(replace(lower(distance),"km","")) as decimal(4,2)) distance,cancellation from driver_order where distance is not null) c
inner join (select order_id,count(roll_id) cnt from customer_orders group by order_id) d on c.order_id=d.order_id;

# What was the successful delivery percentage for each driver?

select driver_id, sum(can_per) Successful_Delivery,count(driver_id) Total_Order,(sum(can_per)/count(driver_id)*100) Percentage from
(select driver_id,case when lower(cancellation) like '%cancel%' then 0 else 1 end as can_per from driver_order) a
group by driver_id;
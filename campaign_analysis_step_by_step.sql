## find the most 2 popular category based on total sales amount for each city, which has more than 100 customers
 ## other campaign may based on the inventory level. The planner initiative a campaign to promote the categories with most inventory on cities with more than 100 customers.

DROP
TEMPORARY TABLE IF EXISTS digital_marketing.qualified_city;
CREATE
TEMPORARY TABLE IF NOT EXISTS digital_marketing.qualified_city
as (
SELECT customer_city, count(*) as customer_number
FROM digital_marketing.customers
group by customer_city
having customer_number>100);

select * from digital_marketing.qualified_city;

DROP
TEMPORARY TABLE IF EXISTS digital_marketing.qualified_customer;
CREATE
TEMPORARY TABLE IF NOT EXISTS digital_marketing.qualified_customer
as (
select c.customer_id, c.customer_city 
from digital_marketing.customers c
inner join digital_marketing.qualified_city qc on c.customer_city=qc.customer_city);

select * from digital_marketing.qualified_customer;

select distinct order_status from digital_marketing.orders;
select * from digital_marketing.orders;
select * from digital_marketing.order_items;

DROP
TEMPORARY TABLE IF EXISTS digital_marketing.final_list;
CREATE
TEMPORARY TABLE IF NOT EXISTS digital_marketing.final_list
as (
select c.customer_city, ca.category_name, sum(oi.order_item_subtotal) as total_sales_amount
from digital_marketing.qualified_customer c
inner join digital_marketing.orders o on c.customer_id=o.order_customer_id AND o.order_status NOT IN ('ON_HOLD', 'CANCELED', 'SUSPECTED_FRAUD')
inner join digital_marketing.order_items oi on o.order_id=oi.order_item_order_id 
inner join digital_marketing.products p on oi.order_item_product_id=p.product_id
inner join digital_marketing.categories ca ON p.product_category_id=ca.category_id
group by c.customer_city, ca.category_name
order by c.customer_city, total_sales_amount desc);

select * from digital_marketing.final_list;

DROP
TEMPORARY TABLE IF EXISTS digital_marketing.final_list_clone;
CREATE
TEMPORARY TABLE IF NOT EXISTS digital_marketing.final_list_clone
as (select * from digital_marketing.final_list);

select * from digital_marketing.final_list_clone;


select fl.*, count(flc.customer_city) as rank_num
from digital_marketing.final_list fl 
left join digital_marketing.final_list_clone flc on fl.customer_city=flc.customer_city and flc.total_sales_amount>=fl.total_sales_amount
group by fl.customer_city, fl.category_name, fl.total_sales_amount
having rank_num<=2;








CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);
INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

select * from members
select * from menu
select * from sales

select s.customer_id, sum(price) as total_amount
from sales as s
join menu as m on s.product_id=m.product_id
group by s.customer_id;

select customer_id, count(order_date) as total_date
from sales
group by customer_id;

WITH ordered_sales_cte AS
(
 SELECT s.customer_id, s.order_date, m.product_name,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
 FROM dbo.sales AS s
 JOIN dbo.menu AS m
  ON s.product_id = m.product_id
) 
SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE rank = 1
group by customer_id, product_name;

select top 1 count(s.product_id) as most_purchase, m.product_name
from sales as s
join menu as m on s.product_id=m.product_id
group by s.product_id, product_name
order by most_purchase desc;

with fav_item_cte as
(
select s.customer_id, m.product_name, 
count(s.product_id) as order_count,
DENSE_RANK() over(partition by s.customer_id order by count(s.customer_id) desc) as rank
from sales as s
join menu as m on s.product_id=m.product_id
group by s.customer_id, m.product_name
)
select customer_id, product_name
from fav_item_cte
where rank=1


select top 1 m.product_name, count(s.product_id) as most_purchased
from sales as s
join menu as m on s.product_id=m.product_id
group by s.product_id, m.product_name
order by most_purchased desc;

with first_purchased_cte as
(
select s.customer_id, m.join_date, s.order_date, s.product_id, 
	DENSE_RANK() over(partition by s.customer_id order by s.order_date) as rank
from sales as s
join members as m 
on s.customer_id=m.customer_id
where s.order_date <= m.join_date
)
select f.customer_id, n.product_name, f.order_date, f.join_date
from first_purchased_cte as f
join menu as n
on f.product_id=n.product_id
where rank=1;

select s.customer_id, count(distinct s.product_id) as item_amount, sum(mm.price) as total_sale
from sales as s
join members as m on s.customer_id=m.customer_id
join menu as mm on s.product_id=mm.product_id
where s.order_date < m.join_date 
group by s.customer_id;

with price_point as
(
select *, 
case when product_name='sushi' then price*20 else price*10 end as points
from menu
)
select s.customer_id, sum(p.points) as total_point
from sales as s
join price_point as p on s.product_id=p.product_id
group by s.customer_id









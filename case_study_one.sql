CREATE TABLE SALES (
	"customer_id" VARCHAR(5),
	"order_date" DATE,
	"product_id" INT
);
INSERT INTO
	SALES ("customer_id", "order_date", "product_id")
VALUES
	('A', '2021-01-01', 1),
	('A', '2021-01-01', 2),
	('A', '2021-01-07', 2),
	('A', '2021-01-10', 3),
	('A', '2021-01-11', 3),
	('A', '2021-01-11', 3),
	('B', '2021-01-01', 2),
	('B', '2021-01-02', 2),
	('B', '2021-01-04', 1),
	('B', '2021-01-11', 1),
	('B', '2021-01-16', 3),
	('B', '2021-02-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-07', 3);

SELECT
	*
FROM
	SALES;

CREATE TABLE MENU (
	"product_id" INT,
	"product_name" VARCHAR(10),
	"price" INT
);

INSERT INTO
	MENU ("product_id", "product_name", "price")
VALUES
	(1, 'sushi', 10),
	(2, 'curry', 15),
	(3, 'ramen', 12);

SELECT
	*
FROM
	MENU;

CREATE TABLE MEMBERS ("customer_id" VARCHAR(2), "join_date" DATE);

INSERT INTO
	MEMBERS ("customer_id", "join_date")
VALUES
	('A', '2021-01-07'),
	('B', '2021-01-09');

SELECT
	*
FROM
	MEMBERS




-- What is the total amount each customer spent at the restaurant?
SELECT
	SL.CUSTOMER_ID,
	SUM(ME.PRICE) AS TOTAL_AMOUNT_SPENT
FROM
	SALES SL
	LEFT JOIN MENU ME ON SL.PRODUCT_ID = ME.PRODUCT_ID
GROUP BY
	SL.CUSTOMER_ID
ORDER BY
	TOTAL_AMOUNT_SPENT DESC;


-- How many days has each customer visited the restaurant?
SELECT
	CUSTOMER_ID,
	COUNT(DISTINCT ORDER_DATE) AS VISITED
FROM
	SALES
GROUP BY
	CUSTOMER_ID
ORDER BY
	VISITED DESC;

-- What was the first item from the menu purchased by each customer?
WITH
	RANK_TABLE AS (
		SELECT
			*,
			DENSE_RANK() OVER (
				PARTITION BY
					CUSTOMER_ID
				ORDER BY
					ORDER_DATE ASC
			) AS RN
		FROM
			MENU ME
			JOIN SALES SL ON ME.PRODUCT_ID = SL.PRODUCT_ID
	)
SELECT DISTINCT
	CUSTOMER_ID,
	PRODUCT_NAME
FROM
	RANK_TABLE
WHERE
	RN = 1
ORDER BY
	CUSTOMER_ID ASC;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	ME.PRODUCT_NAME,
	COUNT(SL.PRODUCT_ID) AS MOST_PURCHASED_ITEM
FROM
	MENU ME
	JOIN SALES SL ON ME.PRODUCT_ID = SL.PRODUCT_ID
GROUP BY
	ME.PRODUCT_NAME LIMIT
	1;

-- Which item was the most popular for each customer?
WITH
	MOST_POPULAR AS (
		SELECT
			SL.CUSTOMER_ID,
			ME.PRODUCT_NAME,
			COUNT(ME.PRODUCT_ID) AS ORDER_COUNT,
			DENSE_RANK() OVER (
				PARTITION BY
					SL.CUSTOMER_ID
				ORDER BY
					COUNT(SL.CUSTOMER_ID) DESC
			) AS RANK
		FROM
			MENU ME
			JOIN SALES SL ON ME.PRODUCT_ID = SL.PRODUCT_ID
		GROUP BY
			SL.CUSTOMER_ID,
			ME.PRODUCT_NAME
	)
SELECT
	CUSTOMER_ID,
	PRODUCT_NAME,
	ORDER_COUNT
FROM
	MOST_POPULAR
WHERE
	RANK = 1;

-- Which item was purchased first by the customer after they became a member?
WITH
	FIRST_PURCHASE AS (
		SELECT
			SL.CUSTOMER_ID,
			SL.ORDER_DATE,
			SL.PRODUCT_ID,
			MM.JOIN_DATE,
			ME.PRODUCT_NAME,
			ROW_NUMBER() OVER (
				PARTITION BY
					SL.CUSTOMER_ID
				ORDER BY
					ORDER_DATE ASC
			) AS RN
		FROM
			SALES SL
			LEFT JOIN MEMBERS MM ON SL.CUSTOMER_ID = MM.CUSTOMER_ID
			JOIN MENU ME ON SL.PRODUCT_ID = ME.PRODUCT_ID
		WHERE
			SL.ORDER_DATE >= MM.JOIN_DATE
	)
SELECT
	CUSTOMER_ID,
	PRODUCT_ID,
	PRODUCT_NAME
FROM
	FIRST_PURCHASE
WHERE
	RN = 1;





-- Which item was purchased just before the customer became a member?
WITH
	PURCHASED_PRIOR_MEMBER AS (
		SELECT DISTINCT
			SL.CUSTOMER_ID,
			ME.PRODUCT_NAME,
			ROW_NUMBER() OVER (
				PARTITION BY
					SL.CUSTOMER_ID
				ORDER BY
					SL.ORDER_DATE DESC
			) AS RN
		FROM
			SALES SL
			LEFT JOIN MEMBERS MM ON SL.CUSTOMER_ID = MM.CUSTOMER_ID
			JOIN MENU ME ON SL.PRODUCT_ID = ME.PRODUCT_ID
		WHERE
			SL.ORDER_DATE < MM.JOIN_DATE
	)
SELECT
	CUSTOMER_ID,
	PRODUCT_NAME
FROM
	PURCHASED_PRIOR_MEMBER
WHERE
	RN = 1
ORDER BY
	CUSTOMER_ID ASC;

-- What is the total items and amount spent for each member before they became a member?
SELECT
	SL.CUSTOMER_ID,
	COUNT(SL.PRODUCT_ID) AS TOTAL_ITEMS,
	SUM(ME.PRICE) AS TOTAL_AMOUNT_SPENT
FROM
	SALES SL
	LEFT JOIN MEMBERS MM ON SL.CUSTOMER_ID = MM.CUSTOMER_ID
	JOIN MENU ME ON SL.PRODUCT_ID = ME.PRODUCT_ID
WHERE
	SL.ORDER_DATE < MM.JOIN_DATE
GROUP BY
	SL.CUSTOMER_ID
ORDER BY 
	SL.CUSTOMER_ID;


-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH
	POINTS_TABLE AS (
		SELECT
			SL.CUSTOMER_ID,
			ME.PRODUCT_NAME,
			CASE
				WHEN ME.PRODUCT_NAME IN ('sushi') THEN ME.PRICE * 20
				ELSE ME.PRICE * 10
			END AS POINTS
		FROM
			SALES SL
			JOIN MENU ME ON SL.PRODUCT_ID = ME.PRODUCT_ID
	)
SELECT
	CUSTOMER_ID,
	SUM(POINTS) AS TOTAL_POINTS
FROM
	POINTS_TABLE
GROUP BY
	CUSTOMER_ID
ORDER BY
	CUSTOMER_ID ASC;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all 
-- items, not just sushi - how many points do customer A and B have at the end of January?
with day_added as (
select sl.customer_id,sl.product_id, me.product_name, me.price, sl.order_date, 
join_date + 6 as seven_day_added,
2 * 10 * price  as points
from sales sl 
left join members mm on sl.customer_id = mm.customer_id
join menu me on sl.product_id = me.product_id
where sl.order_date >= mm.join_date
)

select customer_id, sum(points) as total_points
from day_added
where order_date between '2021-01-01' and '2021-01-31'
group by customer_id
order by customer_id asc;
-- The following questions are related creating basic data tables that Danny and his team can use to quickly derive
-- insights without needing to join the underlying tables using SQL.
-- Recreate the following table output using the available data:

SELECT
	SL.CUSTOMER_ID,
	SL.ORDER_DATE,
	ME.PRODUCT_NAME,
	ME.PRICE,
	CASE
		WHEN SL.ORDER_DATE >= MM.JOIN_DATE THEN 'Y'
		ELSE 'N'
	END AS MEMBER
FROM
	SALES SL
	LEFT JOIN MEMBERS MM ON SL.CUSTOMER_ID = MM.CUSTOMER_ID
	JOIN MENU ME ON SL.PRODUCT_ID = ME.PRODUCT_ID;

-- Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for
-- non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
WITH
	MEMBER_TABLE AS (
		SELECT
			SL.CUSTOMER_ID,
			SL.ORDER_DATE,
			ME.PRODUCT_NAME,
			ME.PRICE,
			CASE
				WHEN SL.ORDER_DATE >= MM.JOIN_DATE THEN 'Y'
				ELSE 'N'
			END AS MEMBER
		FROM
			SALES SL
			LEFT JOIN MEMBERS MM ON SL.CUSTOMER_ID = MM.CUSTOMER_ID
			JOIN MENU ME ON SL.PRODUCT_ID = ME.PRODUCT_ID
	)
SELECT
	*,
	CASE
		WHEN MEMBER = 'N' THEN NULL
		ELSE RANK() OVER (
			PARTITION BY
				CUSTOMER_ID,
				MEMBER
			ORDER BY
				ORDER_DATE ASC
		)
	END AS RN
FROM
	MEMBER_TABLE;










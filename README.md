# Case Study #1 - Danny's Diner ::ramen::

<img src="https://user-images.githubusercontent.com/98699089/156034616-ef978d44-af18-4e54-9885-1ac376a009bf.png" width="500">

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business. Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.

## Available Data

Danny has shared with you 3 key datasets for this case study:
- `sales`;
- `menu`;
- `members`.

### Table 1: `sales`

The `sales` table captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered.

| customer_id | order_date | product_id |
|-------------|------------|------------|
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

### Table 2: `menu`

The `menu` table maps the `product_id` to the actual `product_name` and price of each menu item.

| product_id | product_name | price |
|------------|--------------|-------|
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

### Table 3: `members`

The final members table captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program.

| customer_id | join_date  |
|-------------|------------|
| A           | 2021-01-07 |
| B           | 2021-01-09 |

## Entity Relationship Diagram

![изображение](https://user-images.githubusercontent.com/98699089/156034410-8775d5d2-eda5-4453-9e33-54bfef253084.png)

{{ config(
    schema='gold',
    materialized='table'
) }}

select 
    customers.contact_name, 
    sum(order_details.unit_price * order_details.quantity * (1.0 - order_details.discount) * 100) / 100 as payments
from 
    {{ ref('int_customers') }} as customers
inner join 
    {{ ref('int_orders') }} as orders on orders.customer_id = customers.customer_id
inner join 
    {{ ref('int_order_details') }} as order_details on order_details.order_id = orders.order_id
where 
    lower(customers.country) = 'uk'
group by 
    customers.contact_name
having 
    sum(order_details.unit_price * order_details.quantity * (1.0 - order_details.discount)) > 1000
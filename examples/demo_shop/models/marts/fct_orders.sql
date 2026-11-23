--PLANTED:

select 
     o.order_id
    ,o.customer_id
    ,c.name as customer_name
    ,c.city
    ,o.amount
    ,o.status
from {{ ref('stg_orders')}}        as o
left join {{ ref('stg_customers')}} as c
on o.customer_id = c.customer_id
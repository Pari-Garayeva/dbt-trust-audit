--PLANTED:

select 
     c.customer_id
    ,c.name
    ,count(o.order_id) as order_count
from
{{ source('raw','raw_customers') }} c
left join main.raw_orders o on c.customer_id=o.customer_id
group by 1,2
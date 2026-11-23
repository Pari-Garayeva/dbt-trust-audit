-- QƏSDƏN SƏHV (M002): staging başqa staging-dən asılıdır (ref('stg_orders')).
-- Düzgün qayda: staging yalnız source oxuyur, join-lər marts/intermediate-də olur.

select
     p.payment_id
    ,p.order_id
    ,o.customer_id
    ,p.amount
from {{ source('raw', 'raw_payments') }} as p
left join {{ ref('stg_orders') }}        as o
    on o.order_id = p.order_id
